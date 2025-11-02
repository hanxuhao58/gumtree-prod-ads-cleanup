# GitHub Actions 自动化配置指南

## 📋 功能说明

已创建 GitHub Actions 工作流，实现：
- ✅ 每天凌晨 2:00 UTC（北京时间 10:00 AM）自动运行
- ✅ 自动执行广告清理任务
- ✅ 生成详细报告
- ✅ 发送邮件到 hanxuhao@58.com
- ✅ 支持手动触发

## 🔧 配置步骤

### 1. 配置 GitHub Secrets

访问仓库设置页面：
```
https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/settings/secrets/actions
```

点击 **"New repository secret"** 添加以下密钥：

#### 必需的 Secrets：

**EMAIL_USERNAME** - 发件邮箱账号
```
值: 你的 Gmail 邮箱地址
例如: your-email@gmail.com
```

**EMAIL_PASSWORD** - 邮箱应用专用密码
```
值: Gmail 应用专用密码（不是登录密码）
```

> 💡 **如何获取 Gmail 应用专用密码**：
> 1. 访问：https://myaccount.google.com/apppasswords
> 2. 登录你的 Google 账号
> 3. 选择应用：选择"邮件"
> 4. 选择设备：选择"其他（自定义名称）"，输入"GitHub Actions"
> 5. 点击"生成"，复制 16 位密码
> 6. 将密码粘贴到 GitHub Secrets 的 EMAIL_PASSWORD 中

### 2. 配置账号信息

确保 `data/accounts.csv` 包含需要处理的账号：

```csv
username,password,team_member,notes,enabled
donny.han@gumtree.com,Gumtree123!,Donny Han,主测试账号,TRUE
donnyproa@proton.me,Gumtree123!,Donny ProA,第二测试账号,TRUE
```

⚠️ **重要**：
- 由于是私有仓库，账号信息相对安全
- 建议定期更换密码
- 可以考虑将密码也存储在 GitHub Secrets 中（需修改脚本）

### 3. 提交并推送配置

```bash
cd /Users/a58/Documents/Gumtree/prod-ads-cleanup

git add .github/workflows/daily-cleanup.yml
git add GITHUB_ACTIONS_SETUP.md
git commit -m "feat: 添加 GitHub Actions 自动化工作流

- 每日凌晨自动运行清理任务
- 生成详细报告
- 发送邮件通知到 hanxuhao@58.com"
git push
```

## 📅 运行时间

- **自动运行**: 每天凌晨 2:00 UTC（北京时间上午 10:00）
- **手动触发**: 访问 Actions 页面，点击 "Run workflow"

## 📧 邮件报告内容

邮件将包含：

**主题**：
```
Gumtree 广告清理日报 - [运行编号]
```

**正文**：
```
Gumtree 广告清理任务执行完成

执行时间: 2025-11-03 10:00:00
运行编号: 123

📊 执行摘要
================
处理账号数: 2
活跃广告: 0 个
非活跃广告: 20 个
成功删除: 0 个

📄 详细报告请查看附件

🔗 查看完整日志:
https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/actions/runs/xxx
```

**附件**：
- `report_summary.txt` - 详细报告（包含每个账号的统计信息）

## 🔍 查看运行结果

### 方式一：GitHub Actions 页面

访问：
```
https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/actions
```

可以看到：
- 所有运行历史
- 每次运行的详细日志
- 下载日志和报告文件

### 方式二：邮件通知

每次运行后会自动发送邮件到 `hanxuhao@58.com`，包含：
- 执行摘要
- 详细报告附件
- 完整日志链接

## 🎯 手动触发运行

如果需要立即运行（不等到凌晨）：

1. 访问：https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/actions
2. 点击左侧 "每日广告清理任务"
3. 点击右上角 "Run workflow" 按钮
4. 选择分支（main）
5. 点击绿色 "Run workflow" 按钮

## ⚙️ 自定义配置

### 修改运行时间

编辑 `.github/workflows/daily-cleanup.yml`：

```yaml
on:
  schedule:
    # 修改这里的 cron 表达式
    - cron: '0 2 * * *'  # 每天 2:00 UTC
```

**常用时间示例**：
```
'0 2 * * *'   # 每天 2:00 UTC (北京时间 10:00)
'0 18 * * *'  # 每天 18:00 UTC (北京时间 02:00)
'0 0 * * 1'   # 每周一 0:00 UTC
'0 0 1 * *'   # 每月 1 号 0:00 UTC
```

### 修改收件人

编辑 `.github/workflows/daily-cleanup.yml`：

```yaml
- name: 发送邮件报告
  with:
    to: hanxuhao@58.com  # 修改为其他邮箱
    # 或添加多个收件人（逗号分隔）
    to: hanxuhao@58.com,another@example.com
```

## 🔒 安全建议

1. **保护 Secrets**
   - 永远不要在代码中硬编码密码
   - 定期轮换密码和应用专用密码
   - 限制仓库访问权限

2. **账号安全**
   - 使用强密码
   - 启用两步验证
   - 定期审查账号活动

3. **日志保留**
   - Actions 日志默认保留 30 天
   - 可以下载重要日志本地保存

## 📊 监控与维护

### 检查运行状态

```bash
# 查看最近的运行
gh run list --repo hanxuhao58/gumtree-prod-ads-cleanup

# 查看特定运行的详情
gh run view [RUN_ID] --repo hanxuhao58/gumtree-prod-ads-cleanup

# 下载运行日志
gh run download [RUN_ID] --repo hanxuhao58/gumtree-prod-ads-cleanup
```

### 常见问题

**Q: 为什么没有收到邮件？**
A: 检查：
1. GitHub Secrets 是否正确配置
2. Gmail 应用专用密码是否有效
3. 检查垃圾邮件文件夹
4. 查看 Actions 日志中的错误信息

**Q: 如何暂停自动运行？**
A: 
1. 访问 Actions 页面
2. 点击工作流名称
3. 点击右上角 "..." 菜单
4. 选择 "Disable workflow"

**Q: 如何查看历史报告？**
A: 
1. 访问 Actions 页面
2. 点击任意运行记录
3. 下载 "cleanup-logs-xxx" 附件

## 📞 技术支持

如有问题，可以：
1. 查看 Actions 运行日志
2. 检查 GitHub Secrets 配置
3. 验证邮箱设置

---

**配置完成后**，工作流将在下次预定时间自动运行，或者你可以手动触发测试。

