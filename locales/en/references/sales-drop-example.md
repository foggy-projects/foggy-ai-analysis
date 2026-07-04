# Sales-Drop Example

Use this reference only when the user has no datasource, wants a fast smoke test, or asks for the bundled example.

## Assets

```text
assets/sales-drop-demo/schema.sql
assets/sales-drop-demo/data.sql
assets/sales-drop-demo/models
assets/sales-drop-demo/queries/basic.json
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
