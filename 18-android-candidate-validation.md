# Android 公开候选验证：LAS Recomp

核对日期：2026-10-24

## 候选

[Nycolazs/LASRecomp-Android-Plus](https://github.com/Nycolazs/LASRecomp-Android-Plus) 是《塞尔达传说：梦见岛》
Switch 版的 ARM64 Android 静态重编译移植。公开 README 说明它提供不含游戏内容的 APK，运行时需要用户自己的
游戏文件；它支持 `.xci/.nsp` 或已解包的 ExeFS/RomFS，并需要 `prod.keys`。它的运行时包含 Android/Vulkan、
触摸输入和手机端构建流程。

## 本机验证

| 项目 | 结果 |
|---|---|
| 目标设备 | 当前唯一 ADB 设备 `PYB110` |
| Android | 17 |
| ABI | `arm64-v8a` |
| APK | `LASRecomp-Android-1.2.0.apk`，发布页 SHA256 校验通过 |
| 安装 | 成功 |
| 启动 | 成功进入 `Game Files` 页面，Vulkan 初始化日志正常 |
| 进入游戏 | 已进入标题画面并播放开场电影；触控摇杆、A/B 键可见 |

这次验证已经覆盖 Android shell、APK 安装、ARM64 加载、文件导入、手机端解包/重编译、Vulkan 出帧和游戏输入。
应用在设置完成后显示 `Game files ready`、`Nintendo Switch · v1.0.0`；虽然输入的是本地保存的 v1.0.1 XCI，
该候选的运行时使用其支持的基础游戏版本显示名。标题画面、开场电影和触控覆盖层均正常出现。

## 本机资料盘点

当前已找到的 Switch 镜像：

- `aa456.xci`：Apollo Justice 456 Trilogy；不是本候选需要的游戏。
- `xc3.xci`：Xenoblade Chronicles 3；不是本候选需要的游戏。
- AA123、AAI 和 Cuphead 的本地资料；都不是梦见岛。
- SMB `sharetome` 挂载中找到梦见岛 v1.0.1 和 v1.1.0；本次使用 v1.0.1。

本次把 v1.0.1 XCI 复制到 `/Volumes/Untitled/lasrecomp-link-awakening-v1.0.1/`，再通过 ADB 放入当前设备的
`Download` 目录；`prod.keys` 只作为运行时输入，没有进入仓库或文档内容。SMB 来源保持不变。

## 可复用排障经验

1. 先安装公开 APK，验证 package、ABI、Activity、Surface/Vulkan 和初始日志；这一步不需要游戏本体。
2. 再核对候选项目要求的 title/version/更新包，不要把“同为 Switch”当作兼容。
3. 最后才导入用户自己的合法游戏资料并开始手机端重编译；首次构建的空间、温度和时间必须记录。
4. 如果缺本体，结论写成“shell 验证完成、游戏验证阻塞”，不要改用不匹配的镜像试跑。

## 2026-10-24 真机结果

- 当前唯一设备：PYB110，Android 17，ARM64；本轮没有连接或操作其他手机。
- XCI 大小为约 6.31 GB；文件选择器最初不显示 `.keys`，复制为 `keys.txt` 后通过搜索选择，应用接受了同一份
  keys 内容。这个绕过只发生在设备临时目录，不是项目代码修复。
- 手机端重编译分为读取游戏代码和重新编译两个阶段，界面显示约 4 分钟完成；设备剩余空间约 104 GB，未遇到
  解密失败、bad keys、崩溃或 Vulkan 建设备错误。
- 标题画面显示《Link's Awakening》、`Press L + R` 和虚拟摇杆/A/B 控制；发送 L+R 后进入开场电影。
- 运行日志观察到 Vulkan 约 60 FPS、约 13 ms GPU、0 skipped draws；电影解码线程持续产出帧。此处只记录观测值，
  还没有把它当作完整流程性能结论。

## 当前边界

这证明公开候选在这台 Android 设备上能完成“用户资料 → 手机端静态重编译 → 标题/电影出帧”的链路；它不是
nxnative 的 AA123/AAI 迁移结果。下一步应分别记录：跳过开场电影进入存档、触控输入完整性、长时间稳定性、渲染
性能，以及更新包 v1.1.0 是否能按 README 的支持矩阵复现。游戏资料和密钥仍属于本机运行输入，不应提交到公开手册。
