# MCP IDE 连接

当用户希望 IDE 或支持 MCP 的客户端连接本地 Foggy runtime 时，使用本 reference。

## 前置条件

运行：

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 wait-ready --timeout-seconds 60
foggy-runtime --base-url http://127.0.0.1:18066 capabilities
```

记录 runtime URL 和 `securityMode`。

## Endpoint

当前 Java launcher 在同一端口暴露 Runtime API 和 analyst MCP JSON-RPC endpoint：

```text
Runtime API=http://127.0.0.1:18066/api/v1
MCP analyst JSON-RPC=http://127.0.0.1:18066/mcp/analyst/rpc
```

给出 IDE 配置前，先探测 MCP endpoint：

```powershell
$body = @{
  jsonrpc = "2.0"
  id = 1
  method = "tools/list"
  params = @{}
} | ConvertTo-Json -Depth 5
Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:18066/mcp/analyst/rpc" -Body $body -ContentType "application/json"
```

不要承诺未验证的 `/mcp`、`/sse`、`/messages` 或 stdio endpoint。

## 严格 MCP Client Config

不要把 runtime validation metadata 放进 `mcpServers`。除非用户指定某个 MCP client schema，否则 `mcpServers` 仅包含客户端支持的字段，例如 `url` 和 `headers`。

默认通用 MCP client config：

```json
{
  "mcpServers": {
    "foggy-ai-analysis": {
      "url": "http://127.0.0.1:18066/mcp/analyst/rpc",
      "headers": {
        "X-NS": "salesdrop"
      }
    }
  }
}
```

如果目标客户端明确要求 transport 或 type 字段，将其作为单独的可选变体提供：

```json
{
  "mcpServers": {
    "foggy-ai-analysis": {
      "type": "http",
      "url": "http://127.0.0.1:18066/mcp/analyst/rpc",
      "headers": {
        "X-NS": "salesdrop"
      }
    }
  }
}
```

除非指定 MCP client 文档明确支持，否则不要把以下 runtime 或 validation 字段放进 `mcpServers`：

- `dataSource`
- `security`
- `namespace`
- `runtimeApiBaseUrl`
- `endpoint`
- `env`
- `sqlitePath`
- `datasourceMode`
- `evidenceDir`
- `validationResult`

在 MCP client configuration 后，单独报告 Runtime URL、datasource mode、SQLite path、`securityMode`、evidence directory 和 validation results。
