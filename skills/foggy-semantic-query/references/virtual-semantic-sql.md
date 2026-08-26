# Virtual Semantic SQL

Virtual semantic SQL is a translation aid for SQL-like user intent. It is not permission to execute arbitrary SQL.

## Allowed Translation

Translate only SQL-like requests that can be represented by described semantic models:

- `SELECT` columns from described fields or semantic metrics.
- `WHERE` filters into `slice`.
- `GROUP BY` into `groupBy`.
- `ORDER BY` into `orderBy`.
- `LIMIT` into `limit`.
- Basic aggregate functions that Foggy DSL supports.
- Joins, unions, and derived filters only through composeScript.

## Rejected Translation

Fail closed when the request requires:

- Hidden physical tables or columns not exposed by QM.
- DDL, DML, stored procedures, temp tables, unrestricted CTEs, or multi-statement scripts.
- SQL functions not supported by semantic DSL.
- Arbitrary date functions when the model does not expose the requested date grain.
- Permission, tenant, datasource, or audit bypass.
- Raw SQL execution against production data.

## Translation Steps

1. Identify the semantic model candidates.
2. Describe each candidate before translating fields.
3. Map SQL projection to `columns`.
4. Map row filters to `slice`.
5. Map grouping and aggregate expressions to `columns` plus `groupBy`.
6. Map aggregate-result filters to `having` or compose derived query.
7. Route joins, unions, and second-stage filters to composeScript.
8. Validate before execute.

## User-Facing Wording

When the user asks for SQL, explain the boundary briefly:

```text
I will translate this to Foggy semantic DSL so it stays within the governed model. I will not execute raw SQL unless you explicitly ask for a dev/test probe and the environment allows it.
```

If translation is impossible, return the unsupported clause and the nearest supported semantic query shape.
