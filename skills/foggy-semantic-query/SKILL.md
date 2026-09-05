---
name: foggy-semantic-query
description: Build and review governed Foggy semantic query payloads for existing models. Use when Codex needs queryModel DSL, composeScript, columns/slice/groupBy/orderBy/pivot/timeWindow/calculatedFields, cross-model semantic joins or unions, restricted Compose/CTE runtime checks, virtual semantic SQL translation, pre-aggregation routing, or query error recovery. Pair with foggy-ai-analysis when runtime setup, datasource onboarding, TM/QM creation, model refresh, or MCP client connection is still needed.
---

# Foggy Semantic Query

## Scope

Use this Skill to query existing Foggy semantic models. It assumes the datasource, namespace, TM/QM, and model-list already exist or can be described by Runtime API.

Support two governed callers without mixing their envelopes:

- Runtime CLI supplies namespace/model as command arguments and reads a payload file containing
  only the queryModel DSL object.
- Analytics Console/FAP uses the published Functions. Discover with
  `foggy.analytics.model-dependencies.list@v2`, describe with
  `foggy.analytics.semantic-models.describe@v2`, and run one model with
  `foggy.analytics.query-model.run@v2` using only `namespace`, `modelName`, `mode`, and `payload`.
  Use `foggy.analytics.compose.run@v1` only for governed cross-model or derived-plan work; keep
  `foggy.analytics.semantic-queries.execute@v2` for its smaller typed subset.

The runtime resolves the current valid model once per invocation and keeps that
`CatalogResolution` fixed through validation or execution.

For runtime setup, new datasource onboarding, TM/QM creation, model refresh, question-bank tuning, or MCP client connection, use `foggy-ai-analysis` first. Return here only after `models describe <QueryModel>` can expose the usable fields.

When query work reveals missing fields, ambiguous captions, incorrect model metadata, or datasource/model setup gaps, hand the issue back to `foggy-ai-analysis` for semantic modeling repair, then continue the query workflow here.

Foggy semantic queries are governed by model metadata. Do not bypass the semantic layer with arbitrary SQL, private Runtime API endpoints, hidden fields, production permission workarounds, or undeclared external Skill dependencies.

Protected models may require an optional complete, opaque data-plane
Authorization value. Keep it separate from Runtime management `--auth-code`;
never add `Bearer`, print it, persist it in payloads, or retry a denied query
without it.

## Workflow

1. Identify the target namespace, runtime URL or Function surface, and whether execution evidence
   is required. If the Analytics Function caller does not know a model, list dependencies before
   selecting one.
2. Describe the current model before using fields, metrics, dimension or static-dictionary
   captions, self date-dimension grains, date axes, pivot, or timeWindow. If FAP delivers a Function schema on demand because of prompt budget, retrieve the
   published input schema before building nested DSL; do not guess from a summary.
3. Choose the narrowest supported query surface from the routing table below.
4. Build payloads only from described model fields or from columns produced by prior compose plans.
5. Validate before execute. Execute only when the user asks for row evidence or the environment is clearly dev/test.
6. On errors, inspect `error.code`, `error.phase`, diagnostics, `safeToAutoRepair`, and FAP
   `modelRepairable`/`violations` when present. Repair only a pre-effect request problem whose fix
   preserves the user's semantics, then validate again.
7. On successful responses with `warnings`, inspect their stable structured facts before using the
   result. Correct and revalidate semantic-impact warnings only when the described model supports an
   intent-preserving equivalent; otherwise disclose the limitation. Do not depend on free-text advice.

## Surface Routing

| User intent | Use | Reference |
|---|---|---|
| Single model detail, filter, sort, grouping, aggregation, calculated fields, pivot, or timeWindow | queryModel DSL | `references/query-model-dsl.md` |
| Cross-model join, union, derived plan, time-window output composition, or multiple result plans | composeScript | `references/compose-script.md` |
| Runtime evidence for restricted Compose/CTE scripts or standalone fsscript orchestration | Runtime CLI checks | `references/restricted-cte-runtime.md` |
| SQL-like user wording that should stay governed by semantic models | virtual semantic SQL translation | `references/virtual-semantic-sql.md` |
| Performance, cache, pre-aggregation, or slow-query routing questions | pre-aggregation guidance | `references/pre-aggregation.md` |
| Field, syntax, aggregation, pivot, timeWindow, compose, or runtime validation failures | error recovery | `references/error-recovery.md` |

## Command Rules

When Runtime API evidence is needed, use `foggy-runtime` JSON output and keep the runtime contract backend-neutral:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> capabilities
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel>
foggy-runtime --base-url <runtime-url> --namespace <ns> query validate <QueryModel> --payload <payload.json>
foggy-runtime --base-url <runtime-url> --namespace <ns> query execute <QueryModel> --payload <payload.json>
```

When the caller supplies a protected-model identity, add the same global
`--authorization <opaque-value>` (or use `FOGGY_RUNTIME_AUTHORIZATION`) to model
list/describe, query validate/execute, Compose, and dimension-member commands.
The CLI sends it only to data-plane paths. Management `--auth-code` neither
replaces nor elevates this identity.

Do not add `--engine`, call Java/Python private endpoints, parse pretty output for automation, or execute when validation failed.

For Analytics Function calls, do not copy Runtime CLI flags into Function arguments and do not put
authority, datasource, tenant, model digests, or revision fields in the payload. Use the exact
published Function schema and preserve its validation diagnostics for repair.

## Output Rules

Report:

- Model, namespace, runtime URL, and assumed datasource context.
- Selected query surface and why it is the narrowest supported surface.
- Payload or script file path and the generated query content when useful.
- Validation command/result before execution.
- Execution result only when requested or appropriate for dev/test evidence.
- Exact unsupported pieces when the semantic model cannot answer the request.
- Runtime warning codes/actions and semantic impact when validation or execution succeeded with warnings.
- Whether the model was queried anonymously or with caller-supplied
  Authorization, without ever reporting the credential value.
