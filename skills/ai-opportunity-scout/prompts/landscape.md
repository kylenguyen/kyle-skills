# Stage 1 — Landscape snapshot

Today is {TODAY}. You are building the current-state baseline for an AI business-opportunity search in this scope:

{SCOPE_SUMMARY}

Read `{SKILL_DIR}/references/freshness.md` first. Your training data is out of date for everything in this task. Look things up instead of recalling them. Later agents will rely on this file instead of their own memory, so an error here spreads through the whole run.

Research and write `{RUN_DIR}/landscape.md` with these sections. Tag every claim `[F: source, date]`, or `[M]` if it is stable background:

1. **Frontier and open-weight models now:** current leading models from the major providers. For each: what they now do reliably (reasoning, coding, long context, vision, voice, agents and computer use), notable limitations, and release dates.
2. **Inference pricing:** current API prices per million input/output tokens for the main tiers (frontier, mid, small/cheap), plus batch and caching discounts. Use the providers' own pricing pages.
3. **Capability thresholds crossed recently (last 12–18 months):** what became practical that wasn't before, with evidence from production use rather than demos where possible.
4. **Model provider product moves:** first-party apps, agents, enterprise features and integrations from the major providers that could absorb startup ideas in this scope.
5. **Incumbents in the scope:** the main software platforms and service providers in the domain, and the AI features they have shipped or announced (with dates).
6. **AI startups already in the scope:** names, what they do, funding and stage, launch date, and notable shutdowns or pivots.
7. **Regulation:** AI-specific and sector rules affecting the scope in the target region, including recent and upcoming changes.
8. **Search status and gaps:** whether search worked, and which sections are thin.

Aim for breadth with dates rather than depth. Around 1,500–2,500 words is enough. Return a 5-line summary of the most decision-relevant findings.
