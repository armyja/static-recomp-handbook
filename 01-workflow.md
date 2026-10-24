# 01 — 从调查到验收的工作流

## 阶段 0：建立事实表

先记录：游戏版本和 build ID、模块、SDK、引擎、目标平台、CPU/GPU、OS、页大小、Vulkan/Metal 能力、资源包
版本、patch hash 和 shader chain 版本。没有这张表，后面所有“同一版本”都不可信。

## 阶段 1：离线调查

1. 提取 ExeFS/RomFS 清单，不把大文件复制进代码仓库。
2. 统计导入符号、系统调用、NVN slot、线程/内存/文件服务入口。
3. 对每个重写 site 做反汇编前后对照，并保留原始 bytes、build ID 和 patch 原因。
4. 扫描 C/C++ HLE 导出、结构体大小、函数指针表和 C/C++ ABI 镜像。
5. 提取 shader、建立 VS/FS/CS program 对、binding 表和 profile。

## 阶段 2：最小平台闭环

按顺序验证：

```text
loader → 一个 guest 函数 → 一个 HLE 调用 → 一块固定 guest 内存
→ 一个 NVN buffer/texture → 一个 shader → 一个三角形 → acquire/present
```

这一步不能用真实游戏替代。真实游戏一旦失败，很难知道是加载器、服务还是图形问题。

## 阶段 3：真实游戏 bring-up

每轮只改变一个变量，并记录：

| 字段 | 内容 |
|---|---|
| 基线 | commit、profile、patch、shader chain、APK/可执行文件 hash |
| 环境 | 设备、驱动、页大小、资源目录、存档状态 |
| 变量 | 只允许一个代码/配置/环境变化 |
| 观察 | 固定时间或固定 frame 窗口；记录进程状态和截图 |
| 证据 | 日志、读回图、对象快照、反汇编或文件 hash |
| 结论 | 已证实、排除、未定、撤回或阻塞 |
| 清理 | 诊断开关、设备文件、临时资源是否恢复 |

## 阶段 4：建立 Mac/Android 或参考实现对照

对同一游戏状态，优先比较同一 draw：

- VS/FS hash 和 program pair；
- vertex/index bytes；
- UBO/SSBO 内容；
- texture pool 地址、offset、format、stride、swizzle、incarnation；
- render target、viewport、scissor、blend、depth/stencil；
- submit/acquire/present 的顺序和结果。

不要只比较最终截图。截图只能告诉你结果不同，不能告诉你差异在哪一层。

## 阶段 5：验收与性能

先通过普通配置验收：无诊断开关、干净存档、可重复路线、关键截图和持续运行时间。之后再测：

- p50/p95/p99 frame time；
- CPU translation、GPU execution、上传和 pipeline compile 分项；
- shader miss、draw completion、present drop；
- 内存峰值和长期增长；
- 分辨率、render scale、异步提交等优化的 A/B。

## 不应重复的实验方式

- 在高频路径加入大量 printf 或分配，随后把新时序当成原始行为；
- 同时改 heap、alias、shader 和 present；
- 只看 `return 0` 就认为 HLE 正确；
- 用一个游戏的固定地址修通用 runtime；
- 让“补大内存”“固定颜色”“关闭深度”成为最终修复；
- 把没有 shader cache、没有存档、没有资源的运行结果误判为图形根因。
