# 公开发布前清单

这份清单用于把手册推到一个不绑定 Android、macOS、设备或具体游戏的公开仓库。没有明确远端前，只能完成本地
审计和准备，不应猜测目标仓库。

## 内容审计

- [ ] 每个外部事实都有公开 URL、仓库名、许可证状态和访问日期。
- [ ] 能影响许可证判断的代码已固定到 commit/tag，或明确标为“仅读文档/待核对”。
- [ ] 私有仓库、私有分支、私有会话、用户设备日志和未授权补丁没有进入内容、链接、截图或示例命令。
- [ ] 没有游戏本体、密钥、RomFS/NSP/XCI、shader binary、存档或用户数据。
- [ ] 游戏特化参数都带 build ID、适用条件、证据等级和不可推广边界。
- [ ] Android、macOS 和具体设备只作为案例维度，不出现在仓库名和通用章节标题中。
- [ ] 若发布为独立手册仓库，确认是否保留原项目代码历史；若只公开知识库，应从干净文档树发布，避免把游戏移植源码误当成手册内容。

## 结构和可读性

- [ ] `README.md` 能从症状索引进入对应章节。
- [ ] `symptom-index.tsv` 每行列数一致，字段可被脚本读取。
- [ ] 所有相对链接在干净 checkout 中有效；不依赖 sibling worktree。
- [ ] 中文说明保留必要的英文 API/文件名，便于搜索源码和 GitHub 文档。
- [ ] 新条目说明“可复用设计”和“不可直接复制代码”的区别。

## 本地验证

```sh
git diff --check
git status --short
awk -F '\t' 'BEGIN { bad=0 } /^[^#]/ && NF != 5 { print NR ": bad TSV columns=" NF; bad=1 } END { exit bad }' \
  docs/handbook/symptom-index.tsv
```

再从一个临时干净 checkout 运行相对链接检查；不要只在当前含有 sibling worktree 的目录中验证。

## 提交和推送顺序

1. 由维护者确认最终仓库名和远端 URL。
2. 在本分支查看 `git diff --stat` 与敏感文件扫描结果。
3. 维护者明确同意后再 `git add`、提交并设置远端；提交信息说明这是知识库，不是游戏移植产物。
4. 推送后检查 GitHub 页面中的相对链接、许可证说明和仓库可见性。
5. 发布首个 tag 后，把 tag 写回来源登记表，后续引用优先使用稳定 tag/commit。

如果选择独立知识库，可先执行：

```sh
sh scripts/export_handbook.sh /path/to/new-empty-handbook
```

脚本会先运行手册检查，只复制根许可证、手册 README、手册目录和公开范围说明，并拒绝覆盖非空目录。

当前工作树是从 nxnative 的干净提交建立的手册分支，因此仍包含原项目源码和 MIT `LICENSE`。这不等于手册已经
成为独立仓库；最终发布前由维护者选择“在现有仓库推送分支”或“导出 `docs/handbook` 为新仓库”，并重新检查
历史、第三方目录和根 README 的公开范围。

推荐仓库名：`static-recomp-handbook`、`recomp-field-manual`、`native-recomp-guide`。
