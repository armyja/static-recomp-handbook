# Static Recompilation Field Manual

静态重编译经验手册。目标不是记录某一次成功构建，而是让下一次适配新游戏时，能从症状快速回到正确的
契约层，少做会改变时序、污染现场或把游戏特例写进通用 runtime 的实验。

## 读者和范围

- 做 Switch/ARM64 静态重编译的人：重写器、loader、Horizon HLE、NVN、Metal/Vulkan、Android/iOS/macOS。
- 维护运行时的 AI：需要先查分类、已有排除项和证据标准，再提出下一步实验。
- 审阅外部实现的人：需要区分“可借鉴的设计”“可复用的代码”和“许可证不能直接复制的代码”。

本手册不提供游戏文件、密钥或可直接运行的游戏内容；所有游戏输入都假设来自用户合法拥有的副本。

## 章节

| 文档 | 用途 |
|---|---|
| [00-principles.md](00-principles.md) | 静态重编译的模型、边界和核心原则 |
| [01-workflow.md](01-workflow.md) | 从调查到真机验收的开发/实验流程 |
| [02-runtime-contracts.md](02-runtime-contracts.md) | loader、ABI、HLE、内存、线程、文件系统契约 |
| [03-graphics-contracts.md](03-graphics-contracts.md) | NVN→Metal/Vulkan、shader、纹理、同步和 present |
| [04-platform-differences.md](04-platform-differences.md) | Mac/Apple 与 Android 的共同点和差异 |
| [05-ai-diagnostic-runbook.md](05-ai-diagnostic-runbook.md) | 给 AI 使用的症状→证据→下一步决策树 |
| [06-case-studies.md](06-case-studies.md) | nxnative 的 Android/Mac 关键突破和失败案例 |
| [07-external-projects.md](07-external-projects.md) | d2r-mobile、Eden/Yuzu、LASRecomp 等外部项目解读 |
| [08-portability-profile.md](08-portability-profile.md) | 游戏特化参数、来源、验证和通用边界 |
| [09-contribution-and-licensing.md](09-contribution-and-licensing.md) | 如何补充条目、引用代码和维护许可证边界 |
| [10-source-register.md](10-source-register.md) | 外部来源、许可证和阅读状态登记 |
| [11-experiment-templates.md](11-experiment-templates.md) | 实验、对照、差分和回归记录模板 |
| [12-reusable-tools.md](12-reusable-tools.md) | 本地工具、日志开关和证据产物目录 |
| [13-milestone-map.md](13-milestone-map.md) | 从黑屏到可玩的关键突破复盘 |
| [14-publishing-checklist.md](14-publishing-checklist.md) | 公开仓库发布前的审计清单 |
| [15-completion-matrix.md](15-completion-matrix.md) | 目标要求到文档和验证证据的对应表 |
| [16-provenance.md](16-provenance.md) | 本项目经验、外部引用和公开范围说明 |
| [17-audit-report.md](17-audit-report.md) | 当前工作树的发布前审计记录 |
| [18-android-candidate-validation.md](18-android-candidate-validation.md) | 真实 Android 设备上的公开静态重编译候选验证 |
| [19-lasrecomp-android-lessons.md](19-lasrecomp-android-lessons.md) | LASRecomp Android 的分层、构建和性能经验提炼 |
| [20-target-architecture.md](20-target-architecture.md) | 未来可复用静态重编译平台的目标架构 |
| [symptom-index.tsv](symptom-index.tsv) | 机器可读的症状→证据→章节索引 |

## 证据等级

每个结论必须带一种状态：

- **已证实**：有可复现命令、日志、截图、读回数据或静态反汇编直接支持。
- **排除**：单变量对照改变了条件，但故障边界没有改变；说明该假设不是充分原因。
- **未定**：样本不足、观测改变时序或参照系不一致。
- **假设**：解释现象的候选，不得写成修复建议。
- **撤回**：后续证据推翻的旧结论，必须保留原因，防止重复实验。

## 本项目独立实践

本手册的 Android/Mac 案例来自本项目内部的实验记录和代码审阅；发布手册不依赖其他本机 worktree、私有会话、
设备日志或游戏资料。若需要复核原始证据，应在内部工作区按实验编号查找，公开版只保留可迁移的事实、方法和边界。

## 维护原则

手册分支只收录可迁移的经验、案例和引用，不把当前某个游戏的临时 hack 当成通用修复。每条代码级经验
需要写出：来源、适用条件、不能推广的边界、许可证、证据和回归方式。
