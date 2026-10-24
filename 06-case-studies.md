# 06 — 本地案例：关键突破是如何发生的

## Android / AAi

### 从 139 到持续出帧

早期日志在 `present #1/#4` 后进入 guest allocator NULL。扩大 heap/alias 并没有直接解决它；真正有价值的是把
`MapPhysicalMemory`、`UnmapPhysicalMemory`、`SetHeapSize`、`QueryMemory` 和物理 backing 放到同一套账本中，随后
才逐渐暴露 render target、对象代际和上传问题。结论：容量实验只能改变边界，不能替代资源契约。

### 从黑屏到红色，再到标题主体

固定 fragment 输出红色证明 Vulkan 输出链完整；仿射 VS 证明原始 VS 的位置/常量路径有问题；最终标题主体恢复的
关键是按内容校验动态 UBO 上传，避免 Unity 在固定 scratch 地址重写数据后仍复用旧上传。结论：颜色测试是定位工具，
内容校验才是可泛化修复。

### 从白条到正常菜单

R8 强制通道映射让 UI 框出现，但不是全局修复。之后 Mac 对照、shader miss 补译和完整 shader cache 证明部分 UI
文字缺失来自 shader 产物不全；未选中菜单项仍出现白条时，问题又收敛到离屏目标/呈现新鲜度，而不是字体 atlas 本身。

### 输入和启动状态

xattr Linux namespace 错误阻止存档创建，造成启动流程看似卡死；修复后进入免责声明、语言菜单和双选项框。HID
receipt/latch 和 replay-thread 修复则解决了输入边沿被多个消费者抢读及闪烁。结论：游戏状态阻塞必须和图形阻塞分开。

### 当前未完项

开场字幕在 Mac 可见、Android 进入独立 1920×1080 中间目标后不可见；最新证据已排除 BC7、movie Decoder、缺 shader
和几何 compute，集中到动态 `c3` 颜色数据、离屏 target 和合成。下一步必须做 Mac/Android 同 draw 的 UBO 写入与 target
读回，而不是再次全局改 R8、blend 或 present。

## Mac / Apple

Mac 侧的通用经验包括：

- IL2CPP 需要真实 module layout、异常 unwind、地址空间和线程暂停语义；
- 小 guest stack 调用复杂文件/NVN/Metal host hook 会溢出，必须使用大 host stack；
- CPU-written linear texture 必须与 host 采样 image 共享正确 backing；
- render target 的 stencil、同 pass feedback、duplicate attachment、origin 和 texture view 都会产生局部画面错；
- shader translation 成功不等于 vertex input、driver segment、binding 和 pipeline state 正确；
- pipeline 分段提交和预热可以把性能问题从“看似卡顿”变成可测量的 CPU/GPU/compile 时间。

完整失败目录属于本项目内部实验记录；公开手册只保留这里的症状、契约、证据等级和不可推广边界。
