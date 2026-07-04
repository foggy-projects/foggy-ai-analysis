# Semantic Layer Publish/Update Runbook

当用户要“发布语义层”、“更新语义层”、“提交到 runtime”，或希望 TM/QM 修改对 Runtime API/MCP 查询服务生效时，使用本 runbook。

本文档中的“发布/更新语义层”定义为：把用户当前 Git 工作区中的模型目录注册为 Runtime managed bundle，并通过 refresh 让 Runtime API/MCP 查询服务加载最新 TM/QM。

## 边界

用户自己的 Git 和工程流程负责 TM/QM 文件的版本管理、分支策略、变更审批、回滚、审计、租户权限治理和 RBAC。本 Skill 不实现，也不替代这些治理流程。

本 runbook 只覆盖：

1. Runtime/CLI/Skill 安装和 readiness 检查。
2. 数据源创建、测试和 namespace 绑定。
3. 表结构 inspect 和只读 SQL 探查。
4. TM/QM 文件生成或修改。
5. `models validate`。
6. `bundles add` 或 update。
7. `models refresh`。
8. `models describe`。
9. `query validate` 和 `query execute` smoke。
10. MCP endpoint probe 和客户端连接信息。

## Preconditions

执行前确认这些值：

```text
runtime-url=<runtime API base URL, for example http://127.0.0.1:18066>
namespace=<namespace>
models-dir=<absolute or workspace-relative path to the TM/QM model directory>
bundle=<runtime bundle name>
datasource-name=<Runtime API datasource name>
query-model=<QueryModelName>
evidence-dir=<directory where JSON outputs and pass/fail notes are saved>
```

必须满足：

- 用户已经用 Git 管理 TM/QM 文件。Git 版本、审批、回滚、审计和 RBAC 由用户负责。
- 已安装 `foggy-runtime-cli`。
- Runtime API 已启动。
- 已确定 Runtime URL、namespace、models-dir、bundle name 和 datasource name。
- 如果 `securityMode=auth-code`，CLI 命令使用 `--auth-code <code>`，或设置 `FOGGY_RUNTIME_API_AUTH_CODE`。
- datasource 密码必须保存在环境变量、secret store 或 runtime datasource 配置中。不要把密码写进 TM/QM 文件。

所有命令都使用 JSON 输出并保存结果：

```powershell
New-Item -ItemType Directory -Force -Path <evidence-dir> | Out-Null

# Runtime API 返回 securityMode=auth-code 时可选：
$env:FOGGY_RUNTIME_API_AUTH_CODE = "<auth-code>"
```

只有 JSON 响应 `success=true` 且目标对象存在时才记录 PASS。FAIL 需要记录命令、输出文件路径、准确的 `error.code`、`error.phase`、message 和下一步修复动作。

## Step 1: Runtime Readiness And Capabilities

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> wait-ready --timeout-seconds 90 --interval-seconds 2 |
  Tee-Object -FilePath <evidence-dir>/01-wait-ready.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> capabilities |
  Tee-Object -FilePath <evidence-dir>/02-capabilities.json
```

PASS 条件：

- Runtime 可访问。
- `capabilities` 返回 `success=true`。
- 记录 `engine`、`runtimeApiVersion`、`schemaVersion`、`securityMode`，以及 datasource、bundle、model、query、SQL、MCP 相关 capability。
- 如果 `securityMode=auth-code`，后续 CLI 命令继续使用 `--auth-code <code>`，或保持 `FOGGY_RUNTIME_API_AUTH_CODE` 已设置。

Runtime API capability 缺失时停止。不要调用 private Java 或 Python endpoint 作为绕过方式。

## Step 2: Datasource Validation

如果 datasource 还不存在，使用目标 runtime 支持的 Runtime API-managed datasource 命令创建。示例：

```powershell
# SQLite example
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources add --name <datasource-name> --type sqlite --jdbc-url jdbc:sqlite:<sqlite-db-path> --replace |
  Tee-Object -FilePath <evidence-dir>/03-datasource-add.json

# MySQL example. Keep the password in an environment variable, not in TM/QM files.
$env:FOGGY_DB_PASSWORD = "<password>"
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources add --name <datasource-name> --type mysql --jdbc-url "jdbc:mysql://<host>:<port>/<database>?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" --username <user> --password-env FOGGY_DB_PASSWORD --replace |
  Tee-Object -FilePath <evidence-dir>/03-datasource-add.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources bind --namespace <namespace> --data-source <datasource-name> |
  Tee-Object -FilePath <evidence-dir>/04-datasource-bind.json
