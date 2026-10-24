# 07 — 外部项目解读

本章只记录公开仓库中已经核对过的设计。代码是否能直接复制，必须另看许可证和依赖；“同样的文件名”不代表
“同样的契约”。

## d2r-mobile

仓库：[jhaizhou-ops/d2r-mobile](https://github.com/jhaizhou-ops/d2r-mobile)

它的 README 明确把 host、Android shell、touch overlay、Vulkan presentation 和离线 shader pack 分开，并报告
Android ARM64 真机结果。值得借鉴的不是把它的游戏参数搬过来，而是：

- Android 只分发不含游戏本体的 shell，运行时导入资源；
- shader 在电脑上预翻译并随 import pack 分发，减少首场景 miss；
- Android 与 Apple 共享 host，平台差异集中在前端和图形后端；
- 有 host/gfx 单测、重写等价检查、脚本化输入回归和设备 smoke test；
- Vulkan presentation、touch 和性能工作有独立文档，而不是混在游戏 profile 中。

对应 README 的 Android 章节和 `docs/ANDROID.md`、`docs/ANDROID_COLLABORATION.md`。可复用的是组织方式和测试门槛，
不能直接复制其游戏专用 replay、地址和资源规则。

## Eden / Yuzu

参考：[Eden DesignOverview](https://github.com/comex/eden/blob/master/docs/DesignOverview.md)

Eden 的设计文档明确说明：服务经常以 HLE 方式实现，目标是对程序提供足够准确的语义，而不是模拟每个物理设备；
其 Android 前端、shader recompiler 和 Vulkan backend 分层也值得参考。对 nxnative 最有用的是：

- 把服务语义、CPU、视频和前端隔离；
- 将 memory/page-table/backing/resource-limit 作为可测试的账本；
- 把 shader translation 和 graphics backend 分开；
- 用 HLE 返回“合理的空状态”，而不是任意成功/零值。

Eden/Yuzu 代码许可证和依赖必须逐文件核对；GPL 代码不能直接移植进 MIT/其他许可证项目。

## LASRecomp

仓库：[peiikai/LASRecomp](https://github.com/peiikai/LASRecomp)

它展示了同一游戏的 Windows/Linux Vulkan 与 macOS Metal 分层，以及 Linux ARM64 的明确“编译但未真机验证”状态。
可借鉴：平台能力矩阵、启动时准备本地游戏文件、Vulkan 性能回归、`make smoketest` 一类验收门槛。不能把
“Linux ARM64 可编译”误写成“Android 已支持”。

Android fork：[Nycolazs/LASRecomp-Android-Plus](https://github.com/Nycolazs/LASRecomp-Android-Plus)

这是本手册目前最适合研究“如何把静态重编译交付到 Android”的公开案例。它的公开 README 和
[on-device build 文档](https://github.com/Nycolazs/LASRecomp-Android-Plus/blob/main/docs/android-ondevice-build.md)
显示了完整链路：用户提供游戏文件和 keys，应用解包并校验版本，手机运行生成器和 AArch64 编译器，最后加载单独的
game library。它还把 Android 前端、触控、GPU 驱动选择、Vulkan 性能、shader/pipeline cache 和后台构建拆成不同
边界。

可借鉴：

- 公共 APK 检查，保证不含游戏代码和游戏资料；
- `game build id + generator/compiler + flags` 组成可失效的构建缓存 key；
- 中断构建可恢复，构建产物原子发布；
- Android 地址偏移由生成器、patch 和 runtime 共同管理；
- 移动 GPU 优化以固定场景和温度/帧时间测量为准；
- 触摸、解包、字体、渲染和输入日志有各自的诊断范围。

不可直接搬用：Link's Awakening 的地址表、shader/资源事实、游戏 patch、存档结构以及它的 Android 专属假设。该
fork 的代码可以作为公开实现研究，但每个文件仍需按其许可证和依赖逐项核对。更完整的分层和工作量拆解见
[19-lasrecomp-android-lessons.md](19-lasrecomp-android-lessons.md)。

## SuperMarioWonderRecomp

仓库：[BelmanteGu/SuperMarioWonderRecomp](https://github.com/belmanteGu/SuperMarioWonderRecomp)

这是与 nxnative 最接近的公开 NVN→Vulkan 静态重编译参考之一。其文档把内容分成 recompiler、shared runtime、
`runtime/src/nvn`、每游戏 glue、Android build 和 `docs/nvn` 调查记录。特别值得吸收的是：

- `docs/nvn/ANDROID-PORT.md` 先写“哪些可继承、哪些仍是风险”，没有把桌面 MoltenVK 成功误当成 Android 真机验证；
- guest 指针、固定地址、heap/stack/thunk 区域在 runtime 文档中集中定义；
- Vulkan 资源通过 per-submit upload ring 进入 GPU，明确记录了它和 external-memory-host 的取舍；
- Android manifest、最低 Vulkan/API 要求和构建输出单独验收；
- `docs/nvn/DEBUG.md` 按“症状、根因、修复、开关”积累图形问题，并记录错误假设和新诊断工具。

这直接对应 nxnative 的三个教训：不要把 upload dedup 当成无害优化；不要把目标/窗口 image 混成一个全局对象；
不要在没有 stage/target/descriptor 证据时凭截图猜 shader。该仓库的代码和文档仍须逐文件确认许可证，手册只引用
设计和公开事实，不复制游戏特化实现。

## Strato / Skyline

仓库：[strato-emu/strato](https://github.com/strato-emu/strato)

Strato README 明确说明它是 Android ARMv8 Switch emulator，许可证为 GPL-3.0，并说明其基础来自 Skyline、shader
compiler 源自 yuzu 的 fork。它适合作为 Android guest 边界、NCE、线程/TLS、内存映射、Vulkan capability 和移动
GPU 兼容性研究入口；不适合作为 nxnative MIT/自有代码的直接复制源。

使用规则：

1. 只记录接口语义、设计取舍和可独立重实现的不变量；
2. 需要复制代码时先停止，核对 GPL 兼容性和目标仓库的许可证；
3. 不把 emulator 的动态 CPU/系统模型直接套到静态重编译的 guest ABI；
4. 把 Skyline/Strato 的“Android 已处理过”当作候选契约来源，而不是 AAi 的证明。

## Atmosphère / libmesosphere

参考：[Atmosphère libmesosphere](https://github.com/Atmosphere-NX/Atmosphere/tree/master/libraries/libmesosphere)

`libmesosphere` 是 Horizon kernel functionality 的 C++ 实现，README 标注 GPLv2，并列出对 yuzu、Ryujinx 等项目的
特殊许可例外。它最适合查：address arbiter、thread/process 状态、SVC 返回语义、内核对象生命周期和内存布局。
除非许可证明确允许且项目审核通过，否则 nxnative 只采纳语义和测试向量，不复制实现。

## 本项目独立实践

本项目的长期实验记录展示了另一种重要经验：必须保留撤回、错误假设和自动评分器，否则同一“坏帧”集合被
误记后，后续二分会建立在假数据上。公开版不引用内部 worktree、会话或设备日志。

## 仍需继续核对

- Ryujinx / yuzu：SVC、address arbiter、page table、NVN shader reflection 和资源限制语义的具体 commit。
- Skyline 原始仓库：与 Strato 的继承关系、NCE 异常/TLS 代码和许可证边界。
- Wonder Recomp 的当前 LICENSE、具体 Vulkan runtime 文件和最新 Android 真机状态；GitHub 页面有时返回缓存/404，
  在未取得稳定源码快照前不记录为“可直接复用”。
