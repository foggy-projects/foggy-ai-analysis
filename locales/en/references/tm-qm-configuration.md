# TM/QM Configuration Guide

Use this reference after datasource discovery and table inspection. This is the practical modeling checklist for creating or reviewing Foggy table models (`.tm`) and query models (`.qm`).

For command order, readiness checks, bundle registration, refresh, and query execution, use `datasource-and-semantic-modeling.md` and `runtime-cli-command-rules.md`.

## Modeling Contract

- A TM describes the physical table contract: model name, table name, primary key, fields, physical columns, data types, aggregations, units, and field semantics.
- A QM describes the analysis surface exposed to Runtime API, MCP, and agents: query model name, loaded table model, visible fields, column groups, joins or relations when supported, and access rules.
- Datasource credentials do not belong in TM/QM files. Runtime API datasource configuration, namespace, or bundle configuration decides which database the model runs against.
- This file is the public onboarding and delivery checklist. For attributes not covered here, use the official public syntax reference at `https://foggy-projects.github.io/foggy-data-mcp-docs/en/whitepaper/v1.0/semantic-layer-syntax-reference.html`, then verify against the target runtime's `models validate`/`models describe` output and any project documentation the user provides.
- For query payload syntax after a model is loaded, use the official Query DSL reference at `https://foggy-projects.github.io/foggy-data-mcp-docs/en/whitepaper/v1.0/query-dsl-syntax-reference.html`; keep detailed query-language work in the paired semantic-query workflow when available.
- Do not require a local whitepaper checkout that is not bundled with the Skill.
- Do not invent columns, joins, date grain fields, enums, or business definitions. Confirm them with `tables inspect`, read-only SQL probes, user input, or existing project model conventions.
- Keep TM and QM changes together unless the user explicitly asks for `tm-only` or `qm-only`; otherwise the two files drift.

## Required Evidence Before Writing

Collect enough facts to make the model deterministic:

```powershell
foggy-runtime --base-url <url> --namespace <ns> tables inspect --data-source <name> --table <table> --include-indexes
foggy-runtime --base-url <url> --namespace <ns> sql query --data-source <name> --sql "select * from <table> limit 5" --max-rows 5
```

Record:

- Target namespace and datasource name, or that the runtime default datasource is used.
- Physical table name and primary key.
- Column names, SQL types, nullability, indexes, and sample values.
- Main business time field, if one exists.
- Candidate dimensions, measures, statuses, owners, enums, and text fields.
- Amount unit: major unit, minor unit such as cents/fen, or unknown.

## File Layout

Use the project or bundle layout already present. The public example uses:

```text
models/
  model/
    <Name>.tm
  query/
    <Name>QueryModel.qm
```

Some Spring or embedded hosts also maintain a `model-list.yml` or `application.yml` model list. When that registration file exists, register query models only; do not register TM files as user-facing query models.

## TM Configuration

A single-table TM normally contains:

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

TM rules:

- `name` is the stable table model identifier. Use a clear business name such as `FactOrderModel` or `SalesDropDailyModel`.
- `tableName` must match the inspected physical table. If the project uses `viewSql`, `schema`, or a non-JDBC model type, follow the target runtime capability and existing model conventions.
- `idColumn` must be the physical primary key or stable unique row key, and that column should also appear in `properties`.
- `dataSourceName` can express a model-level named datasource reference, but do not put connection URLs, usernames, or passwords in TM/QM files. Runtime API onboarding should prefer datasource registry and namespace-managed connections.
- Use camelCase logical `name` only when the physical column name is not already the desired field name.
- Put identifiers, dates, enums, statuses, owners, categories, display labels, and useful descriptive text into `properties`.
- Put additive numeric metrics into `measures`, with `aggregation: 'sum'` only when summing is mathematically valid. Counts, distinct counts, max, min, and average metrics must choose the aggregation that matches the business meaning.
- Do not add `aggregation: 'sum'` to row-level ratios such as conversion rate or drop rate unless the business explicitly defines that aggregation.
- Use `DATE` or `DATETIME`/timestamp-equivalent types according to the inspected physical type and runtime model conventions.
- Document enum values and status meanings in `description`; do not leave opaque codes unexplained when sample values reveal the domain.
- Keep long free-text fields out of QM unless they are useful for narrative answers or filtering.