```

验证 datasource 和 namespace binding：

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources list |
  Tee-Object -FilePath <evidence-dir>/05-datasources-list.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources test <datasource-name> |
  Tee-Object -FilePath <evidence-dir>/06-datasource-test.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources binding --namespace <namespace> |
  Tee-Object -FilePath <evidence-dir>/07-datasource-binding.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> tables list --data-source <datasource-name> |
  Tee-Object -FilePath <evidence-dir>/08-tables-list.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> tables inspect --data-source <datasource-name> --table <key-table> --include-indexes |
  Tee-Object -FilePath <evidence-dir>/09-table-inspect-key-table.json
```

至少 inspect 一个核心业务表。需要样例值来修复 caption、单位或枚举含义时，只使用小范围只读 SQL：

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> sql query --data-source <datasource-name> --sql "select * from <key-table> limit 20" --max-rows 20 --timeout-seconds 5 |
  Tee-Object -FilePath <evidence-dir>/10-sql-sample-key-table.json
```

除非用户明确授权，不要执行变更 SQL、DDL、存储过程或生产大范围扫描。

## Step 3: Model Validation

注册或 refresh bundle 之前先 validate：

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models validate --models-dir <models-dir> --include-stack-trace |
  Tee-Object -FilePath <evidence-dir>/11-models-validate.json
```

PASS 条件：

- JSON 响应 `success=true`。
- 没有 invalid TM/QM 文件。
- warning 已理解，并且对本次 smoke 可接受。

validation 失败时，不要发布，不要执行 `bundles add`，也不要执行 `models refresh`。先修 TM/QM 语法、字段引用、datasource schema mismatch、缺失表、缺失列、类型不匹配或 runtime capability gap。

如果输出区分 `MODEL` 和 `CASCADING` 错误，先修 `MODEL` 错误。`CASCADING` 通常是上游 TM/QM 错误修复后会消失的下游症状。

## Step 4: Register Or Update Runtime Bundle

validation 通过后，把模型目录注册或更新为 runtime managed bundle：

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> bundles add --name <bundle> --path <models-dir> --watch --replace |
  Tee-Object -FilePath <evidence-dir>/12-bundles-add-update.json
```

含义：

- `--replace` 用于更新同名 bundle。
- `--watch` 用于让 Runtime 在支持时观察该目录变化。
- 这个命令不是 Git 版本管理、发布审批、审计、回滚或 RBAC。它只是在 Runtime bundle registry 中注册或更新给定模型目录。

PASS 条件：

- JSON 响应 `success=true`。
- bundle name 和 path 与目标 namespace/model directory 一致。

## Step 5: Refresh Models

bundle 注册后刷新 Runtime API query model metadata：

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models refresh |
  Tee-Object -FilePath <evidence-dir>/13-models-refresh.json
```

如果安装的 CLI 和 runtime 支持定向 refresh，可以缩小验证范围：

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models refresh --model <QueryModelName> |
  Tee-Object -FilePath <evidence-dir>/13-models-refresh-QueryModelName.json
```

PASS 条件：

- refresh 成功。
- 目标 QueryModel 出现在 refresh 输出中，或出现在后续 `models list` 和 `models describe` 结果中。

## Step 6: Describe Query Models

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models list |
  Tee-Object -FilePath <evidence-dir>/14-models-list.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models describe <QueryModelName> |
  Tee-Object -FilePath <evidence-dir>/15-models-describe-QueryModelName.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models describe <QueryModelName> --field <fieldName> |
  Tee-Object -FilePath <evidence-dir>/16-models-describe-field.json
```

query payload 只能使用 `models describe` 返回的 `fieldName`。不要从 caption、数据库原始列、旧文档或相似模型名推断字段。维度属性后缀必须严格使用 describe 返回形态，例如 `<dimension>$id`、`<dimension>$caption`，或日期粒度字段 `<dateField>$month`。

PASS 条件：

- `models list` 包含目标 QueryModel。
- `models describe <QueryModelName>` 返回 smoke 需要的字段。
- field-level describe 确认主时间字段、核心维度、核心指标和过滤字段。

## Step 7: Query Smoke

基于 describe 返回字段创建小范围 smoke payload。payload 至少覆盖：

- 一个主时间字段。
- 一个核心维度。
- 一个核心指标。
- 一个过滤条件。

