# 08 — 游戏特化 Profile

每个新游戏都应先创建 profile，再修改通用 runtime。建议至少包含：

| 类别 | 字段示例 | 必须记录 |
|---|---|---|
| 身份 | title ID、base/update、NSO build ID、SDK | 来源文件、SHA、版本 |
| 模块 | main/sdk/subsdk、映射、bss、异常信息 | module layout 和 loader 证据 |
| 重写 | patch site、原始 bytes、替换原因 | 反汇编前后、适用 build |
| 内存 | guest block、heap、alias、stack、页粒度 | 游戏请求值 vs 宿主限制值 |
| 图形 | shader map/pair、binding、format、swizzle、origin | shader hash、stage、参照截图 |
| 资源 | RomFS marker、Addressables、movie、font、save | 读取路径、缺失行为、大小/hash |
| 输入/状态 | 按键、touch、焦点、首轮存档 | 可回放序列和存档前置条件 |
| 性能 | 分辨率、present interval、GPU/CPU预算 | p50/p95/p99、温度和设备 |

## 通用层的准入条件

某项修复只有在以下条件都满足时才进入通用 runtime：

1. 不依赖 title ID、固定 guest address 或单个 shader hash；
2. 至少一个单元/离线测试覆盖；
3. 至少一个真实游戏回归；
4. 不破坏已有 profile；
5. 能解释原始平台契约，而不是仅让当前截图变好。

否则放进 profile，并写清楚为什么不能推广。
