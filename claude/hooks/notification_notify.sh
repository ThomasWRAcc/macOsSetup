#!/bin/bash
HOOK_DIR="$(cd "$(dirname "$0")" && pwd -P)"
source "$HOOK_DIR/parse_hook.sh"

SUBTITLE="$PROJECT"
[ -n "$BRANCH" ] && SUBTITLE="$PROJECT  ·  $BRANCH"

case "$NTYPE" in
  permission_prompt) TITLE="🔐 Permission Needed — $PROJECT" ;;
  idle_prompt)       TITLE="💤 Claude is Waiting — $PROJECT" ;;
  *)                 TITLE="⚠️ Claude Needs You — $PROJECT" ;;
esac

afplay /System/Library/Sounds/Ping.aiff &
osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" subtitle \"$SUBTITLE  ·  $SESSION\""
