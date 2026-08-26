# Release Validation

Use this reference to validate the formal Skill package from public release assets.

## Constraints

```text
do not use foggy-runtime-cli source checkout
do not set PYTHONPATH=src
download Skill from https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v<skill-version>
download CLI from https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v<cli-version>
download Foggy Runtime Launcher from https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/<launcher-tag>
validate all SHA256SUMS
scan the unzipped Skill for undeclared dollar-prefixed Skill references
```

Use the concrete `<skill-version>`, `<cli-version>`, and `<launcher-tag>` stated in the release notes under validation. Do not leave historical version numbers in the validation prompt or evidence.

## Smoke

1. Install CLI in an isolated environment.
2. Start Java runtime on port `18066` unless occupied.
3. Run `wait-ready` and `capabilities`.
4. If the launcher manifest advertises `features.analyticsConsole.embedded=true`, verify default
   startup does not expose Console/Analytics routes, then restart with the packaged Console opt-in
   and verify `/analytics-console/` plus Analytics capabilities.
5. Confirm FAP remains disabled unless the release test explicitly supplies an isolated,
   already-provisioned FAP fixture; launcher startup must not provision it.
   When such a fixture and host source checkout are supplied, validate the host-exported five
   Function projections with `scripts/release/fap_question_publication_gate.py` before host apply;
   require `mutationPerformed=false`, then verify the host describes the same immutable digests.
6. If no datasource is available, run the bundled sales-drop replay with `--use-default-datasource`.
7. Stop runtime and verify the port is released.

## Static Skill Reference Check

After unzipping the Skill, search for Skill-style references:

```powershell
rg -n --pcre2 '(?<![A-Za-z0-9_-])\$([a-z][a-z0-9]*(?:-[a-z0-9]+)+)(?![A-Za-z0-9_-])' <unzipped-skill-dir>
```

Only `$foggy-ai-analysis` self references are allowed unless the package manifest declares additional `skillDependencies`. Any undeclared external Skill reference blocks release validation.

Also verify that `references/semantic-layer-publish-runbook.md` is present in the unzipped Skill and is self-contained:

```powershell
Test-Path <unzipped-skill-dir>/references/semantic-layer-publish-runbook.md
rg -n "semantic-layer-publish-runbook.md|private Java|private Python|models validate|bundles add|models refresh|tools/list|mcpServers" <unzipped-skill-dir>/references/semantic-layer-publish-runbook.md
```

The runbook must route through public `foggy-runtime` commands and the public MCP JSON-RPC endpoint. It must not require another undeclared Skill, bypass `models validate`, or put runtime metadata inside MCP client `mcpServers`.

Report commands, outputs, ports, checksums, failures, and repairs.
