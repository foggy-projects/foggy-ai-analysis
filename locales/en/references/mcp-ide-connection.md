# MCP IDE Connection

Use this reference when a user wants an IDE or MCP-capable client to connect to the local Foggy runtime.

## Preconditions

Run:

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 wait-ready --timeout-seconds 60
foggy-runtime --base-url http://127.0.0.1:18066 capabilities
```

Record the runtime URL and `securityMode`.

## Endpoint

The current Java launcher exposes Runtime API and an analyst MCP JSON-RPC endpoint on the same port:

```text
Runtime API=http://127.0.0.1:18066/api/v1
MCP analyst JSON-RPC=http://127.0.0.1:18066/mcp/analyst/rpc
```

Probe the MCP endpoint before giving IDE configuration:

```powershell
$body = @{
  jsonrpc = "2.0"
  id = 1
  method = "tools/list"
  params = @{}
} | ConvertTo-Json -Depth 5
Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:18066/mcp/analyst/rpc" -Body $body -ContentType "application/json"
```

Do not promise unverified `/mcp`, `/sse`, `/messages`, or stdio endpoints.

## Strict MCP Client Config

Do not include runtime validation metadata inside `mcpServers`. Keep `mcpServers` limited to client-supported fields such as `url` and `headers` unless the user names a specific MCP client schema.

Default generic MCP client config:

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

If the target client explicitly requires a transport or type field, provide it as a separate optional variant:

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

Do not place these runtime or validation fields inside `mcpServers` unless the named MCP client documentation explicitly supports them:

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

Report Runtime URL, datasource mode, SQLite path, `securityMode`, evidence directory, and validation results separately after the MCP client configuration.
