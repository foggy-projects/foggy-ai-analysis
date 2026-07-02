# Embedded Java Integration

Use this reference only when the user wants to embed Foggy Dataset Model into an existing Java/Spring Boot application. For ordinary analysis onboarding, prefer the standalone Runtime API launcher.

## Preconditions

Inspect the project first:

- Maven `pom.xml` exists.
- Spring Boot 3.x and JDK 17+ are used.
- A JDBC datasource is configured or the user has chosen one.
- The project does not already have a conflicting Foggy integration.

If the project is not Maven or not Spring Boot, explain the gap and stop before editing build files unless the user asks for a manual template.

## Maven Dependency

Use the Foggy version from the target release, the existing project BOM, or the user's requested version. Do not hard-code an old beta version.

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

Add the database driver that matches the configured datasource, such as `mysql-connector-j`, `postgresql`, or `sqlite-jdbc`.

## Enable Foggy

Add `@EnableFoggyFramework` to the Spring Boot application or integration configuration:

```java
import com.foggyframework.core.annotates.EnableFoggyFramework;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableFoggyFramework(bundleName = "my-project")
public class Application {
}
```

Use `namespace` only when the project needs model isolation:

```java
@EnableFoggyFramework(bundleName = "odoo", namespace = "odoo")
```

Keep `bundleName` lowercase and hyphenated. Keep namespace values aligned with the upstream project's isolation rule.

## Datasource And Models

Confirm `spring.datasource.*` before creating models. Use `src/main/resources/foggy/templates/` for classpath model files unless the project already has a documented model directory.

Minimal layout:

```text
src/main/resources/foggy/templates/
  model/
    ExampleModel.tm
  query/
    ExampleQueryModel.qm
  model-list.yml
```

For file-system model directories, configure an external bundle:

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

## Validation

If the embedded app exposes Runtime API v1, use the same primary validation path as the standalone runtime:

```powershell
foggy-runtime --base-url <app-runtime-url> --namespace <ns> wait-ready --timeout-seconds 90
foggy-runtime --base-url <app-runtime-url> --namespace <ns> capabilities
foggy-runtime --base-url <app-runtime-url> --namespace <ns> models validate --models-dir <models-dir> --include-stack-trace
foggy-runtime --base-url <app-runtime-url> --namespace <ns> models refresh
foggy-runtime --base-url <app-runtime-url> --namespace <ns> models describe <QueryModelName>
```

Use legacy Spring validation endpoints only when Runtime API is not available and the project explicitly still supports them. Label that result as a legacy fallback.

## Self-Check

Before reporting completion, verify:

- `pom.xml` includes `foggy-dataset-model` and the resolved version.
- `@EnableFoggyFramework` has a non-empty `bundleName`.
- Datasource settings exist for the chosen database.
- Model directory exists or an external bundle points to a real directory.
- Runtime API validation, refresh, and describe succeeded, or the missing Runtime API capability is reported clearly.
