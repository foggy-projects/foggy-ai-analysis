# MCP Deployment

Use this reference when a user asks how to run or deploy the Foggy runtime/MCP service, including JAR, Docker, Odoo gateway, namespace headers, or external model bundles.

For first local onboarding, read `public-onboarding.md` first. For IDE/client configuration after the service is running, read `mcp-ide-connection.md`.

## Boundaries

- Prefer the validated Java Runtime API launcher JAR path for public dev/test onboarding.
- Treat Docker image names, tags, ports, and environment variables as release-specific until verified from the selected release notes.
- Keep production auth, RBAC, audit, governance, and tenant datasource ownership out of this skill's implementation scope.
- After every startup, run `wait-ready` and `capabilities`; do not assume a profile exposes Runtime API or MCP.
- Probe the analyst MCP JSON-RPC endpoint before giving client config.

## JAR Runtime

Start the Java launcher on an explicit port with Runtime API enabled. For local SQLite onboarding, use the same SQLite file that the CLI replay or user workflow will inspect:

```powershell
java -Dfile.encoding=UTF-8 -jar <launcher-jar> `
  --server.port=18066 `
  --spring.profiles.active=lite `
  --foggy.runtime-api.enabled=true `
  --spring.datasource.url=jdbc:sqlite:<sqlite-db-path>
```

Then verify:

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 --namespace <ns> wait-ready --timeout-seconds 90
foggy-runtime --base-url http://127.0.0.1:18066 --namespace <ns> capabilities
```

If `securityMode=auth-code`, pass `--auth-code` or set `FOGGY_RUNTIME_API_AUTH_CODE`.

## Profiles

- `lite`: default public onboarding profile for local Runtime API and JDBC/SQLite smoke work.
- `lite,odoo`: gateway-style profile for Odoo-oriented model bundles or upstream Odoo Bridge integration. Use an explicit Odoo namespace such as `odoo`, `odoo17`, or `odoo18` according to the upstream project's versioning rule.
- Full/default profile: use only when the release or source project documents the included demo/data-viewer components needed by the user.

Record the profile, runtime URL, namespace, datasource mode, and `securityMode` in the final output.

## Docker

Use Docker only when the selected release publishes and documents an image. If the release documentation is not available, provide a template instead of a concrete image claim:

```powershell
docker run --rm -p 18066:18066 `
  -e SPRING_PROFILES_ACTIVE=lite `
  -e FOGGY_RUNTIME_API_ENABLED=true `
  -e SPRING_DATASOURCE_URL=jdbc:sqlite:/data/runtime.sqlite `
  -v <host-data-dir>:/data `
  <image>:<tag>
```

After container startup, run the same `wait-ready`, `capabilities`, and MCP endpoint probe used for JAR startup.

## MCP Endpoint And Namespace

The analyst endpoint is normally:

```text
http://127.0.0.1:18066/mcp/analyst/rpc
```

Use `X-NS` for namespace isolation:

```powershell
$body = @{ jsonrpc = "2.0"; id = 1; method = "tools/list"; params = @{} } | ConvertTo-Json -Depth 5
Invoke-RestMethod -Method Post `
  -Uri "http://127.0.0.1:18066/mcp/analyst/rpc" `
  -Headers @{ "X-NS" = "<ns>" } `
  -Body $body `
  -ContentType "application/json"
```

If the runtime requires auth, include the release-supported auth header or CLI auth-code flow; do not invent a token field.

## External Model Bundles

For Runtime API managed bundles, prefer CLI commands:

```powershell
foggy-runtime --base-url <url> --namespace <ns> bundles add --name <bundle> --path <models-dir> --watch --replace
foggy-runtime --base-url <url> --namespace <ns> models validate --models-dir <models-dir>
foggy-runtime --base-url <url> --namespace <ns> models refresh
```

For embedded Spring configuration, external bundles usually follow this shape:

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

Use the runtime CLI describe/query loop after adding a bundle. Do not rely on file presence alone as proof that models loaded.
