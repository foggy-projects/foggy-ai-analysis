# Pre-Aggregation

Use this reference when the user asks about slow semantic queries, cache hits, pre-aggregation routing, or performance behavior.

## Principles

- Pre-aggregation is an optimization; it must not change the semantic answer.
- Effective model, field, and typed row permissions are resolved before
  pre-aggregation routing and cache lookup.
- Existing pre-aggregations are `GLOBAL`. A protected query may use one only
  when the runtime proves that its permission fields, operators, lineage, grain,
  and measures are equivalent. Otherwise the candidate is skipped and the query
  safely falls back to source data.
- `SECURITY_SCOPED` materialization is reserved; configuration must fail fast
  until scope-specific build and refresh are implemented.
- Start from the same governed queryModel DSL or composeScript shape the user requested.
- Validate the query semantics before investigating cache or route behavior.
- Do not add hidden fields, datasource switches, private endpoints, or raw SQL to force a hit.

## Review Steps

1. Describe the model and confirm the query uses exposed dimensions, metrics, filters, and date axes.
2. Confirm grouping, filters, time grain, and metric definitions match the intended pre-aggregation.
3. Check whether query shape, date range, filters, or calculated fields prevent a hit.
4. For a protected model, check permission-sensitive diagnostics for a safe
   candidate skip; never ask for or display the raw Authorization,
   authorization signature, row values, or hidden field names.
5. If the query misses cache, simplify only when the simplified query still answers the user's request.
6. Report route assumptions separately from query results.

## Safe Adjustments

- Add an explicit date range when the user supplied a bounded period.
- Use the model's described business date grain instead of raw date functions.
- Remove unused columns or excessive detail fields from aggregate queries.
- Split unsupported pivot/timeWindow combinations into separate governed queries.
- Route cross-model derived work through composeScript after each base plan remains valid.

## Unsafe Adjustments

- Replacing a semantic metric with a physical column because it seems faster.
- Changing filter scope to match a cached aggregate without telling the user.
- Removing or weakening model-authored row predicates to force a hit.
- Treating a cache or pre-aggregation miss as permission to use another
  identity, a global user snapshot, or `SECURITY_SCOPED` fallback.
- Using SQL probes as the primary answer path.
- Mutating cache state or invalidating production caches without explicit operator approval.

## Output

Report:

- Original query surface and payload/script.
- Validation result.
- Suspected pre-aggregation hit or miss reason.
- Whether permission equivalence was proven or the candidate safely fell back,
  without exposing sensitive authorization material.
- Any semantic-preserving rewrite.
- Residual performance risk.
