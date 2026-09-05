# Sales-Drop Example

Use this reference only when the user has no datasource, wants a fast smoke test, or asks for the bundled example.

## Assets

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

Install `foggy-ai-analysis` first if it is not already under `~/.agents/skills/foggy-ai-analysis`:

```powershell
$skillVersion = "<skill-version>"
foggy-runtime skills install foggy-ai-analysis --zip ".\foggy-ai-analysis-skill-$skillVersion.zip" --replace
```

After the Java runtime is running, use the CLI replay command. When the Skill is installed under `~/.agents/skills/foggy-ai-analysis`, `--skill-dir` can be omitted; pass it only for an unpacked custom location:

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop demo sales-drop replay `
  --evidence-dir <evidence-dir> `
  --sqlite-path <runtime-default-sqlite-path> `
  --use-default-datasource
```

Target result:

```text
question-bank total=13
executable=12
pass=12
fail=0
needs-clarification=1
runtime blockers=0
portReleased=true after shutdown
```

The `needs-clarification` case is the forecast request because the base example contains observed diagnostics, not a forecast source.

## Single-column self date-dimension smoke

The example projects the fact-table `observation_date` column directly as the `DAY`-typed
`observationDate` self dimension. It needs no `dim_date` table and produces no date-table join.
The QM explicitly exposes `observationDate$id`, `observationDate$caption`,
`observationDate$year`, `observationDate$month`, and `observationDate$yearMonth` so an LLM can
choose a date range or aggregation grain safely.

Run the year-month smoke only when `models describe SalesDropDailyQueryModel` returns those fields:

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop query validate SalesDropDailyQueryModel --payload <skill-dir>/assets/sales-drop-demo/queries/date-dimension.json
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop query execute SalesDropDailyQueryModel --payload <skill-dir>/assets/sales-drop-demo/queries/date-dimension.json
```

The payload uses `$yearMonth` so records from different years are not merged by grouping on
`$month` alone. If an older Runtime or a QM without date-dimension modeling does not describe
these fields, use the raw date field that is actually described; clients must not append date
grains themselves.

## Optional static-dictionary smoke

The example configures the `severity` field with a static `dictRef` in
`models/dicts.fsscript`. Run the following only when
`models describe SalesDropDailyQueryModel` advertises `severity$caption`:

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop query validate SalesDropDailyQueryModel --payload <skill-dir>/assets/sales-drop-demo/queries/static-dictionary-caption.json
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop query execute SalesDropDailyQueryModel --payload <skill-dir>/assets/sales-drop-demo/queries/static-dictionary-caption.json
foggy-runtime --base-url http://127.0.0.1:18066 --namespace salesdrop members list SalesDropDailyQueryModel severity
```

The expected row keeps `severity` as `CRITICAL` and returns `Critical` in
`severity$caption`; Java Runtime converts the label filter back to the raw code. The payload
orders by `salesDropAmount`, not by the non-sortable `$caption`. Skip this smoke on an older
runtime that does not advertise `severity$caption`; do not translate labels in the client.
