# foggy-ai-analysis Skill v0.1.1

Patch release for issue #7.

## Fixes

- Replaces the undeclared external `foggy-runtime-cli-workflow` Skill reference with bundled runtime CLI command rules inside `foggy-ai-analysis`.
- Adds release validation guidance for detecting undeclared dollar-prefixed Skill references.
- Expects the package manifest to include `skillDependencies: []` for this release.

## Release Rule

Do not overwrite the existing `v0.1.0` assets. Publish the corrected package as `v0.1.1`.

Workspace source commit:

```text
6232bf01dcf70c693de3cf97e01119facfbae610
```

## Checksums

```text
e98f3d940f106044b7388dd427893e6216c23efea878a9ae30d35683af0cf527  foggy-ai-analysis-skill-0.1.1.zip
d8572f1b098ffbcb03d62839ddc06499e05d6b9e16baaacc80ed4d7f5d01b25e  foggy-ai-analysis-skill-0.1.1-manifest.json
```
