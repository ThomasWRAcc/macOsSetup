#!/bin/bash

INPUT=$(cat)

# Parse all available fields from the hook JSON
eval "$(echo "$INPUT" | node -e "
const d = JSON.parse(require('fs').readFileSync(0, 'utf8'));
const cwd = d.cwd || 'unknown';
const session = (d.session_id || 'unknown').slice(0, 8);
const transcript = d.transcript_path || '';
const lastMsg = (d.last_assistant_message || '').slice(0, 120);

// Derive project name from transcript path
let project = require('path').basename(cwd);
if (transcript) {
  const parts = transcript.split('/');
  const projIdx = parts.indexOf('projects');
  if (projIdx >= 0 && projIdx + 1 < parts.length) {
    const encoded = parts[projIdx + 1];
    const segments = encoded.split('-').filter(Boolean);
    project = segments[segments.length - 1] || project;
  }
}

console.log('DIR=' + JSON.stringify(cwd));
console.log('SESSION=' + JSON.stringify(session));
console.log('PROJECT=' + JSON.stringify(project));
console.log('PREVIEW=' + JSON.stringify(lastMsg));
")"

BRANCH=$(git -C "$DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Build subtitle with project and branch context
SUBTITLE="$PROJECT"
[ -n "$BRANCH" ] && SUBTITLE="$PROJECT  ·  $BRANCH"

# Show a preview of what Claude said, or a generic message
BODY="${PREVIEW:-Done}"

afplay /System/Library/Sounds/Funk.aiff &

osascript -e "display notification \"$BODY\" with title \"✅ Claude Finished — $PROJECT\" subtitle \"$SUBTITLE  ·  $SESSION\""
