# 公开 Onboarding

当用户需要正式公开版 Foggy AI analysis Skill 包和本地 dev/test runtime 时，使用本 reference。

## 正式下载链接

当前正式 Skill 包。将 `<skill-version>` 替换为去掉前导 `v` 的 release version；除非 release notes 另有说明，两个 Skill 使用同一个 release：

```text
Skill release=https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v<skill-version>
Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-ai-analysis-skill-<skill-version>.zip
Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-ai-analysis-skill-<skill-version>-manifest.json
Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-ai-analysis-skill-<skill-version>-SHA256SUMS
Semantic Query Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-semantic-query-skill-<skill-version>.zip
Semantic Query Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-semantic-query-skill-<skill-version>-manifest.json
Semantic Query Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v<skill-version>/foggy-semantic-query-skill-<skill-version>-SHA256SUMS
```

Runtime components。使用同一 release notes 中列出的 CLI 和 launcher 版本：

```text
CLI release=https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v<cli-version>
Foggy Runtime Launcher release=https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/<launcher-tag>
Default runtime URL=http://127.0.0.1:18066
Default namespace=salesdrop
```

## 官方公开文档

Skill 包对安装、demo replay、数据源 onboarding 和基础 TM/QM 建模保持自包含。用户询问完整语法、兼容性或高级建模细节时，把公开文档作为更完整的契约参考：

```text
Foggy 文档=https://foggy-projects.github.io/foggy-data-mcp-docs/zh/
白皮书 v1.0=https://foggy-projects.github.io/foggy-data-mcp-docs/zh/whitepaper/v1.0/
TM/QM 语法参考=https://foggy-projects.github.io/foggy-data-mcp-docs/zh/whitepaper/v1.0/semantic-layer-syntax-reference.html
Query DSL 语法参考=https://foggy-projects.github.io/foggy-data-mcp-docs/zh/whitepaper/v1.0/query-dsl-syntax-reference.html
```

不要把这些页面作为 onboarding 的阻塞条件。Runtime 行为仍必须通过 `capabilities`、`models validate`、`models describe` 和 query validation 验证。

## 安装 CLI

Windows PowerShell：

```powershell
$version = "<cli-version>"
$download = Join-Path $env:TEMP "foggy-runtime-cli-install-$version"
New-Item -ItemType Directory -Force -Path $download | Out-Null
Invoke-WebRequest "https://github.com/foggy-projects/foggy-runtime-cli/releases/download/v$version/install-foggy-runtime-cli.ps1" -OutFile (Join-Path $download "install-foggy-runtime-cli.ps1")
powershell -ExecutionPolicy Bypass -File (Join-Path $download "install-foggy-runtime-cli.ps1") -Version $version
foggy-runtime --version
```

Linux 或 macOS：

```bash
version="<cli-version>"
download="${TMPDIR:-/tmp}/foggy-runtime-cli-install-$version"
mkdir -p "$download"
curl -fsSL "https://github.com/foggy-projects/foggy-runtime-cli/releases/download/v$version/install-foggy-runtime-cli.sh" -o "$download/install-foggy-runtime-cli.sh"
bash "$download/install-foggy-runtime-cli.sh" --version "$version"
foggy-runtime --version
```

## 安装 Skill

从上面的正式 release 链接下载 `foggy-ai-analysis` Skill zip，然后安装到 agent Skill 目录：

```powershell
$skillVersion = "<skill-version>"
foggy-runtime skills install foggy-ai-analysis --zip ".\foggy-ai-analysis-skill-$skillVersion.zip" --replace
```

CLI 只安装到：

```text
~/.agents/skills/foggy-ai-analysis
```

不会安装或更新 `~/.codex/skills`、`~/.claude/skills` 下的副本。

如果需要已有模型上的 query DSL、composeScript 或受限 Compose/CTE 查询工作，从同一个 release 安装配套查询 Skill：

```powershell
$skillVersion = "<skill-version>"
foggy-runtime skills install foggy-semantic-query --zip ".\foggy-semantic-query-skill-$skillVersion.zip" --replace
```

本地 workspace 安装只属于维护者内部调试路径，不能放进公开 onboarding。公开用户应安装 release zip 资产。

## 启动 Runtime

从 `<launcher-tag>` 下载并验证 Foggy Runtime Launcher release 资产。解压到任意本地目录；除非端口被占用，默认在 `18066` 启动 runtime。公开 onboarding 不要求维护者 workspace 路径。

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
