# Release Process

The Skill source of truth currently lives in:

```text
D:\foggy-projects\foggy-data-mcp\.codex\skills\foggy-ai-analysis
```

Build from the workspace:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\package-foggy-skill.ps1 `
  -SkillName foggy-ai-analysis `
  -Version 0.1.2 `
  -RepoRoot D:\foggy-projects\foggy-data-mcp `
  -OutDir D:\foggy-projects\foggy-data-mcp\dist\skills
```

Upload release assets:

```text
foggy-ai-analysis-skill-0.1.2.zip
foggy-ai-analysis-skill-0.1.2-manifest.json
foggy-ai-analysis-skill-0.1.2-SHA256SUMS
```

Before publishing, unzip the package and verify that any dollar-prefixed Skill references are either self references or listed in `skillDependencies`. For `v0.1.1`, `skillDependencies` should be empty and no external Skill references should remain.

For `v0.1.2`, also verify:

- `references/feedback.md` contains `Where To File Issues`.
- `assets/github-issue-template.md` contains `Issue Routing`.
- Java runtime, launcher, MCP endpoint, model catalog, and query execution issues route to `foggy-projects/foggy-data-mcp-bridge`.
- CLI install, argument parsing, command UX, response formatting, and exit-code issues route to `foggy-projects/foggy-runtime-cli`.
