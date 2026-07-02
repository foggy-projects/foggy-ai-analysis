# Runtime CLI 命令规则

任何需要 `foggy-runtime` 命令证据的任务，都使用本 reference。本文件随 `foggy-ai-analysis` 打包；不要假设外部 `foggy-runtime-cli-workflow` Skill 已安装。

## 契约

- 自动化检查和证据收集使用 `foggy-runtime` JSON 输出。
- 不调用 Java/Python 私有端点。
- 不添加或使用 `--engine`；runtime identity 来自 `capabilities`。
- `--output pretty` 只用于人工查看。
- 只在 dev/test 或用户明确批准数据源访问时执行只读 SQL 探针。

## Preflight

从用户输入、`FOGGY_RUNTIME_API_URL` 或公开 onboarding 默认值解析 runtime URL。从用户输入或 `FOGGY_NAMESPACE` 解析 namespace；如果做了假设，需要明确说明。

如果 runtime 刚启动：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <namespace> wait-ready --timeout-seconds 90 --interval-seconds 2
```

随后在执行具体功能前，必须记录 capabilities：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <namespace> capabilities
```

只有 `success=true` 且所需 capability 为 supported 时继续。记录 `engine`、`runtimeApiVersion`、`data.schemaVersion`、`data.securityMode` 和相关 `data.capabilities`。如果 `securityMode=auth-code`，传入 `--auth-code` 或设置 `FOGGY_RUNTIME_API_AUTH_CODE`。

对于依赖 Runtime API 能力的命令，CLI `v0.1.9` 会先做 capability preflight；不支持时以 exit code `3` 退出。覆盖 models、query、table inspection、SQL probing、bundle/datasource/resource management、compose 和 fsscript 命令。

CLI `v0.1.9` 在顶层和子命令中都支持 `-h`/`--help`，同时兼容单横线 `-help`。

## 数据源探索

对于 runtime-managed SQLite 数据源：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> datasources add --name <datasource-name> --type sqlite --jdbc-url jdbc:sqlite:<sqlite-db-path> --replace
foggy-runtime --base-url <runtime-url> --namespace <ns> datasources test <datasource-name>
foggy-runtime --base-url <runtime-url> --namespace <ns> datasources bind --namespace <ns> --data-source <datasource-name>
foggy-runtime --base-url <runtime-url> --namespace <ns> datasources binding --namespace <ns>
```

当证据需要展示 namespace registry entry 时，在 `datasources bind` 后执行 `datasources binding`。除非 runtime 明确支持 query-time datasource integration，否则查询执行仍遵循模型和 runtime datasource 契约。

编辑模型文件前先 list 和 inspect 表：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> tables list
foggy-runtime --base-url <runtime-url> --namespace <ns> tables list --data-source <datasource-name>
foggy-runtime --base-url <runtime-url> --namespace <ns> tables inspect --data-source <datasource-name> --table <table> --include-indexes
```

只有 caption、单位、枚举描述或字段分类需要值样例时，才取少量只读样例：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> sql query --data-source <datasource-name> --sql "select * from <table> limit 20" --max-rows 20
```

不要用 `sql query` 执行 mutation、DDL、存储过程、多语句脚本、生产权限绕过或私有端点 workaround。

## 模型循环

只有数据源 schema 已确认后，才生成或 patch TM/QM/model-list 文件。

查看未知模型名前，先列出可用 query model：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> models list
```

查看查询模型 schema 时，以 `models describe` 作为主路径：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel>
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel> --field <fieldName>
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel> --include-examples
```

用户询问 QM 有哪些字段、维度、度量、可筛选、可排序或可聚合能力时，将 describe 输出整理成紧凑字段表。构造 query payload 时必须使用 describe 中真实的 `fieldName`，包括 `<dimension>$id`、`<dimension>$caption` 这类维度属性名。

不要把旧 `/mcp/analyst/metadata` 或 `/mcp/analyst/description-model-internal` 当主路径。只有用户处在没有 Runtime API 的旧 Spring 服务，且明确需要 legacy fallback 时才使用，并在证据中标记为 legacy。

验证模型目录：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> models validate --models-dir <models-dir>
foggy-runtime --base-url <runtime-url> --namespace <ns> models validate --models-dir <models-dir> --include-stack-trace
```

validation 失败时，先分类再编辑：

- 大量缺表、lite runtime 下使用了过宽 demo 表，或引用了 inspect 范围外的表：schema 或 fixture mismatch。
- 已知表缺列或列改名：重新执行 `tables inspect`，只修复已证明的差异。
- 表和列都存在：按 TM/QM 语法、loader 或 Runtime API 行为问题处理。
- 如果响应区分 model errors 和 cascading errors，优先修复 `MODEL` 错误；`CASCADING` 通常是上游 TM/QM 错误导致的下游症状。

Runtime API/CLI `models validate` 取代旧 Spring `/api/semantic-layer/validate` 流程。只有项目仍暴露该旧 endpoint 且缺少 Runtime API 时，才作为 legacy fallback 使用：

```powershell
Invoke-RestMethod -Method Post `
  -Uri "http://localhost:<port>/api/semantic-layer/validate" `
  -ContentType "application/json" `
  -Body (@{
    path = "<models-dir>"
    namespace = "<ns>"
    clearExisting = $true
    includeStackTrace = $true
  } | ConvertTo-Json -Depth 5)
```

如果本地模型需要跨 runtime restart 保留，添加为 bundle：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> bundles add --name <ns>-dev-models --path <models-dir> --watch --replace
```

查询前先 refresh 和 describe：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> models refresh --model <QueryModel>
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel>
```

## 查询循环

只能根据 `models describe` 输出构建 DSL payload。execute 前先 validate：

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> query validate <QueryModel> --payload <payload.json>
foggy-runtime --base-url <runtime-url> --namespace <ns> query execute <QueryModel> --payload <payload.json>
```

CLI `v0.1.9` 接受 query payload 中的 `groupBy` string-array 简写，并在发送请求前规范化为 Runtime API v1 object items：

```json
{
  "columns": ["customerName", "customerSegment", "observationDate$month", "sum(salesDropAmount) as totalDrop"],
  "groupBy": ["customerName", "customerSegment", "observationDate$month"]
}
```

绕过 CLI 的原始 Runtime API v1 HTTP 调用方，在 Java API 原生支持 string-array 前，应使用 `[{"field":"customerName"}]` 形式发送 `groupBy`。

只有用户需要数据证据，或环境明确为 dev/test 时才 execute。遇到 `FIELD_NOT_FOUND`，重新 describe 模型，只替换为已存在字段。遇到 `MODEL_NOT_FOUND`，执行 `models list` 或 `models refresh`；不要静默切换到相似模型。如果 `safeToAutoRepair=false`，先解释问题并停止，不要改变语义。

## Exit Code

| Exit | 含义 | 处理 |
|---:|---|---|
| 0 | API success | 解析 `data` 并继续。 |
| 1 | CLI 或本地输入错误 | 修复命令、payload 路径或 JSON。 |
| 2 | Runtime API 错误 | 解析 `error` 和 `diagnostics`。 |
| 3 | capability 不支持 | 停止该流程；不要调用私有端点。 |
| 4 | Transport error | 要求启动 dev/test runtime 或修正 `--base-url`。 |

## 证据

报告命令及 pass/fail 状态、`capabilities` 中的 runtime identity、datasource/table inspection 结果、修改过的 TM/QM/model-list 文件、model validation/refresh/describe 结果、query validation/execution 结果、存在时的精确 `error.code` 和 `error.phase`，以及 namespace、datasource、fixture、dev/test runtime 状态相关的剩余假设。
