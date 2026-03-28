#!/bin/bash

INPUT=$(cat)

# Parse all available fields from the hook JSON
eval "$(echo "$INPUT" | node -e "
const d = JSON.parse(require('fs').readFileSync(0, 'utf8'));
const cwd = d.cwd || 'unknown';
const session = (d.session_id || 'unknown').slice(0, 8);
const message = d.message || 'Needs your attention';
const type = d.notification_type || 'unknown';
const transcript = d.transcript_path || '';

// Derive project name from transcript path: ~/.claude/projects/<encoded-path>/session.jsonl
let project = require('path').basename(cwd);
if (transcript) {
  const parts = transcript.split('/');
  const projIdx = parts.indexOf('projects');
  if (projIdx >= 0 && projIdx + 1 < parts.length) {
    // Decode the directory-encoded project path (e.g. '-Users-thomas-dev-repos-foo')
    const encoded = parts[projIdx + 1];
    const segments = encoded.split('-').filter(Boolean);
    project = segments[segments.length - 1] || project;
  }
}

// Escape for shell
const esc = s => s.replace(/'/g, \"'\\\\''\");
console.log('DIR=' + JSON.stringify(cwd));
console.log('SESSION=' + JSON.stringify(session));
console.log('MESSAGE=' + JSON.stringify(message));
console.log('NTYPE=' + JSON.stringify(type));
console.log('PROJECT=' + JSON.stringify(project));
")"

BRANCH=$(git -C "$DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Build subtitle with project and branch context
SUBTITLE="$PROJECT"
[ -n "$BRANCH" ] && SUBTITLE="$PROJECT  ·  $BRANCH"

# Choose title based on notification type
case "$NTYPE" in
  permission_prompt) TITLE="🔐 Permission Needed — $PROJECT" ;;
  idle_prompt)       TITLE="💤 Claude is Waiting — $PROJECT" ;;
  *)                 TITLE="⚠️ Claude Needs You — $PROJECT" ;;
esac

afplay /System/Library/Sounds/Ping.aiff &

osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" subtitle \"$SUBTITLE  ·  $SESSION\""
