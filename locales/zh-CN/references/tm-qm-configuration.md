# TM/QM 配置指南

数据源发现和表结构 inspect 完成后，使用本 reference 创建或 review Foggy 表模型（`.tm`）和查询模型（`.qm`）。

命令顺序、ready 检查、bundle 注册、refresh 和查询执行流程，继续使用 `datasource-and-semantic-modeling.md` 和 `runtime-cli-command-rules.md`。

## 建模契约

- TM 描述物理表契约：模型名、表名、主键、字段、物理列、类型、聚合、单位和字段语义。
- QM 描述暴露给 Runtime API、MCP 和 agent 的分析面：查询模型名、加载的表模型、可见字段、字段分组、支持时的 join/relation，以及访问控制。
- 数据库凭证不写进 TM/QM。实际连接哪个数据库，由 Runtime API datasource 配置、namespace 或 bundle 配置决定。
- 本文件是公开 onboarding 和交付检查清单。未覆盖的属性必须以目标 runtime 的 `models validate`/`models describe` 输出，以及用户提供的项目文档为准；不要要求公开 Skill 用户拥有未随包分发的本地白皮书 checkout。
- 不要凭空发明列、join、日期粒度字段、枚举或业务口径。必须来自 `tables inspect`、只读 SQL 探针、用户确认或项目既有模型约定。
- 除非用户明确只要 `tm-only` 或 `qm-only`，否则 TM 和 QM 要作为一组交付，避免两者漂移。

## 写文件前必须确认

先收集足够证据，让模型是确定性的：

```powershell
foggy-runtime --base-url <url> --namespace <ns> tables inspect --data-source <name> --table <table> --include-indexes
foggy-runtime --base-url <url> --namespace <ns> sql query --data-source <name> --sql "select * from <table> limit 5" --max-rows 5
```

记录：

- 目标 namespace 和 datasource 名称，或确认使用 runtime 默认 datasource。
- 物理表名和主键。
- 列名、SQL 类型、是否可空、索引和样例值。
- 主业务时间字段。
- 候选维度、度量、状态、负责人、枚举和文本字段。
- 金额单位：主单位、分/厘/cent 等小单位，或未知。

## 文件布局

沿用项目或 bundle 已有布局。公开示例使用：

```text
models/
  model/
    <Name>.tm
  query/
    <Name>QueryModel.qm
```

部分 Spring 或 embedded 宿主还会维护 `model-list.yml` 或 `application.yml` 中的 model list。存在注册文件时，只注册 query model；不要把 TM 当成用户可查询模型注册。

## TM 配置

单表 TM 通常包含：

```javascript
export const model = {
    name: 'SalesDropDailyModel',
    caption: 'Sales Drop Daily Diagnostics',
    tableName: 'sales_drop_daily',
    idColumn: 'sales_drop_id',

    properties: [
        {
            column: 'observation_date',
            name: 'observationDate',
            caption: 'Observation Date',
            description: 'Business date for the diagnostic row.',
            type: 'DATE'
        }
    ],

    measures: [
        {
            column: 'net_sales_amount',
            name: 'netSalesAmount',
            caption: 'Current Net Sales Amount',
            aggregation: 'sum',
            type: 'MONEY'
        }
    ]
};
```

TM 规则：

- `name` 是稳定的 table model 标识。使用清晰业务名，例如 `FactOrderModel` 或 `SalesDropDailyModel`。
- `tableName` 必须匹配 inspect 到的物理表；如果项目用 `viewSql`、`schema` 或非 JDBC 模型类型，必须以目标 runtime 的能力和既有模型约定为准。
- `idColumn` 必须是物理主键或稳定唯一行键，并且该列也应出现在 `properties`。
- `dataSourceName` 可以表达模型级命名数据源引用，但不要把连接 URL、用户名或密码写入 TM/QM；Runtime API onboarding 优先通过 datasource registry 和 namespace 管理连接。
- 物理列名不是理想字段名时，再用 camelCase 逻辑 `name`。
- 标识、日期、枚举、状态、负责人、分类、展示名和有用描述文本放入 `properties`。
- 可加总的数值指标放入 `measures`；只有数学上可加总时才配置 `aggregation: 'sum'`。计数、去重计数、最大值、最小值、平均值等必须按业务含义选择对应 `aggregation`。
- 转化率、下降率等行级比率不要默认加 `aggregation: 'sum'`，除非业务明确了该聚合口径。
- 按 inspect 到的物理类型和 runtime 模型约定使用 `DATE` 或 `DATETIME`/timestamp 等价类型。
- 枚举值和状态含义写进 `description`；样例值已经暴露领域含义时，不要留下不透明代码。
- 长文本字段只有对叙述回答或筛选有用时才暴露到 QM。

## 维度关系与成员字段

