# 目标完成矩阵

本表用于维护者交接和发布前审计。`已覆盖`表示对应内容已经有章节和规则；不表示每个外部仓库的源码审计已经
完成。外部来源仍以 [10-source-register.md](10-source-register.md) 的状态为准。

| 目标要求 | 主要文档 | 当前证据 | 状态 |
|---|---|---|---|
| 与平台/设备无关的通用模型 | [00-principles.md](00-principles.md)、[02-runtime-contracts.md](02-runtime-contracts.md) | game contract / platform contract / graphics contract 分层；不可推广边界 | 已覆盖 |
| nxnative 自身实践 | [06-case-studies.md](06-case-studies.md)、[13-milestone-map.md](13-milestone-map.md) | Android/Mac 黑屏、出帧、资源、shader、内存和 bring-up 复盘 | 已覆盖 |
| 失败案例与撤回机制 | [01-workflow.md](01-workflow.md)、[05-ai-diagnostic-runbook.md](05-ai-diagnostic-runbook.md) | 证据等级、单变量实验、排除/撤回规则 | 已覆盖 |
| runtime 契约 | [02-runtime-contracts.md](02-runtime-contracts.md) | loader、ABI、HLE、VAMM、线程、TLS、FS、时间不变量 | 已覆盖 |
| 图形契约 | [03-graphics-contracts.md](03-graphics-contracts.md) | draw→shader→resource→pass→present 排查链 | 已覆盖 |
| Android 与 Mac 差异 | [04-platform-differences.md](04-platform-differences.md) | API、驱动、Surface、Metal、Vulkan、存储和时序差异 | 已覆盖 |
| AI 快速定位 | [05-ai-diagnostic-runbook.md](05-ai-diagnostic-runbook.md)、[symptom-index.tsv](symptom-index.tsv) | 症状索引、决策树、固定输出格式 | 已覆盖 |
| 游戏特化参数 | [08-portability-profile.md](08-portability-profile.md) | profile 字段、build ID、patch、shader、资源和输入边界 | 已覆盖 |
| 公开 GitHub 项目解读 | [07-external-projects.md](07-external-projects.md)、[10-source-register.md](10-source-register.md) | URL、许可证、HEAD/访问日期、实际阅读范围和限制 | 已覆盖；部分来源待核对 |
| 可复用代码/设计边界 | [07-external-projects.md](07-external-projects.md)、[09-contribution-and-licensing.md](09-contribution-and-licensing.md) | 设计可借鉴、代码须按许可证审核、GPL/未知许可证隔离 | 已覆盖 |
| 私有资料排除 | [09-contribution-and-licensing.md](09-contribution-and-licensing.md)、[14-publishing-checklist.md](14-publishing-checklist.md) | 禁止私有会话、设备日志、未授权补丁进入公开分支 | 已覆盖 |
| 可长期维护 | [11-experiment-templates.md](11-experiment-templates.md)、[12-reusable-tools.md](12-reusable-tools.md) | 实验模板、工具目录、证据产物和回归表 | 已覆盖 |
| 静态重编译分层与构建产物 | [00-principles.md](00-principles.md)、[19-lasrecomp-android-lessons.md](19-lasrecomp-android-lessons.md) | profile/生成器、game library、runtime、平台层和可恢复构建边界 | 已覆盖 |
| Android 产品化经验 | [04-platform-differences.md](04-platform-differences.md)、[19-lasrecomp-android-lessons.md](19-lasrecomp-android-lessons.md) | 解包、版本校验、on-device build、缓存、触控、驱动与移动 GPU 测量 | 已覆盖 |
| 未来目标架构 | [20-target-architecture.md](20-target-architecture.md) | 通用编译器、runtime、图形前端、平台层和游戏 profile 的目标分层与迁移阶段 | 已记录；未宣称实现 |
| 图形契约研究方向 | [03-graphics-contracts.md](03-graphics-contracts.md)、[21-contract-reconstruction-research.md](21-contract-reconstruction-research.md) | Contract IR、事实 ledger、oracle 分层、等价类、检查点重放和 L0–L5 成熟度 | 已记录；工具尚待实现 |
| 游戏选型与成熟度 | [22-game-selection-and-maturity.md](22-game-selection-and-maturity.md) | 按契约能力选择样本，定义从合成测试到 XC3 压力测试的阶梯 | 已记录；样本验证持续进行 |
| GitHub 发布准备 | [14-publishing-checklist.md](14-publishing-checklist.md) | 敏感扫描、链接检查、提交/推送顺序和候选仓库名 | 已覆盖；待远端确认 |

## 尚未宣称完成的事项

- Wonder Recomp 的当前稳定源码和许可证尚未固定到可复核 commit；手册只保留公开文档层面的参考。
- Ryujinx/yuzu、Skyline 等项目仍需按具体文件和许可证做更细的交叉核对；当前只作为语义参考登记。
- 最终 GitHub 仓库名、远端和首个公开 tag 尚未由维护者确认，因此没有执行提交或推送。
