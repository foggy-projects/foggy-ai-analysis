# 内嵌 Java 集成

仅当用户想把 Foggy Dataset Model 嵌入现有 Java/Spring Boot 应用时使用本 reference。普通分析 onboarding 优先使用独立 Runtime API launcher。

## 前置检查

先检查项目：

- 存在 Maven `pom.xml`。
- 使用 Spring Boot 3.x 和 JDK 17+。
- 已配置 JDBC datasource，或用户已选择 datasource。
- 项目中不存在冲突的 Foggy 集成。

如果不是 Maven 或 Spring Boot 项目，先说明差距；除非用户要求手工模板，否则不要修改 build 文件。

## Maven 依赖

版本来自目标 release、项目已有 BOM 或用户指定版本。不要硬编码旧 beta 版本。

```xml
<properties>
    <foggy-model.version>target-version</foggy-model.version>
</properties>

<dependency>
    <groupId>com.foggysource</groupId>
    <artifactId>foggy-dataset-model</artifactId>
    <version>${foggy-model.version}</version>
</dependency>
```

按 datasource 类型补充数据库驱动，例如 `mysql-connector-j`、`postgresql` 或 `sqlite-jdbc`。

## 启用 Foggy

在 Spring Boot application 或集成配置类上添加 `@EnableFoggyFramework`：

```java
import com.foggyframework.core.annotates.EnableFoggyFramework;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableFoggyFramework(bundleName = "my-project")
public class Application {
}
```

只有需要模型隔离时才配置 `namespace`：

```java
@EnableFoggyFramework(bundleName = "odoo", namespace = "odoo")
```

`bundleName` 使用小写中划线。namespace 必须与上游项目隔离规则一致。

## Datasource 与模型

创建模型前确认 `spring.datasource.*`。除非项目已有明确模型目录，classpath 模型使用 `src/main/resources/foggy/templates/`。

最小目录：

```text
src/main/resources/foggy/templates/
  model/
    ExampleModel.tm
  query/
    ExampleQueryModel.qm
  model-list.yml
```

文件系统模型目录使用 external bundle：

```yaml
foggy:
  bundle:
    external:
      enabled: true
      bundles:
        - name: my-models
          namespace: dev
          path: /data/my-models
          watch: true
```

## 验证

如果内嵌应用暴露 Runtime API v1，使用与独立 runtime 相同的主验证路径：

```powershell
foggy-runtime --base-url <app-runtime-url> --namespace <ns> wait-ready --timeout-seconds 90
foggy-runtime --base-url <app-runtime-url> --namespace <ns> capabilities
foggy-runtime --base-url <app-runtime-url> --namespace <ns> models validate --models-dir <models-dir> --include-stack-trace
foggy-runtime --base-url <app-runtime-url> --namespace <ns> models refresh
foggy-runtime --base-url <app-runtime-url> --namespace <ns> models describe <QueryModelName>
```

只有 Runtime API 不可用且项目明确仍支持旧 Spring endpoint 时，才使用旧验证 endpoint，并标记为 legacy fallback。

## 自检

结束前确认：

- `pom.xml` 包含 `foggy-dataset-model` 和已解析版本。
- `@EnableFoggyFramework` 的 `bundleName` 非空。
- 选定数据库的 datasource 配置存在。
- 模型目录存在，或 external bundle 指向真实目录。
- Runtime API validate、refresh、describe 成功；如果 Runtime API capability 缺失，清楚报告缺口。
