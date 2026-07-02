# Feedback

Use this reference when the user reports a bug, confusing behavior, or optimization request.

## Collect

Record:

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

Remove secrets, private hostnames, auth codes, customer rows, and production credentials.

## Where To File Issues

Choose the repository by the component that most likely owns the failure:

| Repository | Use for |
| --- | --- |
| `foggy-projects/foggy-ai-analysis` | Skill packaging, Skill instructions, bundled demo assets, onboarding docs, GitHub issue template, release validation instructions, and unclear routing. |
| `foggy-projects/foggy-runtime-cli` | CLI installation, argument parsing, command behavior, request or response formatting, exit codes, and command UX. |
| `foggy-projects/foggy-data-mcp-bridge` | Java runtime, Runtime API, Java launcher, MCP JSON-RPC endpoint, MCP tool execution, datasource/model loader, model catalog or `dataset.list_models`, query validation, and query execution. |
| `foggy-projects/foggy-ai-analysis-demo` | Legacy demo-only Skill package issues, if that package is still in use. |

Direct issue URLs:

```text
https://github.com/foggy-projects/foggy-ai-analysis/issues/new
https://github.com/foggy-projects/foggy-runtime-cli/issues/new
https://github.com/foggy-projects/foggy-data-mcp-bridge/issues/new
https://github.com/foggy-projects/foggy-ai-analysis-demo/issues/new
```

If ownership is unclear, file the issue in `foggy-projects/foggy-ai-analysis` with the evidence below and label it as a routing question. Maintainers can redirect it after triage.

For engine-specific issues in `foggy-projects/foggy-data-mcp-bridge`, include runtime `capabilities`, Java launcher release, source commit from the launcher manifest if available, namespace, datasource mode, MCP request/response snippets when relevant, model names, and the exact CLI or MCP operation that failed.

## Report Shape

Use `assets/github-issue-template.md` for a bug or optimization issue. Include a minimal reproduction path and whether the issue is:

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
