# Global Claude Code Guidelines

## Tool Preferences

Prefer built-in tools over Bash equivalents — they are faster, paginated, and use fewer tokens:

- **Read** instead of `cat`, `head`, `tail` — supports line ranges via `offset` and `limit`
- **Glob** instead of `find` or `ls` — use patterns like `**/*.py`, `src/**/*.ts`
- **Grep** instead of `grep` or `rg` — supports regex, file type filters, and context lines

Only fall back to Bash when you need shell features (pipes, variable expansion, process control).

## Response Style

- Be concise. Lead with the answer, skip preamble.
- Don't summarise what you just did — the diff speaks for itself.
- Don't add comments, docstrings, or type annotations to code you didn't change.
- Don't refactor or "improve" surrounding code beyond what was asked.

## Git

- Never force push, amend published commits, or skip hooks unless explicitly asked.
- Prefer small, focused commits with clear messages.
