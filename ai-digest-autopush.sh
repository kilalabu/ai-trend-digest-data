#!/bin/bash
# ai-digest 自動git pushスクリプト
# fswatch でフォルダを監視し、.mdファイルが追加・変更されたら自動でgit push

REPO="/Users/kuwa/Develop/personal/my-company/data/ai-digest"
LOG="$HOME/Library/Logs/ai-digest-autopush.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

log "監視開始: $REPO"

/opt/homebrew/bin/fswatch -o --event Created --event Updated --include='\.md$' "$REPO" | while read -r event; do
  sleep 2  # 書き込み完了を待つ

  cd "$REPO" || { log "ERROR: ディレクトリに移動できません"; continue; }

  # 変更がなければスキップ
  if git diff --quiet && git diff --cached --quiet && [ -z "$(git status --porcelain)" ]; then
    continue
  fi

  LABEL=$(date '+%Y-%m-%d %H:%M')
  git add .
  git commit -m "auto: $LABEL" >> "$LOG" 2>&1
  git push >> "$LOG" 2>&1

  if [ $? -eq 0 ]; then
    log "push成功: $LABEL"
  else
    log "ERROR: push失敗"
  fi
done
