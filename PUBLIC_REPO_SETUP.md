# 将仓库设为公开并允许团队协作

## 🎯 目标
将个人仓库 `hanxuhao58/gumtree-prod-ads-cleanup` 设为公开，并允许团队成员协作。

## 📋 步骤

### 方法1: 将仓库设为公开 + 添加协作者（推荐）

#### 1. 将仓库设为公开

1. 访问仓库设置页面：
   - https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/settings

2. 滚动到页面底部，找到 "Danger Zone" 部分

3. 点击 "Change visibility" → "Change to public"

4. 确认操作（输入仓库名称确认）

#### 2. 添加团队成员为协作者

**方式A: 逐个添加协作者**

1. 在仓库设置页面：https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/settings/access
2. 点击 "Add people" 或 "Invite a collaborator"
3. 输入团队成员的 GitHub 用户名或邮箱
4. 选择权限级别：
   - **Write** - 可以推送代码（推荐）
   - **Admin** - 完全管理权限
5. 发送邀请

**方式B: 批量添加（使用脚本）**

```bash
# 需要安装 GitHub CLI
# brew install gh

# 登录
gh auth login

# 添加协作者（替换 USERNAME 为实际用户名）
gh api repos/hanxuhao58/gumtree-prod-ads-cleanup/collaborators/USERNAME \
  -X PUT \
  -f permission=write
```

#### 3. 允许任何人提交 Pull Request（默认已开启）

公开仓库默认允许任何人：
- ✅ Fork 仓库
- ✅ 提交 Pull Request
- ✅ 报告 Issues

### 方法2: 转移到组织仓库（更专业）

如果你想将仓库转移到 `gumtree_tech` 组织：

1. 访问仓库设置：https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/settings
2. 滚动到 "Danger Zone"
3. 点击 "Transfer ownership"
4. 输入组织名称：`gumtree_tech`
5. 确认转移

**转移后的好处**：
- ✅ 仓库属于组织，不依赖个人账号
- ✅ 可以设置团队权限
- ✅ 更便于管理

## 🔐 权限说明

### 协作者权限级别

| 权限 | 说明 | 适用场景 |
|------|------|----------|
| **Read** | 只能查看代码 | 只读访问 |
| **Write** | 可以推送代码、创建分支 | 普通开发者（推荐） |
| **Maintain** | 可以管理仓库，但不能删除 | 项目维护者 |
| **Admin** | 完全权限，包括删除仓库 | 项目管理员 |

### 推荐设置

对于团队协作，建议：
- 核心成员：**Write** 或 **Maintain**
- 临时贡献者：通过 **Pull Request** 方式（无需添加为协作者）

## 🚀 快速操作脚本

创建一个脚本批量添加协作者：

```bash
#!/bin/bash
# 批量添加协作者脚本

REPO="hanxuhao58/gumtree-prod-ads-cleanup"
PERMISSION="write"  # 或 "maintain", "admin"

# 团队成员列表（替换为实际用户名）
TEAM_MEMBERS=(
  "username1"
  "username2"
  "username3"
)

for member in "${TEAM_MEMBERS[@]}"; do
  echo "添加协作者: $member"
  gh api repos/$REPO/collaborators/$member \
    -X PUT \
    -f permission=$PERMISSION
done

echo "✅ 完成！"
```

## ⚠️ 安全注意事项

### 1. 保护敏感信息

在设为公开前，确保：

```bash
# 检查 .gitignore 是否包含敏感文件
cat .gitignore

# 如果 accounts.csv 包含敏感信息，确保已忽略
echo "data/accounts.csv" >> .gitignore

# 如果已提交到历史，需要从历史中移除
# git rm --cached data/accounts.csv
# git commit -m "Remove sensitive accounts file"
# git push origin main
```

### 2. 使用 GitHub Secrets（推荐）

对于敏感配置，使用 GitHub Secrets：

1. 仓库设置 → Secrets and variables → Actions
2. 添加敏感信息作为 Secrets
3. 在脚本中使用 `${{ secrets.ACCOUNT_PASSWORD }}`

## 📝 当前仓库信息

- **仓库地址**: https://github.com/hanxuhao58/gumtree-prod-ads-cleanup
- **当前状态**: 需要检查（可能是私有）
- **建议操作**: 
  1. 设为公开
  2. 添加团队成员为协作者（Write 权限）
  3. 或转移到 gumtree_tech 组织

## ✅ 验证设置

设置完成后，验证：

1. **检查仓库可见性**
   - 访问：https://github.com/hanxuhao58/gumtree-prod-ads-cleanup
   - 未登录状态下应该能看到仓库

2. **检查协作者**
   - 访问：https://github.com/hanxuhao58/gumtree-prod-ads-cleanup/settings/access
   - 确认所有团队成员都已添加

3. **测试协作**
   - 让团队成员尝试 clone 和 push
   - 确认权限正常

## 🆘 常见问题

### Q: 如何查看当前仓库是公开还是私有？
A: 访问仓库页面，如果未登录也能看到，就是公开的。

### Q: 公开仓库后，之前的提交历史会暴露吗？
A: 会的，所有提交历史都会公开。如果之前有敏感信息，需要清理历史。

### Q: 可以只让特定的人看到仓库吗？
A: 可以，保持私有，只添加协作者。或者使用 GitHub Teams 功能。

### Q: 转移到组织后，个人仓库会消失吗？
A: 会，仓库会从个人账号转移到组织。所有内容保持不变。

---

**提示**: 如果只是想临时分享，也可以使用 GitHub Gist 或创建临时访问链接。

