# 02 — Runtime 契约：loader、HLE、内存和线程

## Loader / ABI

静态重编译最早的错误通常不是“平台不支持”，而是边界不对：符号绑定到错误模块、relocation 未应用、
结构体 packing 不同、返回值或寄存器没有按 AAPCS64 保存。每个 HLE 入口至少要能回答：

- 参数来自哪些寄存器/栈槽；
- 输出 buffer 的大小、对齐和初始化状态；
- 返回值如何驱动 guest 的下一分支；
- 该调用是否可能保存指针，在异步线程稍后使用。

## HLE 服务

“成功返回”不是通用 fallback。若调用者随后读取一个未填的结构体，问题会延迟到完全无关的地址崩溃。
对每个 stub 做调用计数和输出 sentinel 检查；合法的“没有设备/没有 amiibo/没有用户”要返回游戏期待的空状态，
而不是任意零值。

## Guest memory / VAMM

需要维护至少四个彼此一致的账本：

1. guest 虚拟地址区间及权限；
2. host backing 页和页粒度；
3. `SetHeapSize` 与 `MapPhysicalMemory` 的物理资源占用；
4. `QueryMemory` 对外报告的分区和状态。

关键不变量：

```text
map/unmap 守恒
QueryMemory 分区不重叠
used <= max
释放后的地址不可继续访问
重复 map 不重复计费
```

扩大 alias 或 heap 只能证明“越过了一个崩溃”，不能证明 guest 的资源限制契约正确。

## 线程、TLS 和调度

Unity/IL2CPP 会依赖线程暂停、寄存器上下文、线程栈、futex/condvar、核心亲和性和 TLS。尤其注意：

- guest 的 x18/TLS 语义不能直接等同于宿主 pthread TLS；
- 小 guest stack 上执行复杂 host hook 会溢出，应切换到大 host stack；
- 线程 SVC 返回不代表等待状态已完成；
- 诊断日志可能改变竞态，必须使用低频摘要或离线回放。

## 文件、存档和时间

Android scoped storage、xattr namespace、路径大小写、clone/copy 语义、时间精度和随机数都可能影响游戏逻辑，
且最终表现为“黑屏”。先验证文件路径、大小、hash 和 errno，再去怀疑 Vulkan。

## 通用修复与游戏修复的边界

通用修复可以进入 runtime：ABI、页表、线程状态机、文件语义、对象生命周期、Vulkan barrier。游戏修复必须进入
profile：地址、模块、build ID、容量、shader hash、特定初始化顺序。若一处修复需要写死某个 `main+offset`，
默认把它视为 profile 变更，而不是通用修复。
