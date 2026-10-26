# Never compress

These keep their meaning and full wording. You may remove filler around them, but not shorten them in a way that changes what they say. This is the caveman skill's "auto-clarity" rule applied to docs: a misread here costs more than the words saved.

1. Safety and security warnings, data handling rules and policy text.
2. Confirmation steps before destructive or irreversible actions: delete, force push, drop, overwrite, publish, send.
3. Ordered procedures. Keep every step and its order; do not merge steps if that hides the order.
4. Conditions and exceptions: "unless", "only if", "except when", "never … without".
5. The strength of a rule. Do not turn "must" into "should" or "never" into "avoid", or the reverse.
6. Exact strings: code blocks, inline code, commands, flags, paths, URLs, `{PLACEHOLDERS}`, environment variable names, error messages, numbers with units, thresholds, limits and versions.
7. Trigger text: every phrase in a SKILL.md `description`, `.claude/agents` and `.claude/commands` descriptions, and tool or API descriptions an agent reads. You may tighten the words that connect the phrases.
8. Identifiers other text points to: headings and anchors linked from elsewhere, stage, step and criterion numbers, and defined terms.
9. Legal text, licence headers and attribution.
10. Text that tests or tools match: strings found by `grep -rnF` in tests, snapshots or alert config, and tool directives in comments.

If you are unsure whether something falls in this list, keep it and record it in the notes as a judgement call.
