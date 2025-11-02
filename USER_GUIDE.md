# Gumtree 线上测试数据清理系统 - 使用指南

## 📋 目录

- [系统概述](#系统概述)
- [功能特性](#功能特性)
- [系统架构](#系统架构)
- [快速开始](#快速开始)
- [添加测试账号](#添加测试账号)
- [手动执行清理](#手动执行清理)
- [自动化执行](#自动化执行)
- [查看报告](#查看报告)
- [常见问题](#常见问题)
- [技术细节](#技术细节)

---

## 系统概述

### 这是什么？

这是一个自动化的 Gumtree 测试数据清理系统，用于定期清理测试账号中的广告数据，保持测试环境的整洁。

### 为什么需要它？

- 🧹 **自动清理**：无需手动删除测试广告，节省时间
- 📊 **数据统计**：清楚了解每个账号的广告数量和清理情况
- 📧 **邮件通知**：每次清理后自动发送详细报告
- 🔄 **定时执行**：每天凌晨 3 点自动运行，无需人工干预
- 🌍 **多环境支持**：支持测试环境（bixi）和生产环境（prod）

### 它能做什么？

1. ✅ 自动登录多个测试账号
2. ✅ 获取每个账号的所有广告（包括活跃和非活跃）
3. ✅ 批量删除非活跃广告
4. ✅ 生成详细的统计报告
5. ✅ 发送邮件通知清理结果

---

## 功能特性

### 🎯 核心功能

| 功能 | 说明 |
|------|------|
| **批量账号处理** | 支持同时处理多个测试账号 |
| **智能筛选** | 只删除非活跃广告，保留活跃广告 |
| **详细日志** | 记录每个操作步骤，便于追踪 |
| **美观报告** | HTML 格式的可视化报告 |
| **邮件通知** | 自动发送清理摘要到指定邮箱 |

### 📊 报告内容

**邮件正文摘要：**
- 执行时间（精确到秒）
- 运行环境（prod/bixi）
- 触发方式（自动/手动）
- 总体统计（账号数、活跃/非活跃广告数、删除数）

**HTML 附件详情：**
- 精美的渐变色设计
- 响应式布局（支持手机/平板查看）
- 逐账号详细数据卡片
- 直接链接到完整日志

---

## 系统架构

### 技术栈

```
┌─────────────────────────────────────────────┐
│           GitHub Actions (调度器)            │
│   - 每天凌晨 3 点自动触发                     │
│   - 支持手动触发                              │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│         Shell 脚本 (run_cleanup_multi.sh)    │
│   - 读取账号列表                              │
│   - 调用 JMeter 执行测试                      │
│   - 生成日志文件                              │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│    JMeter 测试计划 (ad_cleanup_multi_accounts_v2.jmx) │
│   - 登录账号                                  │
│   - 获取广告列表                              │
│   - 批量删除非活跃广告                        │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│              报告生成系统                     │
│   - 解析日志文件                              │
│   - 生成 HTML 报告                            │
│   - 发送邮件通知                              │
└─────────────────────────────────────────────┘
```

### 文件结构

```
prod-ads-cleanup/
├── config/                      # 配置文件目录
│   ├── bixi.env.properties     # 测试环境配置
│   └── prod.env.properties     # 生产环境配置
├── data/                        # 数据文件目录
│   └── accounts.csv            # 账号列表（重要！）
├── scripts/                     # 脚本目录
│   └── run_cleanup_multi.sh    # 主执行脚本
├── testcases/                   # 测试用例目录
│   └── ad_cleanup_multi_accounts_v2.jmx  # JMeter 测试计划
├── .github/
│   ├── workflows/
│   │   └── daily-cleanup.yml   # GitHub Actions 工作流
│   └── report_template.html    # HTML 报告模板
├── logs/                        # 日志文件目录（自动生成）
├── reports/                     # 报告文件目录（自动生成）
└── README.md                    # 项目说明文档
```

---

## 快速开始

### 前置条件

- ✅ 有 GitHub 账号
- ✅ 有 Gumtree 测试账号
- ✅ 有权限访问此项目仓库

### 第一次使用

1. **查看当前账号列表**
   ```bash
   cat data/accounts.csv
   ```

2. **手动触发一次测试**
   - 访问：https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/actions
   - 点击 "Gumtree 广告清理任务"
   - 点击 "Run workflow"
   - 选择环境：`bixi`（建议先测试）
   - 选择发送邮件：`true`
   - 点击 "Run workflow" 按钮

3. **查看执行结果**
   - 等待任务完成（通常 1-5 分钟）
   - 查看邮箱中的报告邮件
   - 或在 Actions 页面查看详细日志

---

## 添加测试账号

### 步骤说明

#### 1. 编辑账号文件

在 GitHub 网页上直接编辑：

1. 访问：https://github.com/hanxuhao58/gumtree-prod-ads-cleanup
2. 点击 `data/accounts.csv` 文件
3. 点击右上角的 ✏️ 编辑按钮

或者在本地编辑：

```bash
cd /path/to/prod-ads-cleanup
vim data/accounts.csv
```

#### 2. 添加账号信息

文件格式：

```csv
username,password,team_member,notes,enabled
donny.han@gumtree.com,Gumtree123!,Donny Han,主测试账号,TRUE
donnyproa@proton.me,Gumtree123!,Donny ProA,第二测试账号,TRUE
```

**字段说明：**

| 字段 | 必填 | 说明 | 示例 |
|------|------|------|------|
| `username` | ✅ | 登录邮箱 | `test@gumtree.com` |
| `password` | ✅ | 登录密码 | `Password123!` |
| `team_member` | ✅ | 账号所有者 | `张三` |
| `notes` | ❌ | 备注信息 | `用于测试发帖功能` |
| `enabled` | ✅ | 是否启用 | `TRUE` 或 `FALSE` |

#### 3. 添加新账号示例

在文件末尾添加新行：

```csv
username,password,team_member,notes,enabled
donny.han@gumtree.com,Gumtree123!,Donny Han,主测试账号,TRUE
donnyproa@proton.me,Gumtree123!,Donny ProA,第二测试账号,TRUE
your.email@gumtree.com,YourPassword123!,Your Name,你的测试账号,TRUE
```

#### 4. 保存并提交

**GitHub 网页编辑：**
- 点击 "Commit changes"
- 填写提交信息：`添加测试账号 - Your Name`
- 点击 "Commit changes" 确认

**本地编辑：**
```bash
git add data/accounts.csv
git commit -m "添加测试账号 - Your Name"
git push
```

#### 5. 验证账号

添加后建议手动触发一次测试，验证账号是否正常工作：

1. 访问 Actions 页面
2. 手动触发工作流
3. 选择 `bixi` 环境（测试环境）
4. 查看日志确认你的账号是否成功处理

### 临时禁用账号

如果某个账号暂时不需要清理，可以将 `enabled` 字段改为 `FALSE`：

```csv
your.email@gumtree.com,YourPassword123!,Your Name,暂时不用,FALSE
```

系统会自动跳过 `enabled=FALSE` 的账号。

### 删除账号

直接删除对应的行即可，但建议先改为 `FALSE` 观察一段时间。

---

## 手动执行清理

### 通过 GitHub Actions 手动触发

#### 步骤：

1. **访问 Actions 页面**
   ```
   https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/actions
   ```

2. **选择工作流**
   - 点击左侧 "Gumtree 广告清理任务"

3. **触发执行**
   - 点击右上角 "Run workflow" 按钮
   - 选择参数：
     - **环境 (environment)**：
       - `bixi`：测试环境（建议先用这个测试）
       - `prod`：生产环境
     - **发送邮件 (send_email)**：
       - `true`：发送邮件报告
       - `false`：不发送邮件（仅用于测试）

4. **查看执行进度**
   - 页面会自动刷新显示执行状态
   - 点击任务名称可查看详细日志

5. **查看结果**
   - ✅ 绿色勾：执行成功
   - ❌ 红色叉：执行失败（点击查看错误日志）
   - 📧 查看邮箱接收报告邮件

### 通过本地脚本执行

如果你有本地环境（需要安装 JMeter）：

```bash
# 进入项目目录
cd /path/to/prod-ads-cleanup

# 执行清理（默认 prod 环境）
./scripts/run_cleanup_multi.sh

# 或指定 bixi 测试环境
./scripts/run_cleanup_multi.sh --env bixi
```

---

## 自动化执行

### 定时任务配置

系统已配置为**每天北京时间凌晨 3:00** 自动执行。

**时区说明：**
- 北京时间 03:00 = UTC 19:00（前一天）
- GitHub Actions 使用 UTC 时间
- 工作流中已设置 `TZ: Asia/Shanghai` 确保日志时间正确

### 查看自动执行历史

1. 访问 Actions 页面
2. 查看 "Gumtree 广告清理任务" 的执行历史
3. 带有 ⏰ 图标的是自动触发的任务

### 修改执行时间

如需修改自动执行时间，编辑 `.github/workflows/daily-cleanup.yml`：

```yaml
on:
  schedule:
    - cron: '0 19 * * *'  # UTC 19:00 = 北京时间 03:00
```

**Cron 表达式说明：**
```
┌───────────── 分钟 (0 - 59)
│ ┌───────────── 小时 (0 - 23)
│ │ ┌───────────── 日期 (1 - 31)
│ │ │ ┌───────────── 月份 (1 - 12)
│ │ │ │ ┌───────────── 星期 (0 - 6, 0 = 周日)
│ │ │ │ │
* * * * *
```

**示例：**
- `0 19 * * *`：每天 UTC 19:00（北京时间 03:00）
- `0 22 * * *`：每天 UTC 22:00（北京时间 06:00）
- `0 14 * * 1`：每周一 UTC 14:00（北京时间 22:00）

### 暂停自动执行

如需暂停自动执行，可以：

**方法 1：禁用工作流**
1. 访问 Actions 页面
2. 点击 "Gumtree 广告清理任务"
3. 点击右上角 "..." 菜单
4. 选择 "Disable workflow"

**方法 2：注释掉 schedule**
编辑 `.github/workflows/daily-cleanup.yml`：
```yaml
on:
  # schedule:
  #   - cron: '0 19 * * *'
  workflow_dispatch:
    # ...
```

---

## 查看报告

### 邮件报告

**接收邮箱：** hanxuhao@58.com

**邮件格式：**

**主题：**
```
Gumtree 线上测试数据清理日报 - 2025年11月03日 [prod]
```

**正文示例：**
```
✅ Gumtree 线上测试数据清理任务执行完成

📅 执行时间: 2025年11月03日 03:00:15
🌍 运行环境: prod
🚀 触发方式: 自动定时

📊 执行摘要
================
处理账号数: 2 个
活跃广告: 0 个
非活跃广告: 123 个
成功删除: 123 个

📄 详细报告请查看附件

🔗 查看完整日志:
https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/actions/runs/xxxxx

---
此邮件由 GitHub Actions 自动发送
```

**HTML 附件：**
- 打开 `report_summary.html` 查看精美的可视化报告
- 包含每个账号的详细统计
- 支持在手机/平板上查看

### 在 GitHub 查看报告

1. **访问 Actions 页面**
   ```
   https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/actions
   ```

2. **点击具体的执行记录**

3. **查看日志**
   - 展开 "运行广告清理" 步骤查看详细日志
   - 展开 "生成报告摘要" 查看统计信息

4. **下载附件**
   - 滚动到页面底部 "Artifacts" 区域
   - 下载 `cleanup-logs-xxx.zip`
   - 解压后查看日志和 HTML 报告

---

## 常见问题

### Q1: 为什么我的账号没有被处理？

**可能原因：**
1. ❌ `enabled` 字段设置为 `FALSE`
2. ❌ 账号信息格式不正确（检查逗号、引号）
3. ❌ 密码错误导致登录失败

**解决方法：**
- 检查 `data/accounts.csv` 中的账号配置
- 查看执行日志中的错误信息
- 手动登录一次确认账号密码正确

### Q2: 如何只测试我的账号？

**方法 1：临时禁用其他账号**
```csv
username,password,team_member,notes,enabled
other@gumtree.com,Pass123!,Other,暂时禁用,FALSE
your@gumtree.com,Pass456!,You,测试中,TRUE
```

**方法 2：创建测试分支**
```bash
git checkout -b test-my-account
# 编辑 accounts.csv，只保留你的账号
git add data/accounts.csv
git commit -m "测试分支"
git push origin test-my-account
```

然后在 GitHub Actions 中选择 `test-my-account` 分支执行。

### Q3: 为什么没有收到邮件？

**检查清单：**
1. ✅ 执行时是否选择了 `send_email: true`
2. ✅ 检查垃圾邮件文件夹
3. ✅ 确认邮箱地址正确（`to: hanxuhao@58.com`）
4. ✅ 查看 Actions 日志中的 "发送邮件报告" 步骤是否成功

**修改接收邮箱：**
编辑 `.github/workflows/daily-cleanup.yml`：
```yaml
- name: 发送邮件报告
  uses: dawidd6/action-send-mail@v3
  with:
    to: your-email@example.com  # 修改这里
```

### Q4: 如何查看某个账号的详细日志？

1. 下载 Artifacts 中的日志文件
2. 解压后打开 `logs/cleanup_YYYYMMDD_HHMMSS.log`
3. 搜索你的账号邮箱
4. 查看该账号的处理过程

### Q5: 删除操作可以撤销吗？

❌ **不可以！** 删除操作是不可逆的。

**建议：**
- 首次使用时先在 `bixi` 测试环境测试
- 确认无误后再在 `prod` 生产环境使用
- 重要账号可以设置 `enabled=FALSE` 暂时不处理

### Q6: 如何添加更多接收邮件的人？

编辑 `.github/workflows/daily-cleanup.yml`：

```yaml
- name: 发送邮件报告
  uses: dawidd6/action-send-mail@v3
  with:
    to: hanxuhao@58.com,colleague1@58.com,colleague2@58.com
    # 多个邮箱用逗号分隔
```

### Q7: 系统会删除活跃的广告吗？

❌ **不会！** 系统只删除**非活跃（inactive）**的广告。

活跃广告会被保留，日志中会显示：
```
📊 发现活跃广告: 5 个
💤 非活跃广告: 10 个
🗑️  成功删除: 10 个
```

### Q8: 如何在本地运行？

**前置条件：**
- 安装 JMeter 5.x
- 配置 `JMETER_HOME` 环境变量

**执行命令：**
```bash
cd /path/to/prod-ads-cleanup
./scripts/run_cleanup_multi.sh --env bixi
```

**查看日志：**
```bash
tail -f logs/cleanup_*.log
```

---

## 技术细节

### 环境配置

系统支持两个环境：

#### 1. BIXI 测试环境
- 配置文件：`config/bixi.env.properties`
- 域名：`mobile-apps-bff.bixi.gumtree.io`
- 用途：开发测试，不影响生产数据

#### 2. PROD 生产环境（默认）
- 配置文件：`config/prod.env.properties`
- 域名：`mobile-apps-bff.gumtree.com`
- 用途：清理真实的测试账号数据

### JMeter 测试计划流程

```
1. 读取账号列表 (CSV Data Set Config)
   ↓
2. 循环处理每个账号
   ↓
3. 登录账号 (POST /login)
   ↓
4. 获取 MyGumtree 页面 (GET /my-gumtree)
   ↓
5. 获取所有广告列表 (GET /my-ads)
   ↓
6. 解析广告数据 (JSON Extractor)
   ↓
7. 筛选非活跃广告
   ↓
8. 批量删除 (DELETE /ads/{id})
   ↓
9. 记录统计信息
   ↓
10. 处理下一个账号
```

### 日志格式

日志文件位置：`logs/cleanup_YYYYMMDD_HHMMSS.log`

**日志级别：**
- `🎯` 开始处理
- `✅` 成功操作
- `❌` 失败操作
- `📊` 统计信息
- `⚠️` 警告信息

**示例日志：**
```
🎯 开始处理账号: donny.han@gumtree.com
✅ 登录成功 (HTTP 200)
✅ 进入 MyGumtree 页面成功 (HTTP 200)
📊 发现活跃广告: 0 个
💤 非活跃广告: 15 个
🗑️  成功删除: 15 个
✅ 账号 donny.han@gumtree.com 处理完成
```

### 报告生成逻辑

1. **数据提取**
   - 从日志文件中提取统计信息
   - 使用 `grep` 和 `awk` 解析日志

2. **HTML 生成**
   - 使用模板文件 `.github/report_template.html`
   - 用 `sed` 替换占位符

3. **邮件发送**
   - 使用 GitHub Actions 的 `dawidd6/action-send-mail@v3`
   - SMTP 服务器：`smtp.gmail.com`

### 安全性说明

**敏感信息保护：**
- ✅ 密码存储在私有仓库中
- ✅ 邮件凭证使用 GitHub Secrets
- ✅ 日志中不显示完整密码
- ✅ 仅授权人员可访问仓库

**GitHub Secrets 配置：**
- `EMAIL_USERNAME`：发送邮件的 Gmail 账号
- `EMAIL_PASSWORD`：Gmail 应用专用密码

---

## 联系支持

### 遇到问题？

1. **查看文档**
   - 先阅读本文档的常见问题部分
   - 查看 `README.md` 了解更多技术细节

2. **查看日志**
   - GitHub Actions 执行日志
   - 下载 Artifacts 中的详细日志文件

3. **联系维护者**
   - 项目维护者：Donny Han
   - 邮箱：hanxuhao@58.com
   - GitHub：https://github.com/hanxuhao58

### 提交问题

在 GitHub 上创建 Issue：
```
https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/issues/new
```

**Issue 模板：**
```markdown
### 问题描述
简要描述遇到的问题

### 复现步骤
1. 第一步
2. 第二步
3. ...

### 预期行为
应该发生什么

### 实际行为
实际发生了什么

### 环境信息
- 环境：prod / bixi
- 执行时间：YYYY-MM-DD HH:MM
- Actions Run ID：xxxxx

### 日志截图
（如有）
```

---

## 附录

### 相关文档

- [README.md](README.md) - 项目技术文档
- [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) - GitHub Actions 配置指南
- [MULTI_ACCOUNT_README.md](MULTI_ACCOUNT_README.md) - 多账号处理说明
- [ACCOUNTS_GUIDE.md](ACCOUNTS_GUIDE.md) - 账号管理指南

### 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v2.0 | 2025-11-03 | 添加 HTML 报告、优化邮件格式 |
| v1.5 | 2025-11-02 | 支持手动触发、修复账号统计 |
| v1.0 | 2025-11-01 | 初始版本，支持自动清理 |

### 术语表

| 术语 | 说明 |
|------|------|
| **活跃广告** | 状态为 active 的广告，正在展示中 |
| **非活跃广告** | 状态为 inactive 的广告，已下线或过期 |
| **BIXI** | Gumtree 的测试环境 |
| **PROD** | Gumtree 的生产环境 |
| **JMeter** | Apache JMeter，性能测试工具 |
| **GitHub Actions** | GitHub 的 CI/CD 自动化平台 |
| **Artifacts** | GitHub Actions 生成的文件产物 |

---

## 总结

这个系统可以帮助你：

✅ **节省时间** - 自动化清理，无需手动操作  
✅ **保持整洁** - 定期清理测试数据  
✅ **数据透明** - 详细的统计报告  
✅ **安全可靠** - 只删除非活跃广告  
✅ **易于使用** - 简单的配置和操作  

如有任何问题，欢迎随时联系！

---

**文档版本：** v1.0  
**最后更新：** 2025-11-03  
**维护者：** Donny Han (hanxuhao@58.com)

