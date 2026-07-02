# 反馈

当用户报告 BUG、困惑行为或优化请求时，使用本 reference。

## 收集信息

记录：

```text
CLI version
Skill version and download URL
Java launcher version
runtime URL and port
namespace
securityMode
datasource mode
SQLite path or sanitized datasource type
commands run
exit codes
key output files
runtime logs
question-bank summary if relevant
```

移除 secret、私有 hostname、auth code、客户行数据和生产 credential。

## Issue 应提交到哪里

根据最可能负责该失败的组件选择仓库：

| Repository | 适用范围 |
| --- | --- |
| `foggy-projects/foggy-ai-analysis` | Skill packaging、Skill instructions、内置 demo assets、onboarding docs、GitHub issue template、release validation instructions，以及不清楚归属的 routing。 |
| `foggy-projects/foggy-runtime-cli` | CLI 安装、参数解析、命令行为、request/response formatting、exit code 和 command UX。 |
| `foggy-projects/foggy-data-mcp-bridge` | Java runtime、Runtime API、Java launcher、MCP JSON-RPC endpoint、MCP tool execution、datasource/model loader、model catalog 或 `dataset.list_models`、query validation 和 query execution。 |
| `foggy-projects/foggy-ai-analysis-demo` | 仍在使用 legacy demo-only Skill package 时的相关问题。 |

直接 issue URL：

```text
https://github.com/foggy-projects/foggy-ai-analysis/issues/new
https://github.com/foggy-projects/foggy-runtime-cli/issues/new
https://github.com/foggy-projects/foggy-data-mcp-bridge/issues/new
https://github.com/foggy-projects/foggy-ai-analysis-demo/issues/new
```

如果归属不清楚，将 issue 提到 `foggy-projects/foggy-ai-analysis`，附上下面的证据，并标注为 routing question。维护者 triage 后可以 redirect。

对于 `foggy-projects/foggy-data-mcp-bridge` 中的 engine-specific 问题，需要包含 runtime `capabilities`、Java launcher release、launcher manifest 中的 source commit（如果可用）、namespace、datasource mode、相关 MCP request/response 片段、model name，以及失败的精确 CLI 或 MCP operation。

## 报告形态

BUG 或优化 issue 使用 `assets/github-issue-template.md`。包含最小复现路径，并说明 issue 类型：

```text
installation
runtime startup
datasource discovery
TM/QM validation
query validation
query execution
question-bank quality
MCP IDE connection
documentation
routing question
runtime API
MCP JSON-RPC endpoint
model catalog/list_models
```
