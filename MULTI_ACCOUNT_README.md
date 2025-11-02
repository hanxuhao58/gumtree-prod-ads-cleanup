# 多账号批量删除 - 使用指南

## 🎯 功能说明

本项目已升级为**多账号批量处理版本**，可以一次性处理您团队内所有成员的测试账号。

### 工作流程

```
读取accounts.csv → 循环每个账号 → 登录 → 提取广告ID → 批量删除 → 统计报告
```

## 📁 文件结构

### 新增文件

```
jmeter-ad-cleanup/
├── config/
│   └── accounts.csv              # ⭐ 账号列表（支持多账号）
├── testcases/
│   ├── ad_cleanup_integrated.jmx      # 单账号版本
│   └── ad_cleanup_multi_accounts.jmx  # ⭐ 多账号版本
├── scripts/
│   ├── run_cleanup.sh                 # 单账号运行脚本
│   └── run_cleanup_multi.sh           # ⭐ 多账号运行脚本
├── ACCOUNTS_GUIDE.md                  # ⭐ 账号管理详细指南
└── MULTI_ACCOUNT_README.md            # ⭐ 本文档
```

## 🚀 快速开始

### 1. 配置账号列表

编辑 `data/accounts.csv`：

```csv
username,password,user_id,account_id,team_member,notes,enabled
donny.han@gumtree.com,Gumtree123!,2917707,2928083,Donny Han,主测试账号,TRUE
donnyproa@proton.me,Gumtree123!,,,Donny ProA,第二测试账号,TRUE
teammate3@gumtree.com,Gumtree123!,,,Team Member 3,成员3,TRUE
```

**重要字段**:
- `username` - 登录邮箱（必填）
- `password` - 登录密码（必填）
- `enabled` - TRUE=处理，FALSE=跳过（必填）
- 其他字段可选

### 2. 运行多账号清理

```bash
cd scripts
bash run_cleanup_multi.sh
```

脚本会：
1. ✅ 显示所有启用的账号列表
2. ✅ 请求确认（输入 `yes` 继续）
3. ✅ 逐个账号处理（登录→提取→删除）
4. ✅ 生成详细统计报告

### 3. 查看结果

```bash
# 查看日志
cat logs/multi_cleanup_*.log

# 打开HTML报告
open reports/multi_cleanup_*_html/index.html
```

## 📊 示例输出

```
========================================
账号列表
========================================

找到 3 个启用的账号:

👤 Donny Han <donny.han@gumtree.com> - 主测试账号
👤 Donny ProA <donnyproa@proton.me> - 第二测试账号
👤 Team Member 3 <teammate3@gumtree.com> - 成员3

========================================
测试环境
========================================

测试环境: mobile-apps-bff.bixi.gumtree.io
测试计划: 多账号批量清理
处理账号: 3 个

⚠️  ⚠️  即将对 3 个账号执行批量删除！
⚠️  此操作不可撤销！

确认继续执行？(yes/no): yes

========================================
开始执行批量清理
========================================

ℹ️  JMeter 运行中...
ℹ️  日志文件: logs/multi_cleanup_20251102_235959.log

[JMeter输出...]

========================================
执行结果摘要
========================================

📊 处理统计

逐账号结果:

🔄 开始处理账号: Donny Han (donny.han@gumtree.com)
   - 发现活跃广告: 0 个
   - 成功删除: 0 个
✅ 账号 Donny Han (donny.han@gumtree.com) 处理完成

🔄 开始处理账号: Donny ProA (donnyproa@proton.me)
   - 发现活跃广告: 15 个
   - 成功删除: 15 个
✅ 账号 Donny ProA (donnyproa@proton.me) 处理完成

📈 总体统计
  总共发现: 15 个活跃广告
  成功删除: 15 个广告
```

## 🔧 账号管理

### 添加新账号

**方法1: 直接编辑CSV**

```csv
# 在文件末尾添加
new_member@gumtree.com,Password123!,,,New Member,新成员,TRUE
```

**方法2: 使用Excel**

1. 用Excel打开 `config/accounts.csv`
2. 添加新行
3. 保存为CSV格式

**方法3: 使用脚本**

```bash
cd data
echo "new@example.com,Pass123!,,,New User,新账号,TRUE" >> accounts.csv
```

### 禁用/启用账号

修改 `enabled` 字段：
- `TRUE` - 账号会被处理
- `FALSE` - 账号会被跳过

