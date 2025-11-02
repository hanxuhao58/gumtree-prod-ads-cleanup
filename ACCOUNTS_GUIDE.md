# 账号管理指南

## 📋 账号文件格式

账号信息存储在 `data/accounts.csv` 文件中，使用Excel或任何文本编辑器都可以编辑。

### CSV文件格式

```csv
username,password,user_id,account_id,team_member,notes,enabled
donny.han@gumtree.com,Gumtree123!,2917707,2928083,Donny Han,主测试账号,TRUE
donnyproa@proton.me,Gumtree123!,,,Donny ProA,第二测试账号,TRUE
```

### 字段说明

| 字段            | 说明       | 是否必填 | 示例                  |
| --------------- | ---------- | -------- | --------------------- |
| `username`    | 登录邮箱   | ✅ 必填  | donny.han@gumtree.com |
| `password`    | 登录密码   | ✅ 必填  | Gumtree123!           |
| `user_id`     | 用户ID     | ⚪ 可选  | 2917707               |
| `account_id`  | 账号ID     | ⚪ 可选  | 2928083               |
| `team_member` | 团队成员名 | ⚪ 可选  | Donny Han             |
| `notes`       | 备注说明   | ⚪ 可选  | 主测试账号            |
| `enabled`     | 是否启用   | ✅ 必填  | TRUE/FALSE            |

## 📝 如何添加新账号

### 方法1: 使用Excel编辑（推荐）

1. 用Excel打开 `data/accounts.csv`
2. 在最后一行添加新账号信息
3. 保存为CSV格式

**Excel模板**:

| username          | password | user_id | account_id | team_member | notes     | enabled |
| ----------------- | -------- | ------- | ---------- | ----------- | --------- | ------- |
| test1@example.com | Pass123! |         |            | Test User 1 | 测试账号1 | TRUE    |
| test2@example.com | Pass123! |         |            | Test User 2 | 测试账号2 | TRUE    |

### 方法2: 使用文本编辑器

打开 `data/accounts.csv`，添加一行：

```csv
test3@example.com,Pass123!,,,Test User 3,测试账号3,TRUE
```

### 方法3: 使用脚本批量添加

```bash
cd data

# 添加单个账号
echo "test4@example.com,Pass123!,,,Test User 4,测试账号4,TRUE" >> accounts.csv

# 或使用Python脚本
python3 << 'EOF'
import csv

new_accounts = [
    ['test5@example.com', 'Pass123!', '', '', 'Test User 5', '测试账号5', 'TRUE'],
    ['test6@example.com', 'Pass123!', '', '', 'Test User 6', '测试账号6', 'TRUE'],
]

with open('accounts.csv', 'a', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerows(new_accounts)
  
print(f"✅ 添加了 {len(new_accounts)} 个账号")
EOF
```

## 🔧 账号管理操作

### 启用/禁用账号

修改 `enabled` 字段：

- `TRUE` - 账号会被处理
- `FALSE` - 账号会被跳过

```csv
# 禁用账号
test1@example.com,Pass123!,,,Test User 1,临时禁用,FALSE

# 启用账号
test2@example.com,Pass123!,,,Test User 2,正常使用,TRUE
```

### 删除账号

直接删除对应的CSV行即可。

### 查看启用的账号

```bash
# 显示所有启用的账号
grep ",TRUE$" data/accounts.csv
```

## 🔒 安全建议

### 1. 密码保护

**不推荐**: 明文密码存储在Git仓库中

**推荐做法**:

```bash
# 添加到.gitignore（如需保密）
echo "data/accounts.csv" >> .gitignore

# 创建模板文件供团队参考
cp data/accounts.csv data/accounts.csv.template

# 清空模板中的敏感信息
sed 's/,[^,]*,/,YOUR_PASSWORD,/g' data/accounts.csv.template
```

### 2. 权限控制

```bash
# 设置文件权限，只允许当前用户读写
chmod 600 data/accounts.csv
```

### 3. 环境变量方式（高级）

可以将密码存储在环境变量中：

```csv
username,password,user_id,account_id,team_member,notes,enabled
test@example.com,${PASSWORD},,,Test User,使用环境变量,TRUE
```

然后在脚本中替换：

```bash
export PASSWORD="your_password"
```

## 📊 批量导入示例

### 从团队列表导入

假设有团队成员列表：

```python
#!/usr/bin/env python3
import csv

# 团队成员列表
team_members = [
    {'name': 'Alice', 'email': 'alice@gumtree.com', 'password': 'Pass123!'},
    {'name': 'Bob', 'email': 'bob@gumtree.com', 'password': 'Pass123!'},
    {'name': 'Charlie', 'email': 'charlie@gumtree.com', 'password': 'Pass123!'},
]

# 生成CSV
with open('data/accounts.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['username', 'password', 'user_id', 'account_id', 'team_member', 'notes', 'enabled'])
  
    for member in team_members:
        writer.writerow([
            member['email'],
            member['password'],
            '',  # user_id (将在首次登录后自动获取)
            '',  # account_id
            member['name'],
            f"{member['name']}的测试账号",
            'TRUE'
        ])

print(f"✅ 成功导入 {len(team_members)} 个账号")
```

## 🧪 测试账号配置

### 当前配置的测试账号

根据您的要求，已预配置以下测试账号：

```csv
username,password,user_id,account_id,team_member,notes,enabled
donny.han@gumtree.com,Gumtree123!,2917707,2928083,Donny Han,主测试账号,TRUE
donnyproa@proton.me,Gumtree123!,,,Donny ProA,第二测试账号,TRUE
```

### 添加更多团队账号

继续添加您团队的其他成员：

```csv
username,password,user_id,account_id,team_member,notes,enabled
donny.han@gumtree.com,Gumtree123!,2917707,2928083,Donny Han,主测试账号,TRUE
donnyproa@proton.me,Gumtree123!,,,Donny ProA,第二测试账号,TRUE
teammate1@gumtree.com,Gumtree123!,,,Teammate 1,成员1测试账号,TRUE
teammate2@gumtree.com,Gumtree123!,,,Teammate 2,成员2测试账号,TRUE
teammate3@gumtree.com,Gumtree123!,,,Teammate 3,成员3测试账号,TRUE
```

## 📋 检查清单

运行脚本前，请确认：

- [ ] `accounts.csv` 文件格式正确
- [ ] 所有必填字段（username、password、enabled）已填写
- [ ] enabled 字段设置为 TRUE 的账号都是需要处理的
- [ ] 密码中没有特殊字符导致CSV解析错误（如逗号）
- [ ] 文件编码为 UTF-8
- [ ] 没有空行或格式错误

### 验证CSV文件

```bash
# 检查CSV格式
cd data
python3 -c "
import csv
with open('accounts.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    accounts = list(reader)
    print(f'✅ 发现 {len(accounts)} 个账号')
    for acc in accounts:
        status = '✅ 启用' if acc['enabled'] == 'TRUE' else '⏸️  禁用'
        print(f'  {status} - {acc[\"team_member\"]} <{acc[\"username\"]}>')
"
```

## 🚀 开始使用

配置好账号后，运行多账号清理脚本：

```bash
cd scripts
bash run_cleanup_multi.sh
```

脚本会自动：

1. 读取所有 `enabled=TRUE` 的账号
2. 显示账号列表供确认
3. 逐个账号执行：登录 → 提取广告 → 删除
4. 生成详细的执行报告

---

**提示**:

- 首次使用建议先用1-2个测试账号验证流程
- 确认无误后再添加全部团队账号
- 定期更新账号信息（如密码变更）
