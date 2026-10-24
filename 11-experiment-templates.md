# 实验与证据模板

本章是可复制的工作表。每次实验先复制模板，再执行；不要只把结论写进聊天记录。

## 1. 单变量实验

```markdown
## EXP-YYYYMMDD-NN：<短标题>

- 状态：未定 / 已证实 / 排除 / 撤回
- 目标层：loader / ABI / HLE / memory / thread / resource / shader / draw / present / input
- 基线构建：<commit、配置、游戏版本、模块 build ID>
- 设备与后端：<平台、GPU、API、驱动、页大小>
- 基线现象：<可观察事实，附日志/截图路径>
- 假设：如果 <变量> 是原因，那么 <可观测结果> 应该改变。
- 唯一变量：<开关、代码行或输入>
- 保持不变：<数据、存档、包、环境变量、操作序列>
- 执行命令：<可复制命令>
- 结果：<改变了什么、没有改变什么>
- 判定：<支持 / 排除 / 不足以判断>
- 清理：<撤销、保留的诊断开关、产物哈希>
- 下一步：<最多三个候选中的一个>
```

“开关改变后画面变了”只证明开关影响了执行路径，不自动证明它是根因。必须记录基线和回滚结果。

## 2. Mac/Android 或两台设备差分

```markdown
## DIFF-YYYYMMDD-NN：<相同输入的跨平台差分>

| 项目 | 参照端 | 被测端 | 是否完全相同 |
|---|---|---|---|
| 游戏数据/更新 | | | |
| patched 模块哈希 | | | |
| shader 包/表哈希 | | | |
| title/build/SDK | | | |
| API/驱动/设备 | | | |
| 输入序列与时间点 | | | |
| 首次 present 帧 | | | |
| 最后一个相同阶段 | | | |

- 首个分叉：<第一个不同的可观察事件>
- 只在被测端存在的条件：<平台特有能力/默认值/路径>
- 不能比较的项目：<不同步或未取证的部分>
- 结论等级：<已证实/未定/假设>
```

先找“首个分叉”，不要拿最终黑屏直接对照。Mac 能跑通通常是契约参照系，不代表其实现可以原样搬到 Android。

## 3. 图形 draw 取证

至少同时保存以下字段：frame、command list、draw 序号、VS/FS hash、program/pipeline、render target、viewport/scissor、channel mask、blend/depth/stencil、顶点缓冲地址/长度、纹理对象与 view、descriptor、shader IO、present 时间点。

判读顺序：

1. draw 是否录制并提交；
2. 是否进入目标 render pass；
3. 顶点/索引是否非空且地址有效；
4. program 是否成功、VS 输出与 FS 输入是否匹配；
5. descriptor 是否真实对象而非 dummy；
6. image 内容、swizzle、layout、barrier 是否正确；
7. blend/深度/模板/通道掩码是否允许写入；
8. composite 是否采样了正确 target；
9. present 是否提交了同一张图。

## 4. 内存账本

```markdown
| 时间/线程 | 操作 | guest addr | size | host backing | owner/object | ref/dirty | 结果 |
|---|---|---:|---:|---|---|---|---|
| | allocate/map | | | | | | |
| | write/unmap | | | | | | |
| | free/unmap | | | | | | |
```

每次检查这些不变量：映射区不重叠；unmap 只释放自己拥有的区间；used 不超过 max；SetHeapSize 与 MapPhysicalMemory 使用同一资源账本；对象销毁后不能被旧 command list 或 image reuse 引用。

## 5. 回归记录

```markdown
| 用例 | 基线 | 改动后 | 预期 | 实际 | 结论 |
|---|---|---|---|---|---|
| boot | | | | | |
| title/menu | | | | | |
| first dialogue | | | | | |
| movie/texture | | | | | |
| input/back | | | | | |
| 10 min idle | | | | | |
```
