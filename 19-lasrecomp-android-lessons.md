# 19 — LASRecomp Android：从成熟项目提炼的可复用架构

核对日期：2026-10-24

本章分析公开的 [LASRecomp](https://github.com/peiikai/LASRecomp) 与
[LASRecomp-Android-Plus](https://github.com/Nycolazs/LASRecomp-Android-Plus)。目标是提炼静态重编译的工程方法，
不是复制游戏代码、地址表或 Android 实现。

## 先看结论

Android fork 的工作量确实很大，但它建立在上游已经完成的“游戏逆向 + 生成器 + 通用 runtime”之上。两边共同基线
之后的公开历史可以粗略看成：上游约 87 个提交、43 个文件和 3,086 行新增；Android 线约 182 个提交、154 个文件和
30,085 行新增。后一个数字包含合并的上游提交、自动生成的性能资料、第三方依赖、文档和脚本，不能当成纯手写 Android
代码量。

更准确的分工是：

| 层 | 上游主要解决 | Android fork 主要解决 |
|---|---|---|
| 游戏特化 | Switch ARM64 反汇编、build ID、地址表、patch、shader 和资源规则 | 复用上游 profile，并适配版本选择和用户导入 |
| 通用 runtime | CPU/ABI、Horizon HLE、内存、线程、文件、输入、音频、电影、NVN | 补 Android 生命周期、线程和存储边界 |
| 图形 | Metal/Vulkan 资源模型、shader 翻译、NVN 语义 | 移动 Vulkan、Adreno/Turnip、帧生成、缓存和性能 |
| 产品外壳 | 桌面启动器和资源目录 | APK、JNI、SAF、触屏、后台构建、断点续编译 |

因此，移植一个新游戏时最应该复用的是分层和验证流程，而不是把另一个游戏的地址、shader 或对象布局搬过来。

## 静态重编译的四层模型

```text
用户自己的 XCI/NSP + keys
          │ 解包、版本和 build ID 校验
          ▼
游戏特化 profile + 生成器
          │ 反汇编、地址重定位、patch、C/ARM64 生成
          ▼
lib<game>.so / game library
          │ 稳定 ABI 接入
          ▼
通用 runtime
  CPU/ABI · HLE · guest memory · FS · HID · audio/movie
  NVN command/object model · shader translation · resource lifetime
          │
          ▼
平台层：macOS/Metal、Windows/Linux/Vulkan、Android/JNI/Surface
```

这个模型有一个重要边界：游戏代码是静态生成的，但系统服务和图形 API 仍由 runtime 在运行时提供。静态重编译并不
等于“所有东西都离线完成”，而是把最昂贵的 guest CPU 执行提前转换，把不可避免的平台行为集中到可测试的边界。

## Android fork 最值得借鉴的实现策略

### 1. APK 只带工具和 runtime，不带游戏

公开 APK 通过用户选择的 `.xci/.nsp`、`prod.keys` 或已解包目录完成 setup。游戏资源、生成的 game library 和
缓存位于应用数据目录，公共 APK 可用检查脚本拒绝包含游戏代码的构建。

这对应一个通用的三期产品边界：

```text
公共 APK = runtime + 解包器 + 生成器/编译器 + 资源模板
用户数据 = 游戏镜像 + keys + 更新包 + 存档
生成产物 = 独立 game library + build id + cache manifest
```

nxnative 以后也应把“游戏本体不进 APK”和“生成后的代码是否随包分发”作为两个独立开关，而不是混在构建脚本里。

### 2. 把 on-device build 当成可恢复的构建系统

Android fork 在手机上运行生成器、Zig/Clang 和 linker；构建过程有进度、前台服务、wake lock、并行度限制和完成
对象缓存。进程被杀或设备重启后，可以从已完成对象继续，而不是从头再来。

可迁移的不变量：

- 每个生成/编译单元有稳定输入 hash；
- build ID、generator 版本、compiler 版本和 flags 进入 manifest；
- 中间结果写入临时名，完成后原子发布；
- 取消、进程死亡和磁盘不足都留下可诊断状态；
- 生成器和编译器可在宿主机用同一输入做 byte-identical 或语义等价检查。

### 3. 先定义 Android 地址重定位，而不是临时找固定地址

Android 进程的库、zygote 和 heap 会占用地址空间，不能假设 Switch guest 地址能原样映射。成熟做法是把
`GUEST_SHIFT` 作为生成器、patch 工具、地址表和 runtime 共同认识的正式参数：

```text
host_address = guest_address + GUEST_SHIFT
```

这个机制必须在最小合成 guest、真实模块和异常路径分别验证；不能只在某几个跳板上加偏移。

### 4. 移动 Vulkan 优化必须建立在正确性基线之上

Android fork 的性能提交包含 shader 预热、pipeline cache、帧生成、动态分辨率、预旋转 swapchain、UBWC/LRZ 和
Adreno 驱动处理。但这些优化都应该有固定场景、GPU/CPU 时间、温度、内存和截图对照。

对 nxnative 的直接规则是：

1. 先让普通配置稳定完成标题、菜单、电影、输入和保存；
2. 再启用异步提交、upload ring、pipeline 并行和 frame generation；
3. 任一性能改动都必须有关闭开关和回归结果；
4. “更快地显示错误画面”不算性能成功。

## 上游与 fork 的工作量如何估算

不要用提交数直接比较难度。建议拆成四个预算：

| 预算 | 主要问题 | 是否能跨游戏复用 |
|---|---|---|
| 逆向预算 | build ID、模块、函数、shader、patch、资源格式 | 低到中；工具可复用，结论通常特化 |
| runtime 预算 | ABI、HLE、内存、线程、服务和 NVN 对象 | 中到高；契约可复用，边界要验证 |
| 平台预算 | Android/Metal/Vulkan/窗口/存储/输入 | 高；平台层通常可复用 |
| 性能预算 | shader、同步、缓存、分辨率、设备调优 | 中；方法可复用，参数依设备和游戏 |

上游最昂贵的是第一、二项：它把一个具体游戏变成了可执行的静态重编译对象。Android fork 最昂贵的是第三、四项：
它把已有对象变成可安装、可导入、可在移动 GPU 上长时间运行的产品。

## 对 nxnative 的落地清单

每个新游戏至少建立以下目录或记录：

```text
games/<title-id>/
  profile.toml              # build、版本、内存和服务参数
  address-map.tsv           # guest/host、来源和验证状态
  patch-map.tsv             # 原始 bytes、替换 bytes、反汇编理由
  shader-map.tsv            # VS/FS/CS pair、IO、binding、用途
  resource-facts.tsv        # texture、font、movie、romfs、save
  device-matrix.tsv         # Mac/Android/GPU/API/页大小/结果
  regression-routes.md      # 固定输入、截图点和存档前置
```

通用 runtime 只接受已经被 profile 描述的契约；无法证明跨游戏通用的修复留在 profile 或 adapter 中。

## 可通过经验明显加速的部分

- 用最小 guest、三角形和合成 HLE 先验证 loader/runtime/graphics，不拿真实游戏当第一台示波器；
- 先扫描 C/C++ 导出、结构体和函数表，再补实现，避免“C 已有、C++ 缺失”或反过来的盲区；
- 先建立 Mac/Android 同一 draw 的差分，而不是只看最终截图；
- 所有静默 dummy、缺 shader、缺 descriptor、空字体和被丢弃 command list 都在首次出现时记录；
- 将高扰动日志和低扰动计数器分开，竞态问题优先用离线 dump、计数和回放；
- 把“解包、生成、编译、链接、加载、首帧、输入、存档”作为独立验收门；
- 先复用成熟 runtime 的接口边界，再决定是否重写内部实现；
- 公开资料只复用许可证允许的代码，GPL/私有来源只抽象语义和测试不变量。

## 外部项目的证据边界

本章使用 LASRecomp 的公开 README、Android 构建文档、公开源码结构和发布说明。它证明了“该项目采用了哪些
架构和流程”，不自动证明这些流程适用于 AAi、nxnative 或任意 Android GPU。具体文件、commit、许可证和阅读范围
登记在 [10-source-register.md](10-source-register.md)。
