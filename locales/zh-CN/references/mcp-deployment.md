# MCP 部署

当用户询问如何运行或部署 Foggy runtime/MCP 服务时使用本 reference，包括 JAR、Docker、Odoo gateway、namespace header 或外部模型 bundle。

首次本地 onboarding 先读 `public-onboarding.md`。服务已运行后需要 IDE/client 配置时，再读 `mcp-ide-connection.md`。

## 边界

- 公开 dev/test onboarding 优先使用已验证的 Foggy Runtime Launcher JAR 路径。
- Docker image 名称、tag、端口和环境变量都按具体 release 文档确认；未确认前只给模板，不声称具体镜像可用。
- 生产 auth、RBAC、审计、治理和租户级 datasource ownership 不在本 Skill 实现范围。
- 每次启动后都运行 `wait-ready` 和 `capabilities`；不要假设某个 profile 一定暴露 Runtime API 或 MCP。
- 输出 MCP client 配置前，先 probe analyst MCP JSON-RPC endpoint。

## JAR Runtime

以显式端口启动 Java launcher，并打开 Runtime API。本地 SQLite onboarding 时，runtime 使用的 SQLite 文件应与 CLI replay 或用户 workflow 使用的文件一致：

```powershell
java -Dfile.encoding=UTF-8 -jar <launcher-jar> `
  --server.port=18066 `
  --spring.profiles.active=lite `
  --foggy.runtime-api.enabled=true `
  --spring.datasource.url=jdbc:sqlite:<sqlite-db-path>
```

随后验证：

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 --namespace <ns> wait-ready --timeout-seconds 90
foggy-runtime --base-url http://127.0.0.1:18066 --namespace <ns> capabilities
```

如果 `securityMode=auth-code`，传入 `--auth-code` 或设置 `FOGGY_RUNTIME_API_AUTH_CODE`。

## Profiles

- `lite`：公开本地 onboarding 的默认 profile，用于 Runtime API 和 JDBC/SQLite smoke。
- `lite,odoo`：Odoo 模型 bundle 或上游 Odoo Bridge gateway 场景。namespace 按上游版本隔离规则显式使用，例如 `odoo`、`odoo17` 或 `odoo18`。
- full/default profile：只有 release 或源码项目明确记录用户需要的 demo/data-viewer 组件时才使用。

最终输出需记录 profile、runtime URL、namespace、datasource mode 和 `securityMode`。

## Docker

只有选定 release 已发布并记录 Docker image 时才给具体 Docker 命令。否则给模板：

```powershell
docker run --rm -p 18066:18066 `
  -e SPRING_PROFILES_ACTIVE=lite `
  -e FOGGY_RUNTIME_API_ENABLED=true `
  -e SPRING_DATASOURCE_URL=jdbc:sqlite:/data/runtime.sqlite `
  -v <host-data-dir>:/data `
  <image>:<tag>
```

容器启动后，同样执行 JAR 模式下的 `wait-ready`、`capabilities` 和 MCP endpoint probe。

## MCP Endpoint 与 Namespace

analyst endpoint 通常为：

```text
http://127.0.0.1:18066/mcp/analyst/rpc
```

用 `X-NS` 实现 namespace 隔离：

```powershell
$body = @{ jsonrpc = "2.0"; id = 1; method = "tools/list"; params = @{} } | ConvertTo-Json -Depth 5
Invoke-RestMethod -Method Post `
  -Uri "http://127.0.0.1:18066/mcp/analyst/rpc" `
  -Headers @{ "X-NS" = "<ns>" } `
  -Body $body `
  -ContentType "application/json"
```

如果 runtime 需要 auth，只使用 release 支持的 auth header 或 CLI auth-code 流程；不要发明 token 字段。

## 外部模型 Bundle

Runtime API 管理的 bundle 优先使用 CLI：

```powershell
foggy-runtime --base-url <url> --namespace <ns> bundles add --name <bundle> --path <models-dir> --watch --replace
foggy-runtime --base-url <url> --namespace <ns> models validate --models-dir <models-dir>
foggy-runtime --base-url <url> --namespace <ns> models refresh
```

Spring 内嵌配置中，外部 bundle 通常使用：

```yaml
foggy:
  bundle:
    external:
      enabled: true
      bundles:
        - name: my-models
          namespace: dev
          path: /data/my-models
          watch: true
```

添加 bundle 后继续使用 runtime CLI describe/query loop 验证。不要仅凭文件存在就认定模型已加载。
