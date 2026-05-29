# 升级到 Developer/Enterprise

Community Edition 对个人使用完全免费。当你需要更多时，可以无缝升级。

## 为什么升级？

| 功能 | Community | Developer | Enterprise |
|---|---|---|---|
| 记忆原子 | 50,000 | 无限 | 无限 |
| Agent / 实例 | 5 | 无限 | 无限 |
| One-Shot Recall | ✅ | ✅ | ✅ |
| 向量语义搜索 | ❌ | ✅ | ✅ |
| 观察捕获与提升 | ❌ | ✅ | ✅ |
| Consolidation 自动化 | ❌ | ✅ | ✅ |
| 域包 | ❌ | 软件工程 | 全部 |
| SSO / RBAC | ❌ | ❌ | ✅ |

## 如何升级

### 1. 获取 License Key

访问 [hmg2ai.com/#pricing](https://hmg2ai.com/#pricing) 购买 Developer 或 Enterprise 许可。

### 2. 应用 License Key

```bash
hmg license apply <your-key>xxxxxxx.yyyyyyyyyyyy
```

### 3. 验证

```bash
hmg license status
# Edition: Developer
# Source: license.key
# Features: unlimited atoms, one-shot-recall, semantic-search, ...
```

就这么简单。同一个二进制文件，不需要重新安装或重新配置。

## One-Shot Recall 示例

```bash
# Developer/Enterprise 专属
hmg recall --one-shot
```

或通过 MCP：

```json
{
  "tool": "memory_agent_brief",
  "arguments": {
    "query": "当前任务状态",
    "response_profile": "compact"
  }
}
```

返回完整的会话上下文：当前状态、先前决策、未解决风险、后续步骤。

## 常见问题

### 会丢失 Community 数据吗？

不会。升级不会影响任何现有数据。所有记忆、修正和治理历史完整保留。

### 可以降级吗？

可以。删除 license 文件即可回到 Community Edition。超出 Community 限制的数据仍然存在，只是不能新增。

### License 如何验证？

License 使用 ed25519 数字签名验证。离线验证，不需要网络连接。支持 7 天离线宽限期。

## Enterprise

如需 Enterprise 版本（SSO、RBAC、审计导出、自定义域包），请联系我们：

- Email: security@hmg2ai.com
- Website: [hmg2ai.com](https://hmg2ai.com/)
