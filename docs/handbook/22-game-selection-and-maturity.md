# 22 — 游戏选型与架构成熟度阶梯

状态：目标方法，具体游戏的可用性和版本仍需按公开仓库、许可证和本地资料单独核对。

## 核心原则

判断静态重编译架构是否“做厚”，不能只看已经跑通了多少款游戏。应该看覆盖了多少种不同的契约类别：

```text
游戏数量 ≠ 能力覆盖
能力覆盖 + 合成测试 + 跨平台回归 = 架构成熟度
```

一个只使用普通 vertex/fragment、单一 render target 的游戏，不能证明 NVN frontend 已经支持 Geometry Shader、
Transform Feedback、整数附件、复杂资源生命周期或多阶段 compute。

## 推荐的能力阶梯

### L0：合成图形契约测试

不依赖完整游戏，先验证：

- guest buffer/texture/image/view；
- vertex/index 和 uniform；
- 普通 vertex/fragment draw；
- blend、depth/stencil、viewport/scissor；
- render target、copy、resolve、acquire/present；
- compute 写入后被 graphics 读取；
- shader VS/FS IO 和 descriptor 校验。

这是所有真实游戏之前的“图形单元测试层”。

### L1：简单 2D 或 Unity 游戏

代表特征是 sprite、UI、字体、普通纹理和简单粒子，重点验证：

- 普通纹理采样和 swizzle；
- alpha/blend；
- 动态字体图集；
- 小型 command buffer；
- 输入、窗口和 present；
- 资源上传和销毁。

这一级适合快速发现对象模型和资源生命周期的结构性错误，但不能证明复杂 3D 图形完整。

### L2：中等 3D、已有成熟参考实现的游戏

代表特征是完整 3D 场景、电影、存档、多个 render pass 和跨平台运行。重点验证：

- 静态重编译 generator 与 game-library ABI；
- Horizon runtime 基本服务；
- 3D camera、depth、shadow 和后处理；
- movie/audio/font 资源链；
- Mac/Android 或 Metal/Vulkan 差分；
- 构建缓存和长时间运行。

LASRecomp/《织梦岛》适合作为这一层的公开架构参考，而不是把它的游戏特化参数直接搬入其他项目。

### L3：复杂 NVN/Vulkan 游戏

代表特征是 shader variant 多、移动 GPU 敏感、资源和 pass 关系复杂。重点验证：

- program key 到 VS/FS/CS 的稳定映射；
- descriptor/binding 和 shader reflection；
- pipeline cache、shader 预热和异步编译；
- image reuse、upload dedup 和资源 incarnation；
- 多帧 in-flight、submit/wait/present；
- Android 驱动能力和性能回归。

Super Mario Wonder 这类公开 NVN→Vulkan/MoltenVK 项目适合作为该层的参考样本；其代码和许可证仍需逐文件核对。

### L4：深度硬件特化的最终压力测试

代表特征是大型自研引擎、非标准格式和多个强耦合图形阶段：

- Geometry Shader；
- Transform Feedback；
- 整数或打包 render target；
- G-buffer、光照、阴影、植被、粒子和后处理；
- 多阶段 compute 生产/消费；
- 大型世界 streaming 和复杂内存生命周期。

XC3 属于这一层。它应该作为架构成熟后的压力测试，而不是用来发现最基础的 TextureBuilder、present 或普通
blend 错误。

## 推荐的最小验证组合

如果资源有限，建议覆盖以下 4–6 个层次，而不是盲目增加游戏数量：

| 顺序 | 样本 | 主要目的 |
|---|---|---|
| 0 | 合成测试 | 验证公共图形契约，不依赖游戏数据 |
| 1 | Cuphead 一类 2D/Unity 项目 | 普通纹理、UI、字体、blend、输入 |
| 2 | 《织梦岛》/LASRecomp | 完整静态重编译和跨平台 runtime 基线 |
| 3 | AA123/AAI | Unity/IL2CPP、动态 UI、movie、资源生命周期 |
| 4 | Super Mario Wonder | 复杂 NVN→Vulkan、shader 和移动 GPU |
| 5 | XC3 | GS/TF、整数 RT、大型自研引擎和强耦合管线 |

这里的游戏是能力样本，不表示应复制它们的地址、shader、资产或私有资料。

## 什么时候可以说公共图形前端“足够厚”

至少需要同时满足：

1. 普通 texture/buffer/render pass/present 在合成测试中稳定；
2. 每种关键 shader stage 至少有一个真实游戏和一个合成测试案例；
3. 普通、压缩、整数、depth/stencil 和多附件格式都有明确事实和回归；
4. compute、GS、TF 或其有证据的替代路径有生产/消费链测试；
5. Mac 与 Android 能使用统一的 draw/resource trace 做差分；
6. 新游戏的普通启动问题主要新增 profile，而不是复制或重写 NVN frontend；
7. 连续两个新游戏接入时，公共 runtime 的改动能被契约测试覆盖；
8. 异步、image reuse、upload dedup 和性能优化都有关闭路径，不会破坏正确性基线。

## 游戏选择的反模式

- 连续选择三个只使用普通 2D draw 的游戏，然后宣称图形前端通用；
- 只看能否进入标题画面，不测试电影、菜单、存档、长时间场景和资源流式加载；
- 把 shader/pipeline 数量当成契约覆盖率；
- 直接从最复杂游戏开始，导致基础 runtime 缺口和特化图形缺口同时出现；
- 为了让单个游戏通过，把地址、容量或 shader hash 写进公共层；
- 只在一个 GPU/驱动上验证异步路径，然后把它当作平台无关语义。

## 对当前路线的意义

当前 nxnative 不需要暂停所有目标去移植一长串游戏。更有效的方式是：

1. 先把 AAi/AA123 当前问题抽成合成契约测试；
2. 用已有 Cuphead、LASRecomp 和 Super Mario Wonder 公开资料校准能力矩阵；
3. 将 AA123/AAI 作为中等复杂度的 runtime/资源样本；
4. 把 XC3 的工作放在 Contract IR、事实 ledger 和 oracle 分层之后；
5. 每完成一个能力类别，就把测试和 profile schema 回写公共仓库。

这样每个游戏都贡献一类可复用能力，而不是只贡献一份不可迁移的修补记录。
