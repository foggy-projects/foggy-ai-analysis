# Production Permission Next Phase

Current public onboarding is dev/test-oriented. Do not implement production permission, auth, RBAC, audit, or governance inside this onboarding flow.

When asked about production readiness, explain that the next phase should cover:

```text
identity and authentication model
runtime API authorization
datasource ownership and access scope
SQL probe restrictions
namespace and bundle write permissions
model publish approval
MCP tool permissions
audit logs
secret handling
tenant isolation
```

For current demos, avoid production keys, private hostnames, customer rows, and unrestricted SQL.
