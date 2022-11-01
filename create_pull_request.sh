#!/bin/sh

# github cli
# jq
# に依存しています

# ブランチ名が xxxxx/111 の形式であること
# 数字部分が存在するissueの番号と対応していること
# を期待しています

# プルリクエスト作成時に差分が無いと失敗します

# 以下の3つの配列は同index間で対応関係にあります
# 向き先ブランチに対してラベルとprefixを定義しています
branches=(production master)
labels=(production staging)
prefixes=(PRD STG)

branch_name=$(git branch --contains | cut -d " " -f 2)
issue_number=$(echo $branch_name | cut -d "/" -f 2)
# issueのタイトルをプルリクエストのタイトルに使用します
title=$(gh issue view ${issue_number} --json title | jq -r ".title")

while true; do
  echo "${branch_name}からproduction, masterにプルリクエストを作成します\n"

  #  echo "プルリクエストのタイトルを入力してください(prefixは自動的に付与されます)"
  #  read title
  echo "ブランチ: ${branch_name}"
  echo "タイトル: ${title}"

  read -p "↑の内容でいいですか？ (y/n)?" choice
  case "$choice" in
  y | Y) break ;;
  n | N)
    echo "終了します\n"
    exit 1
    ;;
  *)
    echo "入力し直してください"
    continue
    ;;
  esac
done

i=0
for base_branch in "${branches[@]}"; do
  label=${labels[@]:${i}:1}
  prefix=${prefixes[@]:${i}:1}

  gh pr create --base ${base_branch} \
  --head $branch_name --label ${label} --title "[${prefix}] ${title}" --body "close #${issue_number}"
  let i++
done
