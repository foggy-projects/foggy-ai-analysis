---
name: foggy-ai-analysis
description: 引导 Foggy AI 分析环境安装、Runtime 启动、数据源接入、SQLite fallback、namespace/TM/QM/query model 创建、查询模型 schema 查看、模型 refresh/validate、问题集调优、IDE/MCP 连接、JAR/Docker/Odoo Runtime 部署说明、可选 Spring Boot 内嵌集成，识别并路由已有模型上的 queryModel DSL、composeScript 或受限 Compose/CTE 用法到 foggy-semantic-query，以及问题反馈证据整理。
---

# Foggy AI Analysis

## 能力范围

将这个 Skill 作为 Foggy AI 分析交付和语义层建设的正式入口：

1. 安装 `foggy-runtime-cli`，下载 Java lite runtime launcher，并启动 Runtime API。
2. 用户未提供数据源时，使用 runtime 默认 SQLite 数据源。
3. 生成语义模型前，先 inspect 表结构并执行只读 SQL 探针。
4. 创建或验证 namespace 维度的 TM/QM 资源；只有 embedded 或 legacy 宿主要求时才处理 model-list 注册。
5. 通过 `foggy-runtime-cli` refresh、describe、validate、execute 查询模型。
6. 创建并运行 question bank，再根据结果调优 TM/QM 字段名、caption、description 和 prompt。
7. Runtime API 就绪后，输出 IDE/MCP 客户端连接配置。
8. 说明 Runtime 部署模式、namespace header 和外部模型 bundle。
9. 仅在用户明确需要把 Foggy 嵌入 Spring Boot 应用时，引导 Java 内嵌集成。
10. 收集脱敏后的命令、证据和日志，用于 GitHub BUG 或优化反馈。

Sales-drop 只是内置示例路径。用户想快速演示或没有数据源时使用；如果用户提供了自己的业务数据，不要把 sales-drop 当成主流程。

生产权限设计不在本 Skill 范围内。需要明确说明当前公开 onboarding 面向 dev/test，生产 auth、RBAC、审计和治理在后续阶段处理。

已有模型上的查询语言工作是独立关注点。涉及 queryModel DSL payload、composeScript、受限 Compose/CTE 检查、虚拟语义 SQL 翻译、预聚合路由或查询错误恢复时，如果 `foggy-semantic-query` Skill 可用，应使用该 Skill。当前 Skill 负责准备 runtime/model 上下文，再把查询语言细节交给该工作流。当前公开 Skill 包必须自包含，不得要求未声明的外部 Skill 依赖。

## 工作流

1. 判断用户状态：全新安装、runtime 已运行、已有数据源、没有数据源、模型迭代、question bank 调优、MCP 连接或反馈问题。
2. 只读取下方索引中与当前任务相关的 reference。
3. 执行长流程前，先确定 runtime URL、namespace、datasource mode、SQLite path、model directory 和 evidence directory。
4. 新启动的 runtime 先跑 `wait-ready`，再跑 `capabilities`，记录 `engine`、`runtimeApiVersion`、`schemaVersion`、`securityMode` 和启用能力。
5. 如果 runtime 返回 `securityMode=auth-code`，传入 `--auth-code` 或设置 `FOGGY_RUNTIME_API_AUTH_CODE`。当前公开 sales-drop 示例使用 `securityMode=none-dev-test-only`。
6. 用户提供数据时先 inspect schema，并使用绑定到目标 namespace 的具名 datasource；没有数据源时使用内置 sales-drop SQLite 示例。不要把用户数据库和 sales-drop reseed 流程混用。
7. refresh 前先 validate 模型；查询前先 describe 已 refresh 的模型；除非用户明确要求 seed 示例数据，否则 SQL 探针必须保持只读。
8. 记录命令、端口、证据路径、失败点和修复动作。

Runtime API 命令顺序和失败处理详见 `references/runtime-cli-command-rules.md`。公开 Skill 包必须保持自包含；除非 package manifest 明确声明，否则不要依赖其他 Codex Skill。

