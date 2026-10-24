# 03 — Graphics 契约：NVN 到 Metal/Vulkan

图形移植不只是 API 逐条翻译，而是把 CPU 命令流、shader stage IO、资源元数据、管线状态、同步和宿主能力共同
组成的隐含契约显式化。完整的契约重建研究和未来工具方向见
[21-contract-reconstruction-research.md](21-contract-reconstruction-research.md)。

## 图形链路分层

```text
NVN API object
→ guest handle / pool backing
→ recorded command snapshot
→ replay state
→ translated shader + descriptor layout
→ backend image/buffer/view
→ render pass / barrier
→ composite / window texture
→ acquire/present
```

任何一层的“dummy”“空 handle”“旧 snapshot”都可能静默地产生黑、白或透明画面。

## 先确认 draw 是否存在

按以下顺序查：

1. guest 是否发出 draw/dispatch；
2. program 是否为非零、VS/FS 是否都存在；
3. vertex/index/UBO 是否有效；
4. target 是否有 host backing；
5. descriptor 是否绑定真实 image/view/sampler；
6. shader 是否产生片元；
7. target 是否被后续 pass 合成到 present source。

“no program”不能自动解释黑屏：可能是合法的空绑定，也可能是宿主丢失了 guest state。

## Shader 迁移

离线翻译要记录：原始 shader hash、stage、control/code、翻译器版本、binding reservation、SPIR-V/Metal 输出 hash。
必须验证 VS outputs 与 FS inputs 的 location、component、类型和插值语义；不能只验证 shader 编译成功。

## 纹理与通道

逐个资源记录：NVN format、target、levels/layers、stride/layout、pool offset、view swizzle、host format、
alpha 语义、是否 CPU 写入、是否 render target、是否可复用。R8、BC、capture texture 和 render target view
不能共享同一套全局“聪明规则”。

## 对象生命周期

对象 key 至少要覆盖 storage identity、描述、format、view/swizzle、代际和 dirty/upload 状态。对象被销毁、pool
重注册或 guest 地址复用时，旧 image 不能以“看起来相同”的 key 复活。异步 replay 下必须让 GPU 完成后再退休资源。

## Present 和同步

每个 swapchain image 需要独立的 acquire/submit/present 生命周期；不能只用一个全局 semaphore 或假定窗口 image
始终对应 guest 当前 render target。动态渲染、传统 render pass、sync2、timeline semaphore 等能力要根据 API 版本
和扩展查询，不根据 `vkGetDeviceProcAddr` 返回非空就判定支持。

## 诊断的正确用法

- 固定颜色：验证 shader/目标是否真的产生片元；不是修复。
- magenta dummy：验证是否走 fallback；不是证明真实资源错。
- snapshot/readback：判断写入发生在哪个 target；注意 snapshot 时机。
- per-draw fingerprint：比较 Mac/Android 有效输入；优先 hash/摘要，避免大量日志改变时序。
