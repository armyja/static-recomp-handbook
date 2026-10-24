# 发布前审计记录

核对日期：2026-10-24

## 当前范围

- 分支：`static-recomp-handbook`
- 基线：从 nxnative 干净提交建立的手册分支
- 手册目录：`docs/handbook/`
- 发布候选不包含游戏本体、密钥、RomFS、NSP/XCI、存档或用户设备数据

## 已执行检查

| 检查 | 命令/方法 | 结果 |
|---|---|---|
| Git whitespace | `git diff --check` | 通过 |
| 相对 Markdown 链接 | 遍历 `docs/handbook/*.md` 的本地链接目标 | 通过 |
| 症状索引结构 | `awk -F '\\t'` 检查非注释行列数 | 通过，16 行 |
| 私有标识扫描 | 绝对本机路径前缀、会话标识、内部协作名称、私钥头 | 未发现 |
| 自动化复核 | `sh scripts/check_handbook.sh` | `handbook checks: OK` |

## 已覆盖范围

完成矩阵见 [15-completion-matrix.md](15-completion-matrix.md)。当前已经覆盖通用模型、runtime/图形契约、平台差异、
失败案例、AI 诊断、游戏 profile、公开项目解读、许可证边界、实验模板、工具和发布流程。

## 尚未执行的外部动作

- 没有创建或推送新的 GitHub 仓库；当前没有得到最终远端 URL。
- 没有提交本地改动；原项目规范要求维护者明确要求后再提交。
- Wonder Recomp、Skyline、Ryujinx/yuzu 的部分源码/许可证仍保持“待核对”，没有把它们写成已审计实现。

这三项不是文档内容缺失，而是发布授权、远端选择或外部版本核验事项。继续发布前应重新运行
[14-publishing-checklist.md](14-publishing-checklist.md)。