## Reference 索引

- `references/public-onboarding.md`：正式下载链接、CLI 安装、Java launcher 下载、runtime 启动和首轮 smoke 检查。
- `references/runtime-cli-command-rules.md`：Runtime CLI JSON 契约、ready/capability gate、datasource/model/query 顺序、exit code 处理和公开包依赖边界。
- `references/datasource-and-semantic-modeling.md`：数据源发现、表检查、SQL 探针、namespace/TM/QM 生成、validate、refresh 和 describe 流程。
- `references/semantic-layer-publish-runbook.md`：将用户自有 Git 管理的 TM/QM 模型目录发布或更新到 Runtime API bundle registry，refresh 查询模型，并验证 Runtime API/MCP 查询服务。
- `references/tm-qm-configuration.md`：TM/QM 配置实操规则，覆盖字段、度量、日期、金额单位、查询模型暴露、可选宿主 model-list 注册和验证。
- `references/question-bank-and-tuning.md`：构建并运行 question bank，分类未命中原因，调优语义元数据或 prompt。
- `references/mcp-deployment.md`：JAR/Docker/Odoo Runtime 部署说明、Runtime API/MCP endpoint 检查、namespace header 和外部 bundle 用法。
- `references/mcp-ide-connection.md`：将支持 MCP 的 IDE 客户端连接到本地 Foggy runtime。
- `references/embedded-java-integration.md`：可选 Spring Boot 内嵌集成，覆盖 `foggy-dataset-model`、`@EnableFoggyFramework`、datasource、namespace 和 bundle 自检。
- `references/sales-drop-example.md`：可选内置 SQLite 示例，包含 demo data、TM/QM 资产和 replay 命令。
- `references/feedback.md`：使用脱敏证据准备 GitHub BUG 或优化反馈。
- `references/production-permission-next-phase.md`：说明生产权限边界，不在 onboarding 流程中实现。
- `references/release-validation.md`：从 release 下载 Skill、CLI 和 Java launcher 资产后做验证，不依赖源码 checkout。

## 内置资产

- `assets/sales-drop-demo/schema.sql`：可选示例的 SQLite schema。
- `assets/sales-drop-demo/data.sql`：确定性的示例数据。
- `assets/sales-drop-demo/models`：示例 TM/QM 资源。
- `assets/sales-drop-demo/queries`：smoke 和 question-bank query payload。
- `assets/sales-drop-demo/question-bank.json`：自然语言示例 question bank。
- `assets/github-issue-template.md`：脱敏 issue 模板。

## 输出规则

完成 setup、modeling 或 debugging 后，需要报告：

- Runtime URL、namespace、port、datasource mode、使用到的 SQLite path 和 model directory。
- 已执行命令及 pass/fail 状态。
- `capabilities` 返回的 runtime identity 和 security mode。
- 创建、复制或修改的文件。
- Evidence directory 和关键输出文件。
- 失败点和具体修复。
- 剩余假设，特别是 datasource ownership 和生产权限延期。

提供 MCP client 配置时，runtime metadata 必须和 `mcpServers` 分开：

- 默认 `mcpServers` 输出只能使用客户端支持的连接字段：`url` 和必需的 `headers`。
- namespace 使用 `headers.X-NS` 表达；不要添加顶层 `namespace` 字段。
- 如果指定的 MCP 客户端要求 `type` 或 `transport`，只能作为明确标注的可选变体提供。
- 除非用户指定的 MCP 客户端文档明确支持，否则不要把 `dataSource`、`security`、`namespace`、`runtimeApiBaseUrl`、`endpoint`、`env`、`sqlitePath`、`datasourceMode`、`evidenceDir` 或 `validationResult` 放进 `mcpServers`。
- MCP client config 后，单独以 runtime information 或 validation results 形式报告 Runtime URL、datasource、SQLite path、`securityMode`、evidence directory 和 validation results。
