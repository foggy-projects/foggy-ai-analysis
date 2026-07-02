# Question Bank 与调优

当 query model 已存在，并且用户需要自然语言质量检查时，使用本 reference。

## 构建 Question Bank

创建 case，把用户问题映射到期望 query payload 和验收检查：

```text
id
question
model
payload
expected behavior
assertion
status: executable | needs-clarification
```

需要包含正向 case、边界过滤 case、排名/排序 case，以及至少一个明确 out-of-scope case。

## 运行与分类

对每个可执行 payload：

```powershell
foggy-runtime --base-url <url> --namespace <ns> query validate <model> --payload <payload.json>
foggy-runtime --base-url <url> --namespace <ns> query execute <model> --payload <payload.json>
```

将未命中分类为：

```text
prompt wording
field caption or description
missing business synonym
wrong enum mapping
missing measure or dimension
query payload defect
runtime/model bug
needs clarification
```

## 调优

优先按以下顺序修复语义：

1. 改进 TM/QM description 和 caption。
2. 添加业务同义词和枚举解释。
3. 澄清单位和日期语义。
4. 只有源数据支持时，才添加缺失 dimension/measure。
5. 模型语义清楚后再调整 prompt。

重新运行受影响 case，并记录调优前后的证据。
