# Gumtree 广告批量删除 - 多账号自动化工具

## 📋 项目简介

自动化批量删除工具，支持多账号轮训处理。通过模拟用户操作实现广告清理。

## 🚀 快速开始

### 1. 配置账号

编辑 `data/accounts.csv`：

```csv
username,password,user_id,account_id,team_member,notes,enabled
donny.han@gumtree.com,Gumtree123!,2917707,2928083,Donny Han,主测试账号,TRUE
donnyproa@proton.me,Gumtree123!,,,Donny ProA,第二测试账号,TRUE
```

**字段说明**：
- `username` - 登录邮箱（必填）
- `password` - 登录密码（必填）
- `enabled` - TRUE=处理，FALSE=跳过（必填）
- 其他字段可选

### 2. 运行清理

```bash
cd scripts
bash run_cleanup_multi.sh                # 生产环境（默认）

# 切换到测试环境（bixi）
bash run_cleanup_multi.sh --env bixi
```

### 3. 查看结果

```bash
# 查看日志
cat logs/multi_cleanup_*.log

# 打开HTML报告
open reports/multi_cleanup_*_html/index.html
```

## 📁 项目结构

```
jmeter-ad-cleanup/
├── config/
│   └── bixi.env.properties       # 环境配置
├── data/
│   └── accounts.csv              # ⭐ 账号列表
├── testcases/
│   └── ad_cleanup_multi_accounts_v2.jmx  # ⭐ JMeter脚本
├── scripts/
│   └── run_cleanup_multi.sh      # ⭐ 运行脚本
├── data/                         # Token和数据存储
├── logs/                         # 执行日志
├── reports/                      # HTML报告
├── README.md                     # 项目说明
├── ACCOUNTS_GUIDE.md             # 账号管理指南
└── MULTI_ACCOUNT_README.md       # 详细使用说明
```

## 🔧 账号管理

### 添加账号

**使用Excel（推荐）**：
1. 用Excel打开 `data/accounts.csv`
2. 添加新行
3. 保存为CSV格式

**直接编辑**：
```csv
new_user@example.com,Password123!,,,New User,新成员,TRUE
```

### 启用/禁用账号

修改 `enabled` 字段：
- `TRUE` - 账号会被处理
- `FALSE` - 账号会被跳过

## 📊 工作流程

```
读取accounts.csv → 循环每个账号 → 登录 → 提取广告ID → 批量删除 → 统计报告
```

对于每个账号：
1. 🔐 登录获取Token
2. 📋 访问MyGumtree页面提取活跃广告ID
3. 🗑️  批量删除所有活跃广告（间隔500ms）
4. 📊 生成统计报告

## ⚙️ 环境配置

环境配置文件：
- 生产（PROD）：`config/prod.env.properties` - **默认环境**
- 测试（BIXI）：`config/bixi.env.properties`

- `HOST_BFF` - API主机
- `DELETE_DELAY_MS` - 删除间隔（默认500ms）
- 其他平台相关配置

## 📝 注意事项

⚠️ **重要**：
1. 删除操作不可撤销
2. 建议先在测试账号上验证
3. 确认账号列表无误后再执行
4. 定期备份重要数据

🔴 生产环境特别提示（默认环境）：
- **默认运行即为生产环境**，将对线上账户与广告生效，谨慎操作
- 确保 `data/accounts.csv` 仅包含需要处理且 `enabled=TRUE` 的生产账号
- 如需测试，请使用 `--env bixi` 切换到测试环境
- 当前生产站点：`https://www.gumtree.com/`

## 🔒 安全建议

```bash
# 保护账号文件
chmod 600 data/accounts.csv

# 如需保密，可添加到.gitignore
# echo "data/accounts.csv" >> .gitignore
```

## 🤖 自动化运行

已配置 GitHub Actions 工作流，支持：
- ✅ 每天凌晨自动运行
- ✅ 生成详细报告
- ✅ 发送邮件通知

**配置指南**: [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)

## 📚 详细文档

- **账号管理详细指南**: [ACCOUNTS_GUIDE.md](ACCOUNTS_GUIDE.md)
- **多账号使用说明**: [MULTI_ACCOUNT_README.md](MULTI_ACCOUNT_README.md)
- **GitHub Actions 配置**: [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)

## 🆘 常见问题

### Q: 如何只处理部分账号？
A: 将不需要处理的账号的 `enabled` 设置为 `FALSE`

### Q: 如何查看某个账号的处理结果？
A: 在日志中搜索：`grep "账号名" logs/multi_cleanup_*.log`

### Q: CSV文件格式错误怎么办？
A: 确保文件编码为UTF-8，没有Windows换行符（\r\n）

## 📞 技术支持

查看日志了解详细错误：
```bash
tail -100 logs/multi_cleanup_*.log
```

---

**版本**: 多账号 v2.0  
**更新日期**: 2025-11-03  
**默认环境**: PROD (mobile-apps-bff.gumtree.com)  
**测试环境**: BIXI (mobile-apps-bff.bixi.gumtree.io)
