# Release Process

The Skill source of truth currently lives in:

```text
D:\foggy-projects\foggy-data-mcp\.codex\skills\foggy-ai-analysis
```

Build from the workspace:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\package-foggy-skill.ps1 `
  -SkillName foggy-ai-analysis `
  -Version 0.1.0 `
  -RepoRoot D:\foggy-projects\foggy-data-mcp `
  -OutDir D:\foggy-projects\foggy-data-mcp\dist\skills
```

Upload release assets:

```text
foggy-ai-analysis-skill-0.1.0.zip
foggy-ai-analysis-skill-0.1.0-manifest.json
foggy-ai-analysis-skill-0.1.0-SHA256SUMS
```

