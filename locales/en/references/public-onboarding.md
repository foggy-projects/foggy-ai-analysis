# Public Onboarding

Use this reference when a user wants the formal public Foggy AI analysis Skill package and a local dev/test runtime.

## Formal Download Links

Current formal Skill package. Replace `<skill-version>` with the release version without the leading `v`, and install paired Skills from the same release unless release notes say otherwise:

```text
Skill release=https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v<skill-version>
Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-ai-analysis-skill-<skill-version>.zip
Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-ai-analysis-skill-<skill-version>-manifest.json
Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-ai-analysis-skill-<skill-version>-SHA256SUMS
Semantic Query Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-semantic-query-skill-<skill-version>.zip
Semantic Query Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-semantic-query-skill-<skill-version>-manifest.json
Semantic Query Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-semantic-query-skill-<skill-version>-SHA256SUMS
```

Runtime components. Use the CLI and launcher versions listed in the same release notes:

```text
CLI release=https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v<cli-version>
Foggy Runtime Launcher release=https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/<launcher-tag>
Default runtime URL=http://127.0.0.1:18066
Default namespace=salesdrop
```

## Official Public Docs

The Skill is self-contained for install, demo replay, datasource onboarding, and basic TM/QM modeling. Use the public docs as the deeper contract reference when a user asks for full syntax, compatibility, or advanced modeling details:

```text
Foggy docs=https://foggy-projects.github.io/foggy-data-mcp-docs/en/
Whitepaper v1.0=https://foggy-projects.github.io/foggy-data-mcp-docs/en/whitepaper/v1.0/
TM/QM syntax reference=https://foggy-projects.github.io/foggy-data-mcp-docs/en/whitepaper/v1.0/semantic-layer-syntax-reference.html
Query DSL syntax reference=https://foggy-projects.github.io/foggy-data-mcp-docs/en/whitepaper/v1.0/query-dsl-syntax-reference.html
```

Do not block onboarding on those pages. Runtime behavior must still be verified with `capabilities`, `models validate`, `models describe`, and query validation.

## Install CLI

Windows PowerShell:

```powershell
$version = "<cli-version>"
$download = Join-Path $env:TEMP "foggy-runtime-cli-install-$version"
New-Item -ItemType Directory -Force -Path $download | Out-Null
Invoke-WebRequest "https://github.com/foggy-projects/foggy-runtime-cli/releases/download/v$version/install-foggy-runtime-cli.ps1" -OutFile (Join-Path $download "install-foggy-runtime-cli.ps1")
powershell -ExecutionPolicy Bypass -File (Join-Path $download "install-foggy-runtime-cli.ps1") -Version $version
foggy-runtime --version
```

Linux or macOS:

```bash
version="<cli-version>"
download="${TMPDIR:-/tmp}/foggy-runtime-cli-install-$version"
mkdir -p "$download"
curl -fsSL "https://github.com/foggy-projects/foggy-runtime-cli/releases/download/v$version/install-foggy-runtime-cli.sh" -o "$download/install-foggy-runtime-cli.sh"
bash "$download/install-foggy-runtime-cli.sh" --version "$version"
foggy-runtime --version
```

## Install Skill

Download the `foggy-ai-analysis` Skill zip from the formal release links above, then install it into the agent Skill directory:

```powershell
$skillVersion = "<skill-version>"
foggy-runtime skills install foggy-ai-analysis --zip ".\foggy-ai-analysis-skill-$skillVersion.zip" --replace
```

The CLI installs only to:

```text
~/.agents/skills/foggy-ai-analysis
```

It does not install copies under `~/.codex/skills` or `~/.claude/skills`.

If existing-model query DSL, composeScript, or restricted Compose/CTE query work is needed, install the paired query Skill from the same release:

```powershell
$skillVersion = "<skill-version>"
foggy-runtime skills install foggy-semantic-query --zip ".\foggy-semantic-query-skill-$skillVersion.zip" --replace
```

Local workspace installs are maintainer-only and must not be used in public onboarding. Public users should install release zip assets.

## Start Runtime

Download and verify the Foggy Runtime Launcher release assets from `<launcher-tag>`. Extract them to any local directory and start the runtime on port `18066` unless occupied. Do not require a maintainer workspace path for public onboarding.

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
