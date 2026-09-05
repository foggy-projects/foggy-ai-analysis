# Sales-Drop 示例

仅在用户没有数据源、需要快速 smoke test，或明确要求内置示例时使用本 reference。

## 资产

```text
assets/sales-drop-demo/schema.sql
assets/sales-drop-demo/data.sql
assets/sales-drop-demo/models
assets/sales-drop-demo/queries/basic.json
assets/sales-drop-demo/queries/date-dimension.json
assets/sales-drop-demo/queries/static-dictionary-caption.json
assets/sales-drop-demo/queries/question-bank
assets/sales-drop-demo/question-bank.json
```

## Replay

如果 `~/.agents/skills/foggy-ai-analysis` 下还没有安装 `foggy-ai-analysis`，先安装正式 Skill：

```powershell
$skillVersion = "<skill-version>"
foggy-runtime skills install foggy-ai-analysis --zip ".\foggy-ai-analysis-skill-$skillVersion.zip" --replace
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
question-bank total=13
executable=12
pass=12
fail=0
needs-clarification=1
runtime blockers=0
portReleased=true after shutdown
```

`needs-clarification` case 是预测请求，因为基础示例包含的是已观测诊断数据，不是预测数据源。

## 单列日期自维度 smoke

示例把事实表上的 `observation_date` 直接建模为 `DAY` 类型的
`observationDate` 自维度，不需要 `dim_date`，也不会产生日期表 JOIN。QM 明确暴露
`observationDate$id`、`observationDate$caption`、`observationDate$year`、
`observationDate$month` 和 `observationDate$yearMonth`，方便 LLM 选择日期范围或聚合粒度。

只有 `models describe SalesDropDailyQueryModel` 已返回上述字段时，才运行年月汇总 smoke：

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop query validate SalesDropDailyQueryModel --payload <skill-dir>/assets/sales-drop-demo/queries/date-dimension.json
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop query execute SalesDropDailyQueryModel --payload <skill-dir>/assets/sales-drop-demo/queries/date-dimension.json
```

该 payload 使用 `$yearMonth`，避免只按 `$month` 聚合时把不同年份合并。旧 Runtime 或
未按日期维建模的 QM 没有返回这些字段时，应继续使用 describe 中已有的原始日期字段，
不能由客户端自行拼接日期粒度。

## 可选静态字典 smoke

示例的 `severity` 字段通过 `models/dicts.fsscript` 配置静态 `dictRef`。只有
`models describe SalesDropDailyQueryModel` 已返回 `severity$caption` 时，才运行：

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop query validate SalesDropDailyQueryModel --payload <skill-dir>/assets/sales-drop-demo/queries/static-dictionary-caption.json
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop query execute SalesDropDailyQueryModel --payload <skill-dir>/assets/sales-drop-demo/queries/static-dictionary-caption.json
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop members list SalesDropDailyQueryModel severity
```

预期行中的 `severity` 保持 `CRITICAL`，`severity$caption` 为 `严重`；payload
传入 label 后由 Java Runtime 转为原始 code。payload 按 `salesDropAmount` 排序，
不会尝试对不支持排序的 `$caption` 排序。旧 runtime 未在 describe 中暴露
`severity$caption` 时跳过本 smoke，不要在客户端自行翻译。
