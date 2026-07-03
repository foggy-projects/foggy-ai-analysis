# 公开 Onboarding

当用户需要正式公开版 Foggy AI analysis Skill 包和本地 dev/test runtime 时，使用本 reference。

## 正式下载链接

当前正式 Skill 包：

```text
Skill release=https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v0.1.6
Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.6/foggy-ai-analysis-skill-0.1.6.zip
Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.6/foggy-ai-analysis-skill-0.1.6-manifest.json
Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.6/foggy-ai-analysis-skill-0.1.6-SHA256SUMS
Semantic Query Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.6/foggy-semantic-query-skill-0.1.6.zip
Semantic Query Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.6/foggy-semantic-query-skill-0.1.6-manifest.json
Semantic Query Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.6/foggy-semantic-query-skill-0.1.6-SHA256SUMS
```

Runtime components:

```text
CLI release=https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v0.1.11
Java launcher release=https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/runtime-api-launcher-v0.1.3
Default runtime URL=http://127.0.0.1:18066
Default namespace=salesdrop
```

## 安装 CLI

Windows PowerShell：

```powershell
$version = "0.1.11"
$download = Join-Path $env:TEMP "foggy-runtime-cli-install-$version"
New-Item -ItemType Directory -Force -Path $download | Out-Null
Invoke-WebRequest "https://github.com/foggy-projects/foggy-runtime-cli/releases/download/v$version/install-foggy-runtime-cli.ps1" -OutFile (Join-Path $download "install-foggy-runtime-cli.ps1")
powershell -ExecutionPolicy Bypass -File (Join-Path $download "install-foggy-runtime-cli.ps1") -Version $version
foggy-runtime --version
```

Linux 或 macOS：

```bash
version="0.1.11"
download="${TMPDIR:-/tmp}/foggy-runtime-cli-install-$version"
mkdir -p "$download"
curl -fsSL "https://github.com/foggy-projects/foggy-runtime-cli/releases/download/v$version/install-foggy-runtime-cli.sh" -o "$download/install-foggy-runtime-cli.sh"
bash "$download/install-foggy-runtime-cli.sh" --version "$version"
foggy-runtime --version
```

## 安装 Skill

从上面的正式 release 链接下载 `foggy-ai-analysis` Skill zip，然后安装到 agent Skill 目录：

```powershell
foggy-runtime skills install foggy-ai-analysis --zip .\foggy-ai-analysis-skill-0.1.6.zip --replace
```

CLI 只安装到：

```text
~/.agents/skills/foggy-ai-analysis
```

不会安装或更新 `~/.codex/skills`、`~/.claude/skills` 下的副本。

如果需要已有模型上的 query DSL、composeScript 或受限 Compose/CTE 查询工作，从同一个 release 安装配套查询 Skill：

```powershell
foggy-runtime skills install foggy-semantic-query --zip .\foggy-semantic-query-skill-0.1.6.zip --replace
```

维护者使用本地 workspace 时，可以一次安装两个 Skill：

```powershell
foggy-runtime skills install foggy-analysis-suite --workspace-root D:\foggy-projects\foggy-data-mcp --replace
```

## 启动 Runtime

从 `runtime-api-launcher-v0.1.3` 下载并验证 Java launcher release 资产。除非端口被占用，默认在 `18066` 启动 runtime。只有维护者工作站明确需要本地 debug 路径时，才使用：

```text
D:\foggy-projects\foggy-data-mcp\foggy-data-mcp-bridge-wt-dev-compose\foggy-mcp-launcher
```

启动后：

```powershell
foggy-runtime --base-url http://127.0.0.1:18066 wait-ready --timeout-seconds 60
foggy-runtime --base-url http://127.0.0.1:18066 capabilities
```

记录 `securityMode`。如果值为 `auth-code`，需要提供 `--auth-code` 或设置 `FOGGY_RUNTIME_API_AUTH_CODE`。

## 没有数据源

如果用户没有数据源，继续执行 `sales-drop-example.md`。该示例使用 runtime 默认 SQLite 文件和内置资产。

## 用户数据源

如果用户提供 SQLite 文件或其他数据源，继续执行 `datasource-and-semantic-modeling.md`。

## 部署变体

如果用户询问 JAR 部署、Docker、Odoo gateway mode、namespace header 或外部模型 bundle，继续执行 `mcp-deployment.md`。
