# 可复用工具与证据产物

本章只登记仓库中可复用的工具和诊断入口；工具的具体参数以脚本的 `--help` 和对应项目文档为准。

## 静态分析与重编译

| 工具 | 路径 | 用途 | 产物/注意事项 |
|---|---|---|---|
| `patch_nso.py` | `dm/tools/patch_nso.py` | NSO 重写、规则集和按 build ID 的 cuts | 原始字节校验、记录模块 build ID；游戏特例必须进入 profile/cut 表 |
| `nso2elf.py` | `dm/tools/nso2elf.py` | NSO 转 ELF 供 Ghidra/objdump 使用 | 保留输入哈希和 image base |
| `nso_fnmap.py` | `dm/tools/nso_fnmap.py` | 在版本更新后映射函数/全局地址 | 每个映射必须回到反汇编复核 |
| `shader_split.py` | `dm/gfx/tools/shader_split.py` | 扫描 shader 容器、UnityFS、SARC 和内嵌 GLSLC | 同时保存 map/facts/pairs；不要把 hash 当作跨游戏语义 |
| `dmsh_build.py` | `dm/gfx/tools/dmsh_build.py` | 构建/翻译 shader 包 | 保存失败 shader 的 VS/FS/program 组合 |
| `dmsh_chain.py` | `dm/gfx/tools/dmsh_chain.py` | 串联 shader 处理步骤 | 让离线产物可重建，不依赖设备现场 |
| `c1_guard.py` | `dm/gfx/tools/c1_guard.py` | 检查 shader/编译器输出的回归约束 | 适合放进 CI 或构建前检查 |

## 运行时取证

仓库已有的 `DM_FS`、`DM_SVC`、`DM_THR`、`DM_WATCH`、`DM_WATCH_STALL` 等开关可用于定位服务、线程和停滞。图形侧的 `NX_TRACE_*` 开关、pass/command/UUB/sampler/glyph 追踪应按需短时开启；高频日志可能改变竞态，必须记录“诊断开关本身可能扰动时序”。

推荐产物目录：

```text
evidence/<date>/<experiment>/
  manifest.txt       # commit、设备、环境、输入哈希
  commands.txt       # 实际执行的命令
  logcat-or-host.log
  draws.tsv
  memory.tsv
  screenshots/
  verdict.md
```

## 设备验证

设备实验必须显式记录序列号、API 版本、GPU、驱动、页大小、安装包哈希和数据目录。多台 ADB 设备时，所有命令都使用明确的 `adb -s <serial>`；不要用当前默认设备替代目标设备。游戏本体、密钥、存档和用户数据不进入手册分支。

## 工具的边界

工具能缩短取证，不会自动证明契约。每个工具条目都应附：输入格式、输出字段、已知误报、适用游戏/SDK、最小回归用例。

手册本身的发布前检查可运行：

```sh
sh scripts/check_handbook.sh
```

它只检查文档相对链接、`symptom-index.tsv` 列数、私有标识扫描和 Git whitespace，不读取游戏数据，也不要求
设备在线。

若需要导出不带原项目源码的独立手册目录，可使用 `scripts/export_handbook.sh`；它不是自动推送工具，远端和
仓库可见性仍需维护者确认。
