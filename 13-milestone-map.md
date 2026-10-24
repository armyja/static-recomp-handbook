# 关键突破复盘：从黑屏到可玩的路径

本章把本项目已经留下的经验抽象成“为什么这一步有效”，而不是只列 commit。数字和地址只属于对应游戏/构建，不能当作通用常量。

## Android 侧

| 阶段 | 现象 | 真正推进点 | 可迁移经验 |
|---|---|---|---|
| 早期 | 进程启动后黑屏/崩溃 | 先补 loader、HLE、固定 guest 地址和最小 Vulkan 出帧 | 先证明“能加载、能 present、能画三角形”，再接游戏 |
| 首次出色块 | 画面仍不完整 | 用固定色/最小 draw 把 present、render pass、目标图像链路切开 | 纯色是定位 draw/present 边界的证据，不是最终修复 |
| 出现标题/部分 UI | 部分资源缺失 | 补齐 UBO/常量上传去重的内容语义，而不是只按源地址缓存 | 动态 scratch 地址可能复用；去重 key 必须覆盖内容或版本 |
| 白条/文字缺失 | 背景和部分页面正常 | 通过 Mac 参照、逐 draw、shader/program/纹理链路缩小到特定资源路径 | “能显示一页”只能证明那一页的契约，不能证明全局图形正确 |
| 平台差异显现 | Mac 正常、Android 异常 | 对照 Vulkan 能力、render pass、image 生命周期、shader IO、同步与驱动 | 先找首个跨平台分叉，避免把平台差异归因到游戏资源 |
| 继续推进 | 低层问题与游戏特例交织 | 将通用 runtime 修复、profile 参数和实验结论分开归档 | 下一款游戏只复制通用层和流程，不复制临时地址/开关 |

## Mac 侧

Mac 的推进通常更快，不是因为静态重编译天然简单，而是 Metal 路径、开发工具和已有宿主边界较稳定；同时已有的 shader/资源分析链更早暴露了契约错误。历史案例包括：模块加载与 unwind、栈布局、CPU 写纹理、R8/捕获、顶点 ABI、stencil、dispatch 常量、坐标原点、分段和预热。

从这些案例提炼出的顺序是：

1. 先让重写后的模块稳定启动；
2. 用离线 shader 扫描和配对验证减少运行时猜测；
3. 让 Metal 的严格 pipeline 校验尽早暴露 VS/FS 不匹配；
4. 用 target snapshot 与 shader 输入隔离“资源没写”与“采样错”；
5. 最后处理性能、预热和帧率策略。

## 为什么 Android 更容易慢

Android 同时增加了 JNI/Surface/ANativeWindow、Bionic/linker、Vulkan capability/layout/sync、驱动差异、Scoped Storage 和更敏感的线程时序。一个 Mac 上被宿主默认值掩盖的契约，在 Android 上可能表现为：静默 dummy、空白 image、非法 feature chain、render pass 不兼容、设备差异或竞态。

因此“Mac 已经能跑”应被当作参照实现和事实来源，而不是 Android 的完成证明；“Android 出了一点颜色”也只能说明一条路径成立。

## 复盘格式

每个新突破都补四句话：

1. 之前的最小可复现症状是什么？
2. 哪个不变量/契约被证明不成立？
3. 修复为什么只影响该层，而不是把游戏特例塞进 runtime？
4. 下一款游戏如何用一个最小检查复用这个经验？
