# 在 gumtree_tech 组织下创建新仓库

## 📋 步骤说明

### 方法1: 通过 GitHub Web 界面创建（推荐）

#### 1. 在 GitHub 上创建新仓库

1. 访问 GitHub: https://github.com/organizations/gumtree_tech/repositories/new
   - 或者：登录 GitHub → 进入 `gumtree_tech` 组织 → 点击 "New repository"

2. 填写仓库信息：
   - **Repository name**: `gumtree-prod-ads-cleanup` (或你想要的名称)
   - **Description**: `Gumtree 广告批量删除 - 多账号自动化工具`
   - **Visibility**: 选择 Private（推荐）或 Public
   - **不要**勾选 "Initialize this repository with a README"（因为已有代码）
   - 点击 "Create repository"

#### 2. 添加新的 remote 并推送代码

在本地项目目录执行：

```bash
cd /Users/donny.han/Documents/Gumtree/gumtree-prod-ads-cleanup

# 添加新的 remote（命名为 gumtree-tech）
git remote add gumtree-tech https://github.com/gumtree_tech/gumtree-prod-ads-cleanup.git

# 或者如果你想替换现有的 origin
# git remote set-url origin https://github.com/gumtree_tech/gumtree-prod-ads-cleanup.git

# 提交当前的更改（如果有未提交的更改）
git add .
git commit -m "Update accounts and configurations"

# 推送到新仓库
git push gumtree-tech main

# 或者如果替换了 origin
# git push -u origin main
```

### 方法2: 使用 GitHub CLI（如果已安装）

```bash
# 安装 GitHub CLI（如果未安装）
# brew install gh

# 登录 GitHub
gh auth login

# 在 gumtree_tech 组织下创建仓库
gh repo create gumtree_tech/gumtree-prod-ads-cleanup \
  --private \
  --description "Gumtree 广告批量删除 - 多账号自动化工具" \
  --source=. \
  --remote=gumtree-tech \
  --push
```

### 方法3: 保持两个 remote（同时推送到两个仓库）

如果你想同时保留个人仓库和组织仓库：

```bash
# 添加组织仓库作为新的 remote
git remote add gumtree-tech https://github.com/gumtree_tech/gumtree-prod-ads-cleanup.git

# 查看所有 remote
git remote -v

# 推送到两个仓库
git push origin main          # 推送到个人仓库
git push gumtree-tech main    # 推送到组织仓库

# 或者创建一个脚本同时推送
echo '#!/bin/bash
git push origin main
git push gumtree-tech main' > scripts/push-all.sh
chmod +x scripts/push-all.sh
```

## 🔐 权限要求

确保你有 `gumtree_tech` 组织的权限：
- 需要是组织的成员
- 需要有创建仓库的权限

如果没有权限，请联系组织管理员添加你。

## 📝 后续操作

### 设置默认 remote

如果你想将组织仓库设为默认：

```bash
# 查看当前 remote
git remote -v

# 删除旧的 origin（可选）
git remote remove origin

# 将组织仓库设为 origin
git remote add origin https://github.com/gumtree_tech/gumtree-prod-ads-cleanup.git

# 或者重命名
git remote rename gumtree-tech origin
```

### 保护敏感文件

在推送前，确保敏感文件已添加到 `.gitignore`：

```bash
# 检查 .gitignore
cat .gitignore

# 如果 accounts.csv 包含敏感信息，确保已忽略
echo "data/accounts.csv" >> .gitignore

# 如果已提交，需要从历史中移除（谨慎操作）
# git rm --cached data/accounts.csv
# git commit -m "Remove sensitive accounts file from git"
```

## ✅ 验证

推送后，访问仓库确认：
- https://github.com/gumtree_tech/gumtree-prod-ads-cleanup

检查：
- ✅ 所有文件都已推送
- ✅ README 显示正确
- ✅ 分支和提交历史完整

## 🆘 常见问题

### Q: 提示权限不足？
A: 确认你是 `gumtree_tech` 组织的成员，且有创建仓库的权限。

### Q: 想保留个人仓库？
A: 使用方法3，同时保留两个 remote。

### Q: 如何更新两个仓库？
A: 使用 `git push --all` 或分别推送：
```bash
git push origin main
git push gumtree-tech main
```

---

**提示**: 如果遇到问题，可以查看 Git 文档或联系组织管理员。

