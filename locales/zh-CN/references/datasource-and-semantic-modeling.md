# 数据源与语义建模

当用户已有数据源，或需要创建 namespace/TM/QM 资源时，使用本 reference。

详细命令 gate、exit code 和失败处理，先读 `runtime-cli-command-rules.md`。

## 顺序

1. 用 `wait-ready` 和 `capabilities` 确认 runtime 就绪。
2. 确定 namespace 和 datasource mode。
3. 写模型前先 inspect 表。
4. 生成或更新 TM/QM 文件；宿主项目需要时同步 model-list 注册。
5. validate 模型。
6. add 或 update model bundle。
7. refresh 并 describe query model。
8. validate 和 execute query payload。

## 数据源发现

对于具名数据源：

```powershell
foggy-runtime --base-url <url> --namespace <ns> datasources list
foggy-runtime --base-url <url> --namespace <ns> datasources test <name>
foggy-runtime --base-url <url> --namespace <ns> tables list --data-source <name>
foggy-runtime --base-url <url> --namespace <ns> tables inspect --data-source <name> --table <table> --include-indexes
```

对于 runtime 默认 SQLite 数据源，如果当前 runtime capability 支持默认数据源执行，可以省略 `--data-source`。

只读 SQL 探针：

```powershell
foggy-runtime --base-url <url> --namespace <ns> sql query --data-source <name> --sql "select * from <table> limit 5" --max-rows 5 --timeout-seconds 5
```

除非用户明确要求，不要对用户数据执行变更 SQL。

Runtime API-managed datasource 需要跨 runtime restart 保留时，必须从 runtime 启动配置和重启检查采集 datasource 持久化证据：

```powershell
foggy-runtime --base-url <url> --namespace <ns> datasources list
foggy-runtime --base-url <url> --namespace <ns> datasources test <name>
```

报告 runtime 启动时配置的 registry 和 datasource 文件路径，例如 `runtime-datasources.json` 或 `runtime-datasource-registry.json`。确认文件存在，重启 runtime，并证明 `datasources list` 仍能返回该 datasource。不要猜这些文件在 runtime 工作目录、用户 home，还是配置过的 runtime home 下。

## 模型文件

将 namespace 资源放在一个可作为 runtime-managed bundle 添加的本地目录：

```text
models/
  model/
    <Name>.tm
  query/
    <Name>QueryModel.qm
```

Runtime-managed bundle 不要主动创建 `model-list.yml`；只有目标宿主已经要求该注册文件时才维护。

根据真实表字段、样例值和用户语言生成 TM 字段。优先使用清晰业务描述，而不是裸列名。必须明确记录单位、日期语义、枚举含义、owner/status 维度。

写入或 review 具体 TM/QM 字段前，先读 `tm-qm-configuration.md`。该文档定义字段分类、度量聚合、日期粒度、金额单位、QM 暴露、可选宿主 model-list 和验证规则。

## 已有 Query Model Schema

用户询问某个 QM 暴露哪些字段时，不要只从 `.qm` 文件推断。模型加载后，通过 Runtime API/CLI 读取 metadata：

```powershell
foggy-runtime --base-url <url> --namespace <ns> models list
foggy-runtime --base-url <url> --namespace <ns> models describe <QueryModelName>
foggy-runtime --base-url <url> --namespace <ns> models describe <QueryModelName> --field <fieldName>
```

汇总字段时，尽量包含 `fieldName`、title/caption、type、维度或度量角色、是否可筛选、是否可排序、是否支持聚合，以及 description。后续 query 指导必须基于 describe 返回的 `fieldName`。

## Validate 与 Refresh

```powershell
foggy-runtime --base-url <url> --namespace <ns> models validate --models-dir <models-dir> --include-stack-trace
foggy-runtime --base-url <url> --namespace <ns> bundles add --name <bundle> --path <models-dir> --watch --replace
foggy-runtime --base-url <url> --namespace <ns> models refresh
foggy-runtime --base-url <url> --namespace <ns> models describe <QueryModelName>
```

validation 失败时，先分类再改文件：

```text
schema mismatch
missing table or column
type mismatch
bad expression or DSL syntax
caption/description ambiguity
runtime capability gap
```

报告 validation 结果时使用 runtime 返回的字段，例如 total files、valid files、invalid files、warnings、failed files、error category、error phase、file、line、message 和 suggestion。如果响应区分 `MODEL` 与 `CASCADING`，先展示 `MODEL` 错误，并说明 cascading 错误通常会在上游 TM/QM 修复后消除。

只有 Runtime API `models.validate` 不支持或不存在，且项目仍记录旧 endpoint 时，才把 `/api/semantic-layer/validate` 作为 legacy Spring fallback。

## 查询检查

```powershell
foggy-runtime --base-url <url> --namespace <ns> query validate <QueryModelName> --payload <payload.json>
foggy-runtime --base-url <url> --namespace <ns> query execute <QueryModelName> --payload <payload.json>
```

保存能代表用户问题的 payload；它们会成为 question bank 的种子。
