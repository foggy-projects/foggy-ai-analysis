# Public Onboarding

Use this reference when a user wants the formal public Foggy AI analysis Skill package and a local dev/test runtime.

## Formal Download Links

Current formal Skill package:

```text
Skill release=https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v0.1.4
Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.4/foggy-ai-analysis-skill-0.1.4.zip
Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.4/foggy-ai-analysis-skill-0.1.4-manifest.json
Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.4/foggy-ai-analysis-skill-0.1.4-SHA256SUMS
```

Runtime components:

```text
CLI release=https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v0.1.9
Java launcher release=https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/runtime-api-launcher-v0.1.2
Default runtime URL=http://127.0.0.1:18066
Default namespace=salesdrop
```

The previous demo-only Skill remains available at:

```text
https://github.com/foggy-projects/foggy-ai-analysis-demo/releases/tag/v0.1.6
```

## Install CLI

Windows PowerShell:

```powershell
$version = "0.1.9"
$download = Join-Path $env:TEMP "foggy-runtime-cli-install-$version"
New-Item -ItemType Directory -Force -Path $download | Out-Null
Invoke-WebRequest "https://github.com/foggy-projects/foggy-runtime-cli/releases/download/v$version/install-foggy-runtime-cli.ps1" -OutFile (Join-Path $download "install-foggy-runtime-cli.ps1")
powershell -ExecutionPolicy Bypass -File (Join-Path $download "install-foggy-runtime-cli.ps1") -Version $version
foggy-runtime --version
```

Linux or macOS:

```bash
version="0.1.9"
download="${TMPDIR:-/tmp}/foggy-runtime-cli-install-$version"
mkdir -p "$download"
curl -fsSL "https://github.com/foggy-projects/foggy-runtime-cli/releases/download/v$version/install-foggy-runtime-cli.sh" -o "$download/install-foggy-runtime-cli.sh"
bash "$download/install-foggy-runtime-cli.sh" --version "$version"
foggy-runtime --version
```

## Start Runtime

Download and verify the Java launcher release assets from `runtime-api-launcher-v0.1.2`. Start the runtime on port `18066` unless occupied. If a local debug path is explicitly needed on the maintainer workstation, use:

```text
D:\foggy-projects\foggy-data-mcp\foggy-data-mcp-bridge-wt-dev-compose\foggy-mcp-launcher
```

After start:

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 wait-ready --timeout-seconds 60
foggy-runtime --base-url http://127.0.0.1:18066 capabilities
```

Record `securityMode`. If it is `auth-code`, provide `--auth-code` or `FOGGY_RUNTIME_API_AUTH_CODE`.

## No Datasource

If the user has no datasource, continue with `sales-drop-example.md`. The example uses the runtime default SQLite file and bundled assets.

## User Datasource

If the user provides a SQLite file or another datasource, continue with `datasource-and-semantic-modeling.md`.

## Deployment Variants

If the user asks about JAR deployment, Docker, Odoo gateway mode, namespace headers, or external model bundles, continue with `mcp-deployment.md`.