当事实表通过外键关联客户、商品、组织、门店、科目、日期等维度表时，优先在 TM `dimensions` 中声明关系，而不是让 query payload 或 LLM 猜 JOIN。

```javascript
dimensions: [
    {
        name: 'customer',
        caption: 'Customer',
        tableName: 'dim_customer',
        foreignKey: 'customer_id',
        primaryKey: 'id',
        captionColumn: 'customer_name',
        properties: [
            { column: 'customer_type', name: 'customerType', caption: 'Customer Type', type: 'STRING' }
        ]
    }
]
```

维度规则：

- `foreignKey` 是当前表或父维度表上的外键列，`primaryKey` 是维度表主键列。
- 配置 `captionColumn` 后，QM/DSL 通常通过 `customer$caption` 使用维度显示名。
- 维度属性通过 `customer$customerType` 这类 `$` 路径暴露；嵌套维度建模路径可使用 `product.category$caption`，最终响应字段名通常会把 `.` 转为 `_`。
- 当显示名需要 JSON、多语言或方言 SQL 表达时，使用项目支持的 `captionDef`/`dialectFormulaDef`，不要把方言 SQL 写进查询 payload。
- 父子维度、组织树、品类树需要闭包表等层级数据结构支撑；没有闭包表时不要假设 `descendantsOf` 等层级操作可用。
- 维度成员查询需要收窄时，在 TM `memberPermission` 或 QM `memberPermissions` 中配置可见列、强制过滤、排序和允许的层级操作。

## 字典、公式与 AI 元数据

- Java Entity 或项目元数据能确认字段是字典/枚举时，可以在 TM 字段上配置 `dictRef`，并在 `description` 中写清楚关键枚举值。
- 只有普通 `column`、维度 JOIN、dictRef 或 semantic scale 不能表达业务字段时，才使用 `formulaDef`/`dialectFormulaDef`。
- 方言相关公式优先使用 `dialectFormulaDef`；公式内容必须是模型作者控制的 SQL 片段，不拼接用户输入或 LLM 生成内容。
- 需要不依赖单个物理列的展示计算时，优先考虑 QM column item 的 `formula`，并验证目标 runtime 的公式能力。
- `ai.prompt` / `ai.levels` 可以补充模型、字段或查询模型的 AI 语义提示；不要用 AI prompt 代替可执行的类型、权限或字段定义。
- `deprecated` / `extData` 等扩展元数据可以保留项目约定，但不要把它们当成查询能力本身。

## 金额和单位规则

金额、价格、费用、成本、收入、支付、结算、退款等字段：

- runtime schema 支持时，货币度量使用 `type: 'MONEY'`。
- 如果物理列已经存储语义单位，例如元或美元，不配置缩放。
- 如果物理列存储小单位，例如分或 cent，优先用 TM 语义缩放元数据，不要用公式字段手写换算。
- 使用语义缩放时，契约是 `物理值 / semanticScaleFactor = 语义值`。
- 同一字段不要同时配置 `semanticScaleFactor` 和手写 `/100` formula。
- 如果同一套模型同时服务期望物理单位的业务系统和期望语义单位的 AI/MCP 调用方，使用不同 namespace 区分物理契约和语义契约。

当 inspect 确认列为分/cent 且 runtime schema 支持 semantic scale 时，可使用：

```javascript
{
    column: 'total_cost_cent',
    name: 'totalCost',
    caption: 'Total Cost',
    type: 'MONEY',
    aggregation: 'sum',
    semanticScaleFactor: 100,
    semanticUnitLabel: 'major currency unit'
}
```

## 时间字段规则

- 生成 QM 前先确定主业务时间字段，例如订单日期、付款日期、记账日期、观测日期、完成时间。
- 不要把技术审计时间当成主业务时间，除非用户确认这个含义。
- TM/QM 中保留原始日期或时间字段。
- `observationDate$month` 这类日期粒度字段属于查询/runtime 字段，不是 TM 里要伪造的物理列。
- refresh 后用 `models describe <QueryModelName>` 确认 runtime 暴露了哪些日期粒度字段，再写 query payload。
- DateTime 字段需要 year/month/day 分析但没有日期维表时，使用项目支持的 self-dimension 模式；不要伪造日期维表 join。

## QM 配置

简单 QM 从已加载 TM 暴露字段：

```javascript
const salesDrop = loadTableModel('SalesDropDailyModel');

export const queryModel = {
    name: 'SalesDropDailyQueryModel',
    caption: 'Sales Drop Diagnostic Query',
    description: 'Single-table query model for sales-drop diagnostics.',
    loader: 'v2',
    model: salesDrop,
    columnGroups: [
        {
            caption: 'Diagnostic Dimensions',
            items: [
                { ref: salesDrop.observationDate },
                { ref: salesDrop.region }
            ]
        },
        {
            caption: 'Sales Metrics',
            items: [
                { ref: salesDrop.netSalesAmount }
            ]
        }
    ],
    accesses: []
};
```

