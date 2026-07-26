# 生产权限边界

Runtime 已支持由模型作者配置的 QM `modelPermissions`、既有字段/成员权限、typed 行谓词、
可选 opaque 数据面 Authorization、授权隔离缓存和权限不等价时的安全预聚合回源。
这些能力治理语义模型访问，但不等同于客户 IAM 产品。

以下生产事项应留在客户平台或独立交付中：

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

`--auth-code` 管理凭据必须与可选数据 Authorization 分离；两者都不能写入 TM/QM 源码、
证据、日志、SQL 或缓存 key。当前 demo 中应避免使用生产 key、私有 hostname、客户行数据
和不受限 SQL。
