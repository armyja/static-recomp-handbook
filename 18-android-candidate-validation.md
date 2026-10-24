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
| 进入游戏 | 未执行；缺少目标游戏本体和 `prod.keys` |

这次验证只证明 Android shell、APK 安装、ARM64 加载和初始 Vulkan 路径成立；不能证明当前设备已经能运行
游戏，也不能把其他 Switch 游戏镜像代替梦见岛。

## 本机资料盘点

当前已找到的 Switch 镜像：

- `aa456.xci`：Apollo Justice 456 Trilogy；不是本候选需要的游戏。
- `xc3.xci`：Xenoblade Chronicles 3；不是本候选需要的游戏。
- AA123、AAI 和 Cuphead 的本地资料；都不是梦见岛。

未找到：梦见岛 v1.0.0 的 `.xci/.nsp`、对应 ExeFS/RomFS 或可用于该游戏的 `prod.keys`。`/Volumes/Untitled` 当前也
没有发现“Share to me”作为单独挂载卷。

## 可复用排障经验

1. 先安装公开 APK，验证 package、ABI、Activity、Surface/Vulkan 和初始日志；这一步不需要游戏本体。
2. 再核对候选项目要求的 title/version/更新包，不要把“同为 Switch”当作兼容。
3. 最后才导入用户自己的合法游戏资料并开始手机端重编译；首次构建的空间、温度和时间必须记录。
4. 如果缺本体，结论写成“shell 验证完成、游戏验证阻塞”，不要改用不匹配的镜像试跑。
