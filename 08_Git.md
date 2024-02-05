### 用户信息

```bash
# 查看git版本
git -v

# 每台设备初次使用时的设定
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com

# 查看设置
git config --list
```

### 仓库基础操作

```bash
# 初始化一个仓库
git init
 
# 克隆一个仓库
git clone <repo directory> [repo name]

# 本地仓库连接到远程仓库
git remote add origin <server>

# 添加到暂存区
git add <filename>
git add *

# 移除暂存区
git rm --cached <filename>

# 提交到存储区
git commit -m <msg>

# 推送到远程仓库
git push origin master

# 拉取
git pull origin master

# 显示工作区和暂存区的状态
git status

# 显示远程仓库地址
git remote -v

# 查看提交历史
git log
git log --oneline

# 恢复删除的文件（仅在工作区删除）
git restore <filename>  # 从存储区恢复到工作区

# 恢复删除的文件（存储区中也删除了）
git reset --hard <hash>  # 修改head头，部分提交历史会丢失
git revert <hash>  # 恢复删除的文件，提交历史不会丢失

# 查看指定文件的修改记录
git blame <file>
```

### 分支操作

* 从master主分支创建分支的时候，会把master上的内容都复制到新分支中，之后在分支上的操作不会互相影响；
* 合并分支时，新分支中删除的文件在master中会被删除，新分支添加的文件在master中会被添加
* 合并冲突

```bash
# 分支控制
# 创建分支
git branch <branchname>

# 查看分支
git branch -v

# 切换分支
git checkout <branchname>
git checkout -b <branchname> # 创建并切换到新分支

# 删除分支
git branch -d <branchname>

# 合并分支
git merge <branchname>  # 把branchname合并到当前分支 

# fetch
git pull = git fetch + git merge
```

### 解决冲突

```bash

```

