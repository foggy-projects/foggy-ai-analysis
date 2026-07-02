# 生产权限后续阶段

当前公开 onboarding 面向 dev/test。不要在本 onboarding 流程中实现生产权限、auth、RBAC、审计或治理。

如果用户询问生产可用性，说明下一阶段应覆盖：

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

当前 demo 中应避免使用生产 key、私有 hostname、客户行数据和不受限 SQL。
