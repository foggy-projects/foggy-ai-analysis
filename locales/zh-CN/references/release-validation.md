# Release 验证

使用本 reference 验证来自公开 release 资产的正式 Skill 包。

## 约束

```text
do not use foggy-runtime-cli source checkout
do not set PYTHONPATH=src
download Skill from https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v0.1.5
download CLI from https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v0.1.10
download Java launcher from https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/runtime-api-launcher-v0.1.2
validate all SHA256SUMS
scan the unzipped Skill for undeclared dollar-prefixed Skill references
```

## Smoke

1. 在隔离环境安装 CLI。
2. 除非端口被占用，在 `18066` 启动 Java runtime。
3. 执行 `wait-ready` 和 `capabilities`。
4. 如果没有数据源，使用 `--use-default-datasource` 跑内置 sales-drop replay。
5. 停止 runtime，并验证端口已释放。

## 静态 Skill 引用检查

解压 Skill 后，搜索 Skill-style reference：

```powershell
rg -n --pcre2 '(?<![A-Za-z0-9_-])\$([a-z][a-z0-9]*(?:-[a-z0-9]+)+)(?![A-Za-z0-9_-])' <unzipped-skill-dir>
```

除非 package manifest 声明了额外 `skillDependencies`，否则只允许 `$foggy-ai-analysis` 自引用。任何未声明的外部 Skill 引用都会阻塞 release validation。

报告命令、输出、端口、checksum、失败点和修复动作。
