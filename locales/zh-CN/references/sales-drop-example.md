# Sales-Drop 示例

仅在用户没有数据源、需要快速 smoke test，或明确要求内置示例时使用本 reference。

## 资产

```text
assets/sales-drop-demo/schema.sql
assets/sales-drop-demo/data.sql
assets/sales-drop-demo/models
assets/sales-drop-demo/queries/basic.json
assets/sales-drop-demo/queries/question-bank
assets/sales-drop-demo/question-bank.json
```

## Replay

如果 `~/.agents/skills/foggy-ai-analysis` 下还没有安装 `foggy-ai-analysis`，先安装正式 Skill：

```powershell
foggy-runtime skills install foggy-ai-analysis --zip .\foggy-ai-analysis-skill-0.1.7.zip --replace
```

Java runtime 运行后，使用 CLI replay 命令。Skill 安装到 `~/.agents/skills/foggy-ai-analysis` 时可以省略 `--skill-dir`；只有解压到自定义目录时才需要显式传入：

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop demo sales-drop replay `
  --evidence-dir <evidence-dir> `
  --sqlite-path <runtime-default-sqlite-path> `
  --use-default-datasource
```

目标结果：

```text
question-bank total=12
executable=11
pass=11
fail=0
needs-clarification=1
runtime blockers=0
portReleased=true after shutdown
```

`needs-clarification` case 是预测请求，因为基础示例包含的是已观测诊断数据，不是预测数据源。