CLI payload 示例，使用 `foggy-runtime-cli` 支持的 string-array `groupBy` 简写：

```json
{
  "columns": [
    "<mainTimeField>$month",
    "<coreDimensionField>",
    "sum(<coreMeasureField>) as totalMeasure"
  ],
  "groupBy": [
    "<mainTimeField>$month",
    "<coreDimensionField>"
  ],
  "slice": [
    {
      "field": "<filterField>",
      "op": "=",
      "value": "<small-scope-value>"
    }
  ],
  "limit": 20
}
```

绕过 CLI 直接调用 Runtime API v1 HTTP 的调用方，应使用 runtime 支持的 groupBy object 形态，例如：

```json
{
  "groupBy": [
    { "field": "<mainTimeField>$month" },
    { "field": "<coreDimensionField>" }
  ]
}
```

先 validate，再 execute：

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> query validate <QueryModelName> --payload <payload.json> |
  Tee-Object -FilePath <evidence-dir>/17-query-validate.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> query execute <QueryModelName> --payload <payload.json> |
  Tee-Object -FilePath <evidence-dir>/18-query-execute.json
```

没有用户明确授权时，不要对生产数据执行大范围查询。smoke 使用小时间窗口、低 limit 和窄过滤条件。遇到 `FIELD_NOT_FOUND` 时，重新执行 `models describe` 并只替换为 describe 返回字段。遇到 `MODEL_NOT_FOUND` 时，执行 `models list` 和 `models refresh`；不要静默切到相似模型。

## Step 8: MCP Service Probe

endpoint：

```text
<runtime-url>/mcp/analyst/rpc
```

使用 namespace header 探测 `tools/list`：

```powershell
$body = @{
  jsonrpc = "2.0"
  id = 1
  method = "tools/list"
  params = @{}
} | ConvertTo-Json -Depth 5

Invoke-RestMethod `
  -Method Post `
  -Uri "<runtime-url>/mcp/analyst/rpc" `
  -ContentType "application/json" `
  -Headers @{ "X-NS" = "<namespace>" } `
  -Body $body |
  ConvertTo-Json -Depth 20 |
  Tee-Object -FilePath <evidence-dir>/19-mcp-tools-list.json
```

如果 runtime 需要 auth，只使用 runtime/launcher release 文档支持的 auth header，或使用支持的 CLI auth-code flow。不要发明 token 字段。

MCP client 配置只应包含客户端支持的连接字段。通用配置中，`mcpServers` 只放 `url` 和 `headers`：

```json
{
  "mcpServers": {
    "foggy-analysis": {
      "url": "<runtime-url>/mcp/analyst/rpc",
      "headers": {
        "X-NS": "<namespace>"
      }
    }
  }
}
```

除非某个指定 MCP client 文档明确支持，否则不要把 datasource name、security mode、namespace metadata、runtime API base URL、evidence path、validation result 或其他 runtime metadata 放进 `mcpServers` entry。

PASS 条件：

- JSON-RPC 响应包含 tools list。
- 目标 runtime 的 analysis/model/query tools 存在。
- namespace header 使用 `X-NS`。

## Step 9: Publish/Update Report

输出一份包含 pass/fail 状态和 evidence path 的简洁报告：

```text
runtime URL:
namespace:
datasource name:
models-dir:
bundle name:
query model names:
capabilities summary:
datasource test result:
table inspect result:
models validate result:
bundle add/update result:
refresh result:
describe result:
query smoke result:
MCP tools/list result:
remaining assumptions:
```

每一项包含：

- PASS 或 FAIL。
- 使用的命令或 payload 文件。
- `<evidence-dir>` 下的 JSON 输出文件路径。
- 关键 ID、模型名和字段名。
- 失败时的准确 error code、phase 和 message。
- 是否有修复动作修改 TM/QM 文件、datasource binding 或 bundle registry。

## Prohibited Actions

- 不要把 Git 版本管理、审批、回滚、审计、租户治理或 RBAC 作为 Foggy Skill 必须实现的能力。
- 不要在本 runbook 中建议修改生产权限策略。
- 不要调用 private Java 或 Python endpoint。
- 不要绕过 `models validate`。
- 不要在 validation 失败时继续执行 `bundles add` 或 `models refresh`。
- 不要把 datasource 密码写进 TM/QM 文件。
- 不要把 runtime metadata 放进 MCP client 的 `mcpServers` 字段。
- 不要在没有用户明确授权时执行生产大范围查询。