```csv
# 临时禁用某个账号
test@example.com,Pass123!,,,Test User,暂时禁用,FALSE
```

### 查看当前配置

```bash
# 查看所有账号
cat data/accounts.csv

# 只看启用的账号
grep ",TRUE$" data/accounts.csv
```

## 🆚 单账号 vs 多账号

### 单账号版本

**使用场景**: 临时处理单个账号

**运行方式**:
```bash
cd scripts
bash run_cleanup.sh
```

**配置**: 使用 `config/bixi.env.properties` 中的账号

### 多账号版本 ⭐ 推荐

**使用场景**: 批量处理团队所有账号

**运行方式**:
```bash
cd scripts
bash run_cleanup_multi.sh
```

**配置**: 使用 `data/accounts.csv` 账号列表

## 📋 最佳实践

### 1. 定期维护账号列表

```bash
# 每周/每月更新一次账号列表
cd data
vim accounts.csv  # 或使用Excel编辑
```

### 2. 测试新账号

添加新账号后，先单独测试：

```csv
# 先禁用其他账号，只启用新账号
old_account@example.com,Pass123!,,,Old User,旧账号,FALSE
new_account@example.com,Pass123!,,,New User,新账号,TRUE
```

运行测试后，确认无误再启用所有账号。

### 3. 定时清理

可以设置cron定时任务：

```bash
# 每周五晚上8点执行清理
0 20 * * 5 cd /path/to/jmeter-ad-cleanup/scripts && bash run_cleanup_multi.sh <<< "yes"
```

### 4. 备份日志

```bash
# 定期备份重要日志
cp logs/multi_cleanup_*.log ~/backups/
```

## 🔒 安全注意事项

### 1. 保护账号信息

```bash
# 设置文件权限
chmod 600 data/accounts.csv

# 如需保密，可添加到.gitignore
# echo "data/accounts.csv" >> .gitignore
```

### 2. 使用模板文件

```bash
# 创建模板供团队参考
cp data/accounts.csv data/accounts.csv.template

# 清空敏感信息
sed -i '' 's/,[^,]*@[^,]*,/,YOUR_EMAIL,/g' data/accounts.csv.template
sed -i '' 's/,\([^,]*\)!/,YOUR_PASSWORD!/g' data/accounts.csv.template
```

## 📝 常见问题

### Q: 如何只处理部分账号？

A: 将不需要处理的账号的 `enabled` 设置为 `FALSE`

### Q: 账号太多，处理时间很长怎么办？

A: 可以分批处理：
```bash
# 第一批：账号1-10
# 将11-20的enabled设为FALSE，运行脚本

# 第二批：账号11-20  
# 将1-10的enabled设为FALSE，11-20设为TRUE，再次运行
```

### Q: 如何查看某个账号的处理结果？

A: 在日志文件中搜索：
```bash
grep "donny.han@gumtree.com" logs/multi_cleanup_*.log
```

### Q: CSV文件格式错误怎么办？

A: 验证CSV格式：
```bash
cd data
python3 -c "
import csv
with open('accounts.csv', 'r') as f:
    reader = csv.DictReader(f)
    for i, row in enumerate(reader, 1):
        print(f'{i}. {row[\"team_member\"]} - {row[\"username\"]}')
"
```

## 📞 技术支持

### 问题排查

1. **账号登录失败**
   - 检查用户名密码是否正确
   - 确认网络连接正常
   - 查看日志了解详细错误

2. **CSV文件读取失败**
   - 确认文件编码为UTF-8
   - 检查是否有多余的空格或特殊字符
   - 确保没有Windows换行符（\r\n）

3. **部分账号跳过**
   - 确认 `enabled` 字段为 `TRUE`
   - 检查CSV格式是否正确

### 获取帮助

- 查看详细文档: `ACCOUNTS_GUIDE.md`
- 查看日志文件: `logs/multi_cleanup_*.log`
- 查看HTML报告: `reports/multi_cleanup_*_html/index.html`

---

## 🎉 总结

多账号版本让您可以：
- ✅ 一次处理整个团队的测试账号
- ✅ 灵活启用/禁用账号
- ✅ 详细的逐账号统计报告
- ✅ 易于维护的CSV格式

**立即开始使用**:
```bash
cd scripts
bash run_cleanup_multi.sh
```

---

**文档更新**: 2025-11-02  
**版本**: 多账号 v2.0