QM 规则：

- 导出名使用 `queryModel`，不要改成其他导出名。
- 使用 `loadTableModel('<TM name>')`，字段通过 `{ ref: model.field }` 引用。
- 前端或工作流需要行标识时，QM 要暴露 TM 的 `idColumn` 对应字段。
- 字段按分析意图分组，不按数据库原始顺序机械分组。
- QM 表面要足够收敛，避免 agent 误选字段；但必须包含预期用户问题需要的字段。
- 第一组维度优先放主时间字段和常用维度。
- 度量组放可加总指标和描述清楚的比率。
- 如需 QM 级计算字段，使用 `name + formula + type`，并在 `description` 中说明公式口径；窗口公式涉及 `partitionBy`、`windowOrderBy`、`windowFrame` 时必须做 runtime 验证。
- 默认排序使用 `orders`；排序字段必须来自 QM 可解析字段，且不要依赖未暴露的 TM 内部字段。
- dev/test 示例中 `accesses: []` 可以接受；租户或生产模型必须在缺少 auth context 时 fail closed。
- 多表模型优先使用项目推荐的 QM `joins` 写法，例如 `fo.leftJoin(fp).on(fo.orderId, fp.orderId)`；TM `onBuilder` 属于高级关联条件，不应作为新 QM 多模型绑定的默认示例。
- `memberPermissions` 可在 QM 层覆盖并收窄 TM 维度成员权限；只能收窄，不应放宽生产权限边界。

## 可选高级能力

- `preAggregations` 是 TM 上的性能优化元数据，不改变 QM 字段语义，也不是默认查询路径。只有真实高频聚合、刷新机制、数据新鲜度和查询证据都验证后，才把它作为交付要求。
- `VECTOR`、MongoDB、非 JDBC 模型、复杂窗口公式、父子维度和跨模型 joins 都依赖具体 runtime/宿主能力；公开 onboarding 中只能在目标 runtime validate/describe 通过后宣称支持。
- v2.0 白皮书中的 Memory Grid、Pivot、Experience Recipe、DSL_CTE 等能力继承 TM/QM 基础契约，但不是 TM/QM 文件本身的必配项。不要为了这些高级能力扩大 QM 字段面或绕过 validator。

## 命名和描述质量

- 字段标识使用稳定英文或项目标准命名；不要在字段 identifier 中使用本地化名称。
- `caption` 写用户可见标签，`description` 写业务口径、注意事项、枚举值、单位和推荐用法。
- 优先使用清晰业务词，而不是数据库缩写。
- 负向约束要明确，例如：“账期使用 invoiceDate；不要使用 createTime 表示会计期间。”
- 字段只用于筛选或权限时，也要说明这个角色。

## Model List 与注册

Runtime-managed bundle 可以直接从 bundle path validate 和 refresh `.tm` / `.qm` 文件。embedded host 或旧项目可能还使用 model list。

需要 model list 时：

- 注册 query model 名称，不注册 TM 文件路径。
- 新增、重命名、删除 QM 时同步更新注册列表。
- 不要把内部 helper TM 暴露为用户可查询模型。

## 验证清单

编辑 TM/QM 后执行：

```powershell
foggy-runtime --base-url <url> --namespace <ns> models validate --models-dir <models-dir> --include-stack-trace
foggy-runtime --base-url <url> --namespace <ns> bundles add --name <bundle> --path <models-dir> --watch --replace
foggy-runtime --base-url <url> --namespace <ns> models refresh
foggy-runtime --base-url <url> --namespace <ns> models describe <QueryModelName> --format json
```

检查：

- `models validate` 没有 invalid TM/QM 文件。
- `models refresh` 包含目标 query model。
- `models describe` 暴露预期字段名、caption、type、维度、度量、是否可筛选、是否可排序、是否支持聚合和 description。
- query payload 只能使用 describe 返回的字段名。`<dateField>$month` 这类日期粒度字段，必须在 runtime metadata 或 query validate 确认支持后才能使用。
- 嵌套维度字段、caption 字段、QM 计算字段、默认排序、accesses 和 memberPermissions 都必须在 describe 或 query smoke 中被验证到。
- 至少执行一个覆盖主时间字段、一个维度和一个度量的 smoke query。
- 配置 semantic scale 时，交付前应覆盖 projection、filtering、ordering、aggregation、calculated fields、pivot/time-window 等路径。
- 配置 preAggregations 时，额外检查查询证据中的预聚合命中信息；没有命中时结果仍应能回退到原始查询路径。

## 示例资产

内置 sales-drop 示例是具体语法参考：

- `assets/sales-drop-demo/models/model/SalesDropDailyModel.tm`
- `assets/sales-drop-demo/models/query/SalesDropDailyQueryModel.qm`

语法形态参考这些文件，但业务字段必须替换为用户真实数据源 inspect 后的事实。
