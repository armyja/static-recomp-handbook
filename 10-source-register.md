# 10 — 来源登记表

本表避免把“我看过一个 README”误写成“代码已经审计”。状态分为：`已读文档`、`待读代码`、`只作语义参考`、
`可复用但需保留许可证`、`禁止直接复制`。

本轮公开资料核对日期：2026-10-24。外部事实以表中仓库链接为准；未固定到 commit/tag 的条目不得被表述为
“源码已逐行审计”，后续应补稳定版本和具体文件。

来源只分两类：公开来源可以带链接和许可证登记；私有来源不进入本表，不进入公开分支。私有材料产生的通用
经验若要公开，必须重新用公开证据或本项目独立实验表达，不能暴露私有仓库、会话、文件名或内部标识。

| 来源 | 类型 | 当前登记 | 可贡献给手册的内容 |
|---|---|---|---|
| 本项目独立实践 | 项目自身 | 已读内部实验并抽象公开 | Mac/Android bring-up、失败目录、profile、NVN/Metal/Vulkan 案例；不公开内部路径和原始设备资料 |
| [d2r-mobile](https://github.com/jhaizhou-ops/d2r-mobile) | MIT（以仓库当前声明为准） | README/Android 文档；HEAD `195ae11dc70f`（2026-10-24） | Android shell、离线 shader pack、性能回归、共享 host 分层 |
| [SuperMarioWonderRecomp](https://github.com/belmanteGu/SuperMarioWonderRecomp) | 需确认当前 LICENSE | 已读 README/Android-port/DEBUG 摘要 | NVN→Vulkan 组织、upload ring、调试条目、Android 风险表 |
| [Eden](https://github.com/comex/eden) | 需逐版本确认 | DesignOverview；HEAD `908b1e9a3701`（2026-10-24） | HLE 分层、Android frontend、shader recompiler、Vulkan backend 组织 |
| [Strato](https://github.com/strato-emu/strato) | GPL-3.0 | README；HEAD `ae1566a48285f`（2026-10-24） | Android emulator 的架构线索；禁止未经审核直接复制 |
| [Atmosphère/libmesosphere](https://github.com/Atmosphere-NX/Atmosphere/tree/master/libraries/libmesosphere) | GPLv2，含特定例外 | README/许可证说明；HEAD `6b0c077b4c60f`（2026-10-24） | Horizon kernel 语义和测试向量；默认只作参考 |
| [LASRecomp](https://github.com/peiikai/LASRecomp) | 需按仓库 LICENSE | README/Linux 文档；HEAD `59b61fd3c65d`（2026-10-24） | 跨平台矩阵、Vulkan/Linux ARM64 验收、启动时准备资源 |
| Ryujinx / yuzu | 需逐仓库/文件确认 | 本地已有 vendored/reference 线索 | shader translation、Horizon service 和内存语义交叉验证 |
| Skyline | 需确认原仓库状态和许可证 | 仅由 Strato README 间接定位 | NCE、Android memory/TLS/异常边界的研究入口 |

## 引用规范

每次新增外部条目，补充：

```text
URL：
访问日期：
commit/tag：
许可证：
读过的文件：
事实：
从事实推导的本地建议：
不能推导的部分：
```

外部仓库如果只读到了 README，就只能写 README 证实的事实；不能把推测写成“代码已经解决”。
