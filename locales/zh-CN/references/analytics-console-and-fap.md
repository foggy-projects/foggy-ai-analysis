# 内嵌 Analytics Console 与可选 FAP

用户询问 Analytics Console 是否随标准 Launcher 发布、是否要独立安装、如何启用，或它与
FAP 如何集成时，使用本 reference。

## Release 能力检查

不要根据 JAR 文件名推断 Console 能力。读取 `runtime-launcher-manifest.json`，并要求：

```text
features.analyticsConsole.embedded=true
features.analyticsConsole.enabledByDefault=false
features.analyticsConsole.springProfile=analytics-console
features.analyticsConsole.fapEnabledByDefault=false
```

标准 Launcher 从 `0.1.18` 开始内嵌 Console。更早版本不支持新的启动脚本开关。先通过稳定
栈解析目标 Release，但最终仍以该 Release Manifest 为能力合同。

## 安装与启用

只要 Manifest 声明该能力，Console 后端和预构建 SPA 已经位于可执行 JAR 内。用户不需要
安装 Node.js、npm、Web Server 或独立 Console 压缩包。

Console 只作为本地 dev/test 显式 opt-in。PowerShell：

```powershell
$start = .\start-foggy-runtime.ps1 -Port 18066 -AnalyticsConsole | ConvertFrom-Json
foggy-runtime --base-url $start.runtimeUrl wait-ready --timeout-seconds 90
foggy-runtime --base-url $start.runtimeUrl capabilities
```

Bash：

```bash
ANALYTICS_CONSOLE_ENABLED=true PORT=18066 ./start-foggy-runtime.sh
foggy-runtime --base-url http://127.0.0.1:18066 wait-ready --timeout-seconds 90
foggy-runtime --base-url http://127.0.0.1:18066 capabilities
```

随后验证：

```text
Console Web=http://127.0.0.1:18066/analytics-console/
Console 产品 API=http://127.0.0.1:18066/analytics-console/api/v1
Analytics Runtime API=http://127.0.0.1:18066/analytics/api/v1
```

默认启动没有 `-AnalyticsConsole` 或 `ANALYTICS_CONSOLE_ENABLED=true` 时，这三个路由都必须
不可用。除非调用方显式覆盖，启动脚本把 Console Catalog 和 Function trace 保存在 Runtime
工作目录下。

直接使用 CLI 检查 Analytics lane 时，使用独立 Base URL 和身份合同：

```bash
FOGGY_ANALYTICS_RUNTIME_API_URL=http://127.0.0.1:18066/analytics \
  foggy analytics capabilities
```

不要通过 Foggy Runtime API 环境变量传递 Analytics 凭证；两套客户端使用不同的环境变量和
authority 合同。

## FAP 集成边界

Launcher 不包含 FAP。Console shell、Catalog 和直连 Analytics Runtime lane 都不依赖 FAP。
未配置时应显示 `FAP NOT CONFIGURED`，浏览器不得回退为直接访问 LLM。

启用 FAP 是独立、需显式授权的宿主部署操作。宿主负责提供：

- FAP Service Provider Base URL 和服务端授权；
- opaque workspace/model/provider binding；
- 已发布的问题 Skill、Capability，以及带匹配 Schema Delivery 的五个 Analytics FunctionRef；
- callback capability binding 与授权；
- 生产环境宿主管理的 Console subject/authority resolver。

Launcher 启动过程不得创建、更新、重试发布或修复这些 FAP 资源。JAR 内的问题 Skill 与
Function Delivery 是独立 FAP 发布工作流的不可变 Release 输入。凭证与 binding 不得进入
Launcher Manifest、Console Catalog、浏览器 payload 或日志。

在 Foggy 源码部署中，宿主 publisher 必须从
`FapAnalyticsQuestionFunctionCatalog.publicationValues()` 序列化 exact 五项 projection，并在自己的
dry-run/apply 前使用
`foggy-data-mcp-bridge/scripts/release/fap_question_publication_gate.py` 校验导出内容。校验通过只表示
FunctionRef、Schema 和 canonical digest 与 Release 一致；门禁始终返回 `mutationPerformed=false`，不含
FAP 凭据或 apply 模式。追加 immutable Function、Skill、Capability revision 仍由认证后的 FAP 宿主管理
client 完成。已发布的 Launcher `0.1.18` 即使没有后续新增的 host-publication manifest 仍然有效，它通过
内嵌 schema delivery 和 Adapter catalog 验证。

仅在静态本地开发中，且 FAP 资源已经存在后，部署方才可配置文档声明的
`ANALYTICS_CONSOLE_FAP_*` 服务端环境变量。不得把 `static-dev-only` 身份当成生产安全模型。

## 查询与模型行为

JAR 内的问题 Skill 描述该 Release 支持的完整 queryModel DSL 和受限 Compose/CTE。实时单模型
Function 只传 `namespace`、`modelName`、`mode` 和业务查询 `payload`。Provider 在一次调用开始时
解析当前有效模型，并在 validate 或 execute 全程固定同一个 `CatalogResolution`。

Function 合同不兼容时发布新的 FunctionRef，例如 `@v2`；模型合同不兼容时使用新的
`modelName`。内部 model/dependency digest 只用于 Bundle 审计或过期检测，不是调用方可见的
模型选择参数。

## 生产边界

标准启动脚本的 Runtime API 安全模式为 `none-dev-test-only`，Console profile 使用
`static-dev-only` authority。不得把该进程直接暴露给不可信网络。生产内嵌需要经过认证的
宿主 subject/authority resolver、网络控制、凭证管理、审计，以及正常的 Foggy 查询
Sandbox/Permission 链路。
