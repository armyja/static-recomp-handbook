# 04 — 平台差异：为什么 Mac 快、Android 难

## Apple/Metal

Mac/iOS 的优势不是“没有问题”，而是既有 host、Metal 对象模型和 shader 链已经承担了大量语义。常见问题会
更早表现为具体的 texture、attachment、shader input 或 thread stack 错误。

nxnative 的 Mac 经验包括：CPU-written linear texture、big-stack NVN entry、lower-left origin、stencil copy、
compute dispatch constants、same-pass feedback、render-pass segmentation 和 pipeline prewarm。

## Android/Vulkan

Android 额外引入：

- Bionic/linker、JNI/NDK 和 AArch64 线程边界；
- scoped storage、SAF、Surface/ANativeWindow 生命周期；
- Vulkan feature/extension、render pass、layout、semaphore 和 driver 差异；
- SPIR-V descriptor/binding 与 shader cache 分发；
- 不同 Adreno 驱动的格式、同步和性能行为。

所以安卓常见的现象是“层层解锁”：先修 loader/HLE 才暴露内存，再修内存才暴露 render target，最后才看到真正
的 shader、合成或游戏逻辑问题。

成熟 Android 静态重编译项目还会多出一条产品链：用户资料导入、解包、版本校验、手机端生成/编译、后台保活、断点
续编译、game library 缓存和触控输入。这些不属于 Vulkan 后端，应该单独验收。参考
[LASRecomp Android 的 on-device build 文档](https://github.com/Nycolazs/LASRecomp-Android-Plus/blob/main/docs/android-ondevice-build.md)：
它把生成器、编译器、链接器和应用服务拆开，并为失败恢复保留中间对象。

Android 的字体、驱动和系统资源也不能照搬桌面路径。语言代码正确不代表字体槽存在；应分别记录：游戏语言、字体
来源、字体格式、解析结果和实际 glyph 覆盖范围。系统 CJK 字体路径、CFF/TrueType 兼容性以及用户导入字体都应在
设备矩阵中单独测试。

## 统一验证方法

Mac 是黄金参照，不是 Android 的实现替代品。对同一游戏状态采集同一 draw 的有效输入，再比较 backend 结果。
设备差异实验必须固定 APK、patch、资源、存档、shader cache 和输入路线，只改变驱动/平台。

## 性能原则

静态重编译的性能上限来自原生 guest CPU 执行、离线 shader、低开销 host 和正确的资源生命周期。先消除错误和
重复工作，再优化异步、pipeline cache、render scale、上传和分段提交；否则高性能只是更快地显示错误画面。
