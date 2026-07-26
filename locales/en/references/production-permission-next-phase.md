# Production Permission Boundary

Runtime model-author permissions are available through QM `modelPermissions`,
existing field/member permissions, typed row predicates, optional opaque
data-plane Authorization, authorization-scoped caches, and safe
pre-aggregation fallback. These features govern semantic-model access; they are
not a customer IAM product.

Keep the following production concerns in the customer's platform or a separate
delivery:

```text
identity and authentication model
token issuance and verification
management-plane RBAC
datasource ownership and access scope
SQL probe restrictions
namespace and bundle write permissions
model publish approval
MCP tool permissions
audit logs
secret handling
tenant isolation
outbound network, proxy, certificate, and mTLS policy
```

Keep `--auth-code` management credentials separate from optional data
Authorization. Never store either value in TM/QM source, evidence, logs, SQL, or
cache keys. For demos, avoid production keys, private hostnames, customer rows,
and unrestricted SQL.
