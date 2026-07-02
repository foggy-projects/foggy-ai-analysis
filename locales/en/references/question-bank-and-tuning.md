# Question Bank And Tuning

Use this reference after a query model exists and the user wants natural-language quality checks.

## Build The Bank

Create cases that map user questions to expected query payloads and acceptance checks:

```text
id
question
model
payload
expected behavior
assertion
status: executable | needs-clarification
```

Include positive cases, edge filters, ranking/sort cases, and at least one explicit out-of-scope case.

## Run And Classify

For each executable payload:

```powershell
foggy-runtime --base-url <url> --namespace <ns> query validate <model> --payload <payload.json>
foggy-runtime --base-url <url> --namespace <ns> query execute <model> --payload <payload.json>
```

Classify misses as:

```text
prompt wording
field caption or description
missing business synonym
wrong enum mapping
missing measure or dimension
query payload defect
runtime/model bug
needs clarification
```

## Tune

Prefer semantic fixes in this order:

1. Improve TM/QM descriptions and captions.
2. Add business synonyms and enum explanations.
3. Clarify units and date semantics.
4. Add missing dimensions/measures only when backed by source data.
5. Adjust prompts after model semantics are clear.

Re-run the affected cases and record before/after evidence.
