# 20 — 目标架构：可复用的静态重编译平台

状态：目标设计，未宣称当前已经实现。

本章记录未来希望形成的静态重编译架构。它吸收 LASRecomp 的优点，也保留 nxnative 已经完成的 Android、guest、
NVN 和 Vulkan 探索成果。目标不是复制某个游戏项目，而是让第二个、第三个游戏的接入成本显著低于第一个游戏。

## 目标

```text
一次建设通用工具和 runtime
        ↓
每个游戏只新增 profile、生成结果和必要 adapter
        ↓
每个平台只新增 platform/backend 实现
        ↓
所有结论都能由契约测试、差分 trace 和固定路线复核
```

目标架构必须同时满足四件事：

1. 游戏代码能够直接执行在宿主 ARM64 上；
2. Horizon/NVN 语义集中在可测试的 runtime 边界；
3. Mac、Android 和其他平台共享尽可能多的核心代码；
4. 游戏特化参数不会污染通用 runtime，也不会被遗忘在聊天记录里。

## LASRecomp 的优势

### 1. 把一次性逆向工作固化成生成器

它使用生成器处理 NSO、函数边界、ARM64 指令、跳转表、重定位和代码输出。AI 或人工完成的逆向判断被固化成
工具后，后续构建不需要每次重新理解整个二进制。

### 2. 运行时边界清楚

生成的 game library 通过稳定函数表接入 runtime。游戏代码、Horizon 服务、图形后端和平台外壳有清楚的边界，
因此问题可以先归类为“生成器、runtime、图形或平台”，而不是在一个巨大进程里盲猜。

### 3. 游戏特化内容显式化

地址、build ID、patch、shader 和资源规则集中在生成器输入、patch 表或 profile 中。它们不会悄悄变成通用
runtime 的永久特判。

### 4. 构建产物可缓存、可恢复、可追溯

生成器、编译器、flags、patch hash 和 build ID 共同决定 game library 的身份。中断后可以继续，工具链变化后可以
准确失效，不需要“感觉这次应该重新生成”。

### 5. 平台优化建立在正确性之后

移动端的帧生成、pipeline cache、动态分辨率、上传和驱动调优都有独立开关和测量，不会把性能实验和基本语义
混成一个不可回退的修复。

### 6. 外部借鉴有边界

可以借鉴设计、测试方法和接口语义；需要复制代码时，先核对许可证、ABI、对象布局、线程模型和生命周期。这使得
公开手册能持续吸收 GitHub 经验，又不会把私有代码或 GPL 实现不加审核地带入项目。

## 目标分层

```text
┌──────────────────────────────────────────────┐
│ Game profile / adapter                        │
│ build ID · address map · patches · shaders   │
│ resources · services · input · regression     │
├──────────────────────────────────────────────┤
│ Recompiler toolchain                          │
│ NSO parser · function discovery · ARM64 lifter│
│ jump-table resolver · relocations · codegen   │
│ incremental generator · game-library ABI      │
├──────────────────────────────────────────────┤
│ Shared Horizon/NVN runtime                    │
│ CPU context · memory · TLS · SVC · IPC        │
│ threads · FS · HID · audio · movie            │
│ NVN objects · command lists · resource ledger │
├──────────────────────────────────────────────┤
│ Shared graphics frontend                      │
│ shader reflection · descriptor model          │
│ texture/image lifecycle · render graph        │
│ upload/readback · submit/present contracts    │
├──────────────────────────────────────────────┤
│ Platform/backend                             │
│ macOS/Metal · Android/Vulkan · other targets  │
│ window · storage · input · driver capability  │
└──────────────────────────────────────────────┘
```

### 层之间的规则

| 层 | 可以依赖 | 不应该依赖 |
|---|---|---|
| Profile/adapter | 所有下层公共接口 | 另一个游戏的地址或隐式全局状态 |
| Recompiler | NSO/ARM64 格式和明确 profile | Android、Metal 或某个 shader hash |
| Horizon/NVN runtime | 稳定 game-library ABI | 某个游戏的临时容量和截图特判 |
| Graphics frontend | NVN 语义和结构化资源描述 | 某一平台的 Vulkan/Metal handle |
| Platform/backend | 公共 runtime/frontend 接口 | 直接修改游戏生成代码 |

