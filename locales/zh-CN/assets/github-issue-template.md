## 摘要

<!-- 用一句话描述 BUG 或优化请求。 -->

## Issue 归属

<!--
选择最可能的 owner：

- foggy-projects/foggy-ai-analysis:
  Skill packaging、Skill instructions、内置 demo assets、onboarding docs、GitHub issue template、release validation instructions，或归属不清楚的 routing。
- foggy-projects/foggy-runtime-cli:
  CLI 安装、参数解析、命令行为、request/response formatting、exit code 或 command UX。
- foggy-projects/foggy-data-mcp-bridge:
  Java runtime、Runtime API、Java launcher、MCP JSON-RPC endpoint、MCP tool execution、datasource/model loader、model catalog 或 dataset.list_models、query validation 或 query execution。
- foggy-projects/foggy-ai-analysis-demo:
  如果仍在使用 legacy demo-only Skill package，则相关问题提交到这里。

直接 issue URL：
- https://github.com/foggy-projects/foggy-ai-analysis/issues/new
- https://github.com/foggy-projects/foggy-runtime-cli/issues/new
- https://github.com/foggy-projects/foggy-data-mcp-bridge/issues/new
- https://github.com/foggy-projects/foggy-ai-analysis-demo/issues/new
-->

- 选择的仓库：
- Issue 类型：
- 如果归属不确定，说明原因：

## 环境

- OS:
- Java:
- Maven:
- Python:
- Repo commit:
- Branch:
- Runtime URL:
- Namespace:
- Runtime securityMode:
- CLI release:
- Skill release:
- Java launcher release:
- Datasource mode:
- SQLite path:
- Launcher legacyDatasourceConfigDir，如有：

## 复现步骤

1.
2.
3.

## 期望结果

## 实际结果

## 证据

- `capabilities`:
- `wait-ready`:
- `tables list`:
- `tables inspect`:
- `models validate`:
- `models refresh`:
- `models describe`:
- `query validate`:
- `query execute`:

## 附件或片段

<!-- 可用时包含脱敏后的 TM/QM、query payload、CLI JSON、summary.json、question-bank-replay.json、command-status.json、runtime.out.log、runtime.err.log 和 runtime-log-classification.json。不要包含 secret 或客户数据。 -->

## MCP IDE 细节，如相关

- Endpoint:
- Transport:
- Headers supported:
- `initialize` result:
- `tools/list` result:

## 备注

生产权限、认证和治理不在 demo flow 范围内，应作为单独的 production-readiness 项跟踪。