## Dimensions And Member Fields

When a fact table relates to customer, product, organization, store, account, date, or other dimension tables through foreign keys, prefer TM `dimensions` declarations instead of letting query payloads or LLMs guess joins.

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

Dimension rules:

- `foreignKey` is the key on the current table or parent dimension table; `primaryKey` is the dimension table key.
- After `captionColumn` is configured, QM/DSL callers usually use the dimension display value as `customer$caption`.
- Dimension properties are exposed with `$` paths such as `customer$customerType`. Nested dimension model paths can use `product.category$caption`, and final response field names usually replace `.` with `_`.
- When display names require JSON, localization, or dialect SQL, use the project's supported `captionDef`/`dialectFormulaDef`; do not put dialect SQL in query payloads.
- Parent-child dimensions, organization trees, and category trees need closure-table or equivalent hierarchy data. Do not claim `descendantsOf` and related hierarchy operators are available without that backing structure.
- When member lookup must be narrowed, configure TM `memberPermission` or QM `memberPermissions` for visible columns, forced filters, ordering, and allowed hierarchy operations.

## Dictionary, Formula, And AI Metadata

- When Java Entity metadata or project metadata confirms a dictionary/enum field, configure `dictRef` on the TM field and still document important enum values in `description`.
- Use `formulaDef`/`dialectFormulaDef` only when ordinary `column`, dimension joins, dictRef, or semantic scale cannot express the business field.
- Prefer `dialectFormulaDef` for dialect-specific formulas. Formula SQL must be model-author-controlled; do not concatenate user input or LLM-generated content.
- For display calculations that are not bound to one physical column, prefer QM column item `formula` and validate formula support in the target runtime.
- `ai.prompt` / `ai.levels` can supplement model, field, or query-model semantic hints for AI callers. Do not use AI prompts as a substitute for executable types, access rules, or field definitions.
- `deprecated` / `extData` and similar extension metadata can follow project conventions, but they are not query capabilities by themselves.

## Amount And Unit Rules

For money, price, cost, revenue, payment, settlement, refund, or fee fields:

- Use `type: 'MONEY'` for monetary measures when the runtime schema supports it.
- If the physical column already stores the semantic unit, such as dollars or yuan, do not configure scale conversion.
- If the physical column stores minor units, such as cents or fen, prefer TM semantic scale metadata over formula fields.
- When using semantic scale, the contract is `physical value / semanticScaleFactor = semantic value`.
- Do not combine `semanticScaleFactor` with a manual `/100` formula for the same field.
- If the same model bundle serves both business systems that expect physical units and AI/MCP callers that expect semantic units, use separate namespaces for the physical and semantic contracts.

Example when the inspected schema confirms a cent/fen column and the runtime schema supports semantic scale:

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

## Time Field Rules

- Choose the main business time field before generating the QM. Examples: order date, payment date, accounting date, observation date, completion time.
- Do not treat a technical audit timestamp as the main business time unless the user confirms that meaning.
- Keep the original date/time field visible in TM/QM.
- Date grain fields such as `observationDate$month` are query/runtime fields, not physical columns to invent in the TM.
- Use `models describe <QueryModelName>` after refresh to confirm which date grain fields the runtime exposes before writing query payloads.
- If a DateTime field needs year/month/day analysis but no date dimension exists, use the project's supported self-dimension pattern; do not fake a date dimension join.

## QM Configuration

A simple QM exposes fields from a loaded TM:

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

QM rules:

