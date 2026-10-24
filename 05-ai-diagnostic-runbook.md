# 05 — AI 诊断手册

## 接到一个新症状时

### 1. 先分类，不猜修复

把症状标为：启动/ABI、服务、内存、线程、文件、输入、shader、纹理、target/composite、present、性能或内容缺失。
同一现象可以有多个候选，但只能选择一个最小下一证据。

### 2. 写出不变量

例：

- “黑屏”不变量：至少一个有效 draw 写入最终可达的 target，且 present source 在 acquire 后包含该 target 的内容。
- “文字缺失”不变量：VS/FS pair、glyph vertex/UV、atlas view、descriptor、discard 输入和最终颜色都可解释。
- “139”不变量：fault address 属于哪个 guest region，调用者是否检查了分配失败，宿主是否越过了边界。

### 3. 选不扰动时序的证据

优先：静态反汇编、离线 shader reflection、文件 hash、低频计数、单次 snapshot、同 draw 的结构摘要。
最后才是高频日志、强制 sleep、全量 dump 和改变调度的开关。

### 4. 只做一个实验

实验必须回答一个二分问题：

```text
如果 A 改变，候选 X 得到支持；如果 A 不变，候选 X 被排除。
```

实验结束后马上记录结果、清理现场、更新“已排除列表”，不要把未命中误写成“系统正常”。

### 5. 用参照系收敛

优先选择：Mac 同场景、另一个已知可工作的 title、离线三角形、纯色 shader、golden texture、原始 guest bytes。
参照系必须记录版本和输入；否则“Mac 正常”也可能只是不同存档或不同资源路径。

## 决策树

```text
进程是否继续？
├─ 否 → crash/线程/服务/内存/文件，先定位最后一个 guest 边界
└─ 是
   ├─ present 是否继续？
   │  ├─ 否 → queue/fence/Surface/线程等待
   │  └─ 是
   │     ├─ draw 是否完成？
   │     │  ├─ 否 → program/descriptor/command list/资源生命周期
   │     │  └─ 是
   │     │     ├─ target 有内容吗？
   │     │     │  ├─ 否 → vertex/VS/FS/纹理/深度/混合
   │     │     │  └─ 是 → composite/present source/window image
   │     │     └─ 只缺某类资源？→ profile/shader/cache/texture view
```

## AI 输出格式

每次给出：

1. 当前已证实事实；
2. 已排除事实；
3. 最多三个候选，按证据排序；
4. 一个最小实验或静态检查；
5. 预期的三种结果和下一步；
6. 回滚/清理动作；
7. 文档条目编号和是否需要 commit。

禁止只输出“可能是竞态”“可能是 patch”而没有可证伪的下一步。
