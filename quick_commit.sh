#!/bin/bash

# 进入本地仓库目录
cd /Users/hu/胡强/GitHub/notes

# 检查是否存在未提交的修改
if [ -n "$(git status --porcelain)" ]; then
  # 存在未提交的修改
  # 添加所有修改
  git add .

  # 提交修改
  git commit -m "Quick commit - $(date '+%Y-%m-%d %H:%M:%S')"

  # 推送到远程仓库
  git push origin master # 或者使用你当前分支的名称
else
  echo "没有未提交的修改."
fi
