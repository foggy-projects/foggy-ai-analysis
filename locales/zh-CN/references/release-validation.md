# Release 验证

使用本 reference 验证来自公开 release 资产的正式 Skill 包。

## 约束

```text
do not use foggy-runtime-cli source checkout
do not set PYTHONPATH=src
download Skill from https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v<skill-version>
download CLI from https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v<cli-version>
download Foggy Runtime Launcher from https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/<launcher-tag>
validate all SHA256SUMS
scan the unzipped Skill for undeclared dollar-prefixed Skill references
```

使用当前待验证 release notes 中声明的 `<skill-version>`、`<cli-version>` 和 `<launcher-tag>`。validation prompt 或证据中不要残留历史版本号。

## Smoke

1. 在隔离环境安装 CLI。
2. 除非端口被占用，在 `18066` 启动 Java runtime。
3. 执行 `wait-ready` 和 `capabilities`。
4. 如果没有数据源，使用 `--use-default-datasource` 跑内置 sales-drop replay。
5. 停止 runtime，并验证端口已释放。

## 静态 Skill 引用检查

解压 Skill 后，搜索 Skill-style reference：

```powershell
rg -n --pcre2 '(?<![A-Za-z0-9_-])\$([a-z][a-z0-9]*(?:-[a-z0-9]+)+)(?![A-Za-z0-9_-])' <unzipped-skill-dir>
```

除非 package manifest 声明了额外 `skillDependencies`，否则只允许 `$foggy-ai-analysis` 自引用。任何未声明的外部 Skill 引用都会阻塞 release validation。

还需要确认 `references/semantic-layer-publish-runbook.md` 已包含在解压后的 Skill 中，并且文档自包含：

```powershell
Test-Path <unzipped-skill-dir>/references/semantic-layer-publish-runbook.md
rg -n "semantic-layer-publish-runbook.md|private Java|private Python|models validate|bundles add|models refresh|tools/list|mcpServers" <unzipped-skill-dir>/references/semantic-layer-publish-runbook.md
```

该 runbook 必须通过公开 `foggy-runtime` 命令和公开 MCP JSON-RPC endpoint 工作。不得要求未声明的外部 Skill、绕过 `models validate`，或把 runtime metadata 放入 MCP client 的 `mcpServers`。

报告命令、输出、端口、checksum、失败点和修复动作。