- Export `queryModel`; do not use an alternate export name.
- Use `loadTableModel('<TM name>')` and reference fields through `{ ref: model.field }`.
- Expose the TM `idColumn` field when the model is used by frontends or workflows that need row identity.
- Group fields by analysis intent, not by raw database order.
- Keep the QM surface narrow enough for agents to choose correctly, but include fields required by expected user questions.
- Put the main time field and common dimensions in the first dimension group.
- Put additive measures and carefully described ratios in measure groups.
- For QM-level calculated fields, use `name + formula + type` and document the formula semantics in `description`. Window formulas using `partitionBy`, `windowOrderBy`, or `windowFrame` require runtime validation.
- Use `orders` for default sorting. Sort fields must be resolvable by the QM and should not depend on hidden TM internals.
- For dev/test demo models, `accesses: []` is acceptable. For tenant or production models, access rules must fail closed when auth context is missing.
- For multi-table models, prefer the project's recommended QM `joins` shape, such as `fo.leftJoin(fp).on(fo.orderId, fp.orderId)`. TM `onBuilder` is an advanced association hook and should not be the default example for new QM multi-model binding.
- `memberPermissions` can override and narrow TM dimension member permissions at the QM layer. It should narrow production boundaries, not broaden them.

## Optional Advanced Features

- `preAggregations` is TM performance-optimization metadata. It does not change QM field semantics and is not a default query path. Make it a delivery requirement only after high-frequency aggregations, refresh mechanics, data freshness, and query evidence are validated.
- `VECTOR`, MongoDB, non-JDBC models, complex window formulas, parent-child dimensions, and cross-model joins depend on the target runtime/host capability. Public onboarding should claim support only after target runtime validate/describe passes.
- v2.0 whitepaper capabilities such as Memory Grid, Pivot, Experience Recipe, and DSL_CTE inherit the TM/QM base contract, but they are not mandatory TM/QM file settings. Do not broaden the QM field surface or bypass validators for those advanced capabilities.

## Naming And Description Quality

- Use stable English or project-standard field names; avoid localized names in the field identifier.
- Use `caption` for user-facing labels and `description` for business rules, caveats, enum values, units, and preferred usage.
- Prefer a concrete business phrase over a database abbreviation.
- Make negative constraints explicit, for example: "Use invoiceDate for billing period; do not use createTime for accounting period."
- If a field is only for filtering or access control, describe that role.

## Model List And Registration

Runtime-managed bundles can validate and refresh `.tm` and `.qm` files from the bundle path. Embedded hosts or older projects may also use a model list.

When a model list is required:

- Register query model names, not TM file paths.
- Keep the list synchronized when adding, renaming, or deleting QMs.
- Do not expose internal helper TMs as user-facing query models.

## Validation Checklist

After editing TM/QM:

```powershell
foggy-runtime --base-url <url> --namespace <ns> models validate --models-dir <models-dir> --include-stack-trace
foggy-runtime --base-url <url> --namespace <ns> bundles add --name <bundle> --path <models-dir> --watch --replace
foggy-runtime --base-url <url> --namespace <ns> models refresh
foggy-runtime --base-url <url> --namespace <ns> models describe <QueryModelName> --format json
```

Check:

- `models validate` has no invalid TM/QM files.
- `models refresh` includes the target query model.
- `models describe` exposes expected field names, captions, types, dimensions, measures, filterability, sortability, aggregation support, and descriptions.
- Query payloads use only described field names. Date grain names such as `<dateField>$month` are allowed only after runtime metadata or query validation confirms support.
- Nested dimension fields, caption fields, QM calculated fields, default orders, accesses, and memberPermissions must be covered by describe output or query smoke evidence.
- At least one smoke query executes for the primary time field, one dimension, and one measure.
- If semantic scale is configured, projection, filtering, ordering, aggregation, calculated fields, and pivot/time-window paths should be tested before delivery.
- If preAggregations are configured, additionally check pre-aggregation hit evidence in query debug output. When no pre-aggregation hits, the query should still fall back to the original query path.

## Example Assets

The bundled sales-drop example is the concrete syntax reference:

- `assets/sales-drop-demo/models/model/SalesDropDailyModel.tm`
- `assets/sales-drop-demo/models/query/SalesDropDailyQueryModel.qm`

Use those files for syntax shape, but replace the business fields with inspected user datasource facts.
