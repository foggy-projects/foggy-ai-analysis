# Error Recovery

Use this reference when a semantic query fails validation or execution.

## Successful Responses With Warnings

A successful validation or execution can still report that an input property was ignored, normalized,
or otherwise interpreted differently. Read stable structured fields such as `code`, `path`, `property`,
`action`, `semanticImpact`, `allowedProperties`, normalized request fragments, and `docsRef`. Preserve
the warning in evidence and report it to the caller.

Do not require or invent a natural-language `suggestedAction`; Runtime code cannot enumerate every
model-specific correction. A stable `suggestionCode` and parameters may help when the remedy is
deterministic, but the actual repair should be derived from the current model description. When a
warning indicates possible semantic drift, correct and revalidate only if the described model exposes
an equivalent that preserves the user's intent. Otherwise keep the successful result qualified and
state which requested semantics were not applied. Purely informational warnings need no repair.

## Fail-Closed Rules

- Do not invent fields, captions, date grains, metrics, or model names.
- Do not switch to raw SQL, private endpoints, or unrelated agents to answer reporting questions.
- Do not execute after validation failure.
- Correct a rejected request only when the diagnostics identify a structural fix that preserves
  the user's business semantics; then validate the corrected request again.
- If Runtime returns `safeToAutoRepair=false`, do not perform an automated state-changing repair.
  This does not prohibit proposing a new pre-effect query payload for the user or validator to
  review.
- Never switch to a different model as error recovery. Live Function calls always use the current
  valid model resolved for that invocation.

## Analytics Function Validation Failures

For `foggy.analytics.query-model.run@v2`, a semantic validation rejection may arrive from the
Analytics Runtime as `ANALYTICS_SEMANTIC_QUERY_INVALID`. At the FAP boundary it is projected to a
pre-effect `FUNCTION_ARGUMENT_INVALID` result with:

- `modelRepairable: true`;
- `effectPhase: "PRE_EFFECT"`;
- the exact `functionRef` and published `schemaDigest`;
- safe `violations[]` entries containing `instancePath`, `keyword`, and `messageKey`.

Use each violation's stable `messageKey` to correct only the indicated Function argument, and call
`mode=validate` again. Never execute the rejected payload. `retryable=false` means that replaying
the unchanged request will not help; it does not mean the model should stop after a repairable
parameter rejection.

`ANALYTICS_SEMANTIC_QUERY_FAILED` is an execution/runtime failure, not permission to guess a new
payload. Preserve its safe `code`, `phase`, message, and diagnostics, report it, and retry only if
the published response explicitly marks the same operation retryable. Permission, sandbox,
protocol, and transport failures keep their own codes and boundaries.

## Field And Model Errors

| Error | Handling |
|---|---|
| `MODEL_NOT_FOUND` | Run model listing or refresh if appropriate; do not silently switch to a similar model. |
| `FIELD_NOT_FOUND` | Re-describe the model and replace only with an existing field. |
| Missing caption | Use an exposed id field, omit caption, or switch only to a model that exposes the caption. |
| Missing date grain | Use an exposed grain field or explain that the requested grain is unavailable. |
| `DICT_LABEL_NOT_FOUND` | Re-describe the field and use a registered label or the raw code; do not guess a spelling or silently drop the filter. |
| `DICT_LABEL_AMBIGUOUS` | Stop and ask the model owner to make labels unique, or use the exact raw code when the user's intent identifies one. |
| `DICT_CAPTION_ORDER_UNSUPPORTED` | Remove label ordering only when it is not required. If it is required, report that the field must be modeled as a database-backed dimension. |
| `DICT_CAPTION_FILTER_UNSUPPORTED` | Replace range/fuzzy caption filtering only with a semantically equivalent supported code/label equality or set filter; otherwise report the limitation. |

For a static dictionary, absence of `<field>$caption` in the current model description means the
field is unavailable on that runtime/model. Do not manually translate returned rows or maintain a
client-side label map as error recovery.

## DSL Syntax Errors

- `fields` is wrong for queryModel; use `columns`.
- Put DSL under `payload` when using function wrappers.
- Move complex expressions into `calculatedFields` when supported.
- Remove SQL snippets such as `DATE_TRUNC`, `YEAR()`, `CASE WHEN`, or raw `where`.
- Keep row filters in `slice`; use `having` or compose derived query for aggregate-output filters.
- For `DSL_CTE_STAGE_REFERENCE_INVALID`, make the first stage use `input.model`, make every later
  `inputs` reference a prior named stage, and revalidate. Never invent `source` as an implicit
  stage.

## Aggregation Errors

- Add every non-aggregate selected field to `groupBy`.
- Do not re-aggregate semantic metrics that are already aggregate metrics.
- If the engine asks to specify query fields, check for missing `columns` or timeWindow derived fields selected without the base metric.
- Use a compose derived query when filtering the result of an aggregate plan.

## Pivot Errors

- Remove `columns` when using `pivot`.
- Do not combine `pivot` and `timeWindow` in one request.
- Reduce axis cardinality with filters or limits.
- Use tree mode only when the model exposes the required hierarchy.

## Time Window Errors

- Add required `field`, `grain`, `comparison`, and `targetMetrics`.
- Use comparisons such as `yoy`, `mom`, `wow`, `ytd`, `mtd`, `rolling_7d`, `rolling_30d`, or `rolling_90d` only when supported.
- Do not use timeWindow for plain period totals.
- Include base metrics, not only derived fields like `metric__mtd` or `metric__ratio`.
- Do not target calculated fields unless runtime metadata explicitly supports it.

## Compose Errors

- Alias join keys before joining.
- Rename duplicate columns before joining.
- Aggregate fact-side data before joining to avoid row multiplication.
- Return `{ plans: ... }`.
- Treat empty derived results as valid unless the user asked for diagnostics.
- On sandbox violations, stop and report the unsupported operation.
