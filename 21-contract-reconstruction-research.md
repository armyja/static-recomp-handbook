# 21 — 契约重建研究方向

来源：[《主机游戏图形 API 移植中的契约重建问题——以〈异度神剑 3〉的渲染适配为例》](https://blog.armyja-online.uk/posts/xc3-graphics-api-contract-reconstruction/)

状态：公开文章的可迁移内容整理；XC3 的具体数量、地址、shader key 和当前阻塞不作为通用事实。

## 这篇文章为什么仍然有价值

它提供的不是某个游戏的修复答案，而是一个适合长期架构建设的问题定义：

> 图形移植的核心不是逐条翻译 API 调用，而是把原主机由离线工具链、固定硬件和驱动隐含保证的契约，在宿主环境中重新显式化并验证。

这补足了手册中 runtime contract 和 graphics contract 之间的桥梁。静态重编译能保证 guest CPU 指令语义接近原程序，
但不会自动带走 CPU 命令流、shader 变体键、资源元数据、附件格式、同步和驱动保证。

## 应保留的通用洞见

### 1. 契约不只在 shader 里

一个 draw 的完整事实至少来自四处：

```text
CPU command stream
  + shader stage interface
  + resource/metadata tables
  + host API and driver capabilities
  = executable graphics contract
```

因此 shader 反编译正确，不代表 draw 正确。后续图形 trace 应把同一 draw 的以下对象关联起来：program/VS/FS/CS、
vertex/index layout 和 bytes、UBO/SSBO/descriptor、sampler/texture view、attachment/render pass、blend/depth/raster、
resource incarnation/dirty/upload，以及 submit/wait/acquire/present 顺序。

### 2. 缺口要分三类

| 类型 | 典型问题 | 首选证据 | 修复方向 |
|---|---|---|---|
| 参数值错误 | 槽位数、附件数、stride、容量、格式 key | 配置来源、调用参数、反汇编 | 修正 profile/解析规则 |
| 类型/接口契约缺失 | uint/float 输出、VS/FS location、binding、layout | reflection、pipeline create、数值读回 | 补显式契约和校验 |
| 功能实现缺失 | GS、TF、copy、同步、资源生命周期空壳 | 同 draw 生产/消费链和副作用 | 实现、选择性替代或明确降级 |

参数问题不应重写函数，接口问题不应靠扩大内存，空实现问题也不应仅靠关闭验证来掩盖。

### 3. 产物数量不是正确性指标

shader key 数量、pipeline 数量、成功生成文件数和编译时间都只是成本或覆盖指标，不能证明附件格式、shader 输出类型、
binding、GS/TF/compute 生产消费关系或最终像素数值正确。进度应拆成：产物可生成、管线可创建、合成 draw 可执行、
固定场景像素通过、长时间回归通过。

### 4. 用约束和等价类降低组合爆炸

不要逐个穷举所有 shader × attachment × binding 组合。先从 reflection、格式规则、编译器和 pipeline validator 得到
约束，再把行为相同或契约相同的候选聚类，每个等价类只选代表做宿主确认。

编译器/验证器可以排除非法组合，但不能单独证明数值语义正确；视觉模型可以筛查灾难性帧，不能取代 pixel readback、
数值比较或资源快照。

### 5. 契约层精确，实现层可以替换

契约必须准确：输出类型、附件格式、binding、同步和可观察副作用不能随意改变。但内部实现未必必须复刻原硬件，
例如某些 geometry stage 可用 compute 替代，某些反馈缓冲可用显式 ping-pong 资源替代，某些绑定布局可映射到宿主
descriptor 体系。是否替代必须由同 draw 的生产/消费证据决定。

## 值得继续深挖的架构课题

### A. Graphics Contract IR

建立一个与 Vulkan/Metal 无关的中间表示，描述 program 和 draw 的完整契约：

```text
ProgramContract
  stages: VS/FS/GS/CS
  io: location/type/component/interpolation
  bindings: set/slot/type/visibility
  attachments: format/samples/load/store
  state: blend/depth/stencil/raster
  resources: image/buffer/incarnation/dirty range
  ordering: pass/submit/wait/present edges
```

Metal 和 Vulkan backend 都从这份 IR 生成各自对象。这样 VS/FS 不匹配会在公共层被发现，而不是等某个平台静默画错。

### B. Contract ledger 与事实来源

每条事实记录 `fact_id/title_id/build_id/program/draw/value/source/confidence/last_verified/regression`。来源可以是反汇编、
CPU trace、shader reflection、资源 dump、Mac 对照或宿主读回。推断值和已证实值分开，事实改变时保留历史。

### C. Oracle 分层

把验证器拆成四级：结构 oracle（格式、类型、binding、IO）、数值 oracle（UBO、texture、buffer、pixel）、时序 oracle
（submit、同步、资源可见性、帧生命周期）、视觉 oracle（黑屏、白屏、文字、布局和特效筛查）。高层 oracle 不能替代
低层 oracle。

### D. 检查点加确定性重放

对于启动慢、设备反馈稀缺或竞态敏感的游戏，优先实现“帧边界检查点 + 固定输入重放”，而不是立即追求任意时刻的
完整 save state。检查点至少绑定 guest memory、逻辑线程边界、资源事实、shader/pipeline cache 和输入序列。

### E. 能力成熟度 L0–L5

| 等级 | 含义 |
|---|---|
| L0 | 尚未识别或仅有猜测 |
| L1 | 静态清单和调用范围完成 |
| L2 | 离线候选和结构约束完成 |
| L3 | 合成测试/管线验证通过 |
| L4 | 真实游戏 draw 或场景通过 |
| L5 | 数值/像素回归和长时间运行通过 |

这比“实现了多少 API”更能显示真实进展，也能防止把标题画面出帧误认为图形系统完成。

### F. 游戏复杂度分类器

新游戏接入前，可以先按 CPU 特化程度、shader 变体规模、geometry/transform feedback/compute 使用、非标准 render
target、资源生命周期、引擎跨平台抽象和可获得参照系估算风险。这个分类只用于排序，不断言某类游戏一定容易。

## 对 nxnative 的直接转化

文章最值得转成代码的不是某个 XC3 特判，而是：

1. 在公共图形层引入 `ProgramContract`/`DrawContract` 数据结构；
2. 把 shader、纹理、attachment、同步和 present 事实写入统一 ledger；
3. 将结构、数值、时序、视觉验证器分层；
4. 将 AAi 当前实验结果映射到 L0–L5 和证据等级。

这四项完成后，AA123、AAI、Cuphead 或其他游戏可以共享诊断工具，即使它们的 profile 和 shader 仍然不同。

## 不应直接搬入通用层的内容

- XC3 的具体 shader 数量、地址、槽位和附件格式；
- 尚未取得同 draw 生产/消费证据的 TF/GS 因果结论；
- 只在某个平台观察到的驱动行为；
- 文章中对其他项目的概括，若没有对应公开源码或文档证据。

这些内容应留在 XC3 profile、研究文章或候选事实登记中，不能变成 nxnative 的默认契约。