## Profile 是跨游戏复用的关键

每个游戏新增一个 profile，而不是复制整个 runtime：

```text
games/<title-id>/<build-id>/
  manifest.toml
  modules.tsv
  address-map.tsv
  hle-symbols.txt
  patch-map.tsv
  shader-map.tsv
  resource-facts.tsv
  memory-profile.tsv
  device-matrix.tsv
  regression-routes.md
```

`manifest` 至少包含：

- title ID、base/update 版本和 NSO build ID；
- main/sdk/subsdk 模块及其加载范围；
- 生成器、compiler、runtime ABI 和 profile 版本；
- guest 地址偏移策略；
- 必需的 HLE 服务和特殊资源；
- shader、字体、movie、存档和输入事实；
- 当前已证实、排除、未定和撤回的结论。

## 从当前 nxnative 迁移到目标架构

不要求一次重写。按以下顺序收口：

### 阶段 A：标记边界

- 找出通用 runtime 中所有 AAi/AA123/Cuphead 特判；
- 为每个特判写出 title、build、来源和不可推广边界；
- 将临时环境变量分为诊断开关、兼容开关和性能开关；
- 给每个 game library 记录 ABI、profile hash 和 patch hash。

### 阶段 B：建立扫描和报告

自动生成：

- C/C++ 声明与实现差异；
- HLE/SVC/IPC 调用清单；
- guest memory 和固定地址请求；
- shader program、VS/FS IO、binding 和 texture 使用；
- 未支持指令、未解析函数和 dummy/fallback 计数。

### 阶段 C：把实验变成契约测试

已经验证的 `QueryMemory`、物理内存、对象代际、纹理上传、shader IO、command list 和 present 经验，分别变成
最小测试。测试不应依赖完整游戏才能运行。

### 阶段 D：抽出公共图形前端

NVN 对象、资源生命周期、shader reflection、upload 和 render-pass 语义先独立于 Vulkan/Metal。平台 backend 只
实现能力差异和 handle 转换。

### 阶段 E：恢复性能优化

正确性基线稳定后，再启用异步 replay、image reuse、upload dedup、pipeline 并行、frame generation 和动态分辨率。
每项优化保留关闭路径和固定场景回归。

## 哪些东西最值得优先建设

按投入产出比排序：

1. profile schema 和构建 manifest；
2. C/C++ ABI/HLE 缺口扫描器；
3. game library 稳定加载接口；
4. guest memory/resource ledger；
5. shader VS/FS IO 与 descriptor 校验；
6. Mac/Android 结构化 draw trace；
7. 可恢复的生成/编译缓存；
8. 固定输入路线和截图回归；
9. 最后才是异步图形和设备特化优化。

## 复用边界

### 高复用

- ARM64 lifter 和代码生成器；
- NSO/ExeFS 解析与重定位；
- game library ABI；
- HLE 框架和公共服务；
- NVN 图形前端和 shader translator；
- Android/Mac 平台骨架；
- 构建缓存、日志和测试工具。

### 中等复用

- 内存容量和地址空间策略；
- movie、字体、音频和输入服务；
- shader 优化和上传策略；
- 设备驱动 workaround。

### 低复用

- 固定地址；
- 游戏 patch；
- shader hash 到用途的映射；
- 资源路径和版本号；
- 存档结构和游戏逻辑特例。

## 成功标准

目标架构不是“第二个游戏也能启动”这么简单，而是：

- 第二个游戏不需要复制第一套 runtime；
- 新缺口能由扫描报告定位到明确层；
- 游戏特化修复能在 profile 中独立回滚；
- Mac 与 Android 使用同一套公共图形事实格式做差分；
- 生成和编译可以缓存、恢复并追溯；
- 性能优化不会破坏正确性基线；
- 手册中的经验能对应到代码、测试或可执行工具。

本章描述的是未来目标，不代表当前 nxnative 已经完成这些分层。当前实现和实验状态仍以各游戏 worktree、
`06-case-studies.md`、`13-milestone-map.md` 和对应 profile 为准。

如果未来希望服务原生游戏开发和跨平台 QA，还应结合 [23-value-to-game-development.md](23-value-to-game-development.md)，
把 Contract IR、resource ledger、shader build graph 和 deterministic replay 做成独立于静态重编译器的公共工具。
