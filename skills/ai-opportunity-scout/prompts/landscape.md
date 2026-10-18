# Stage 1 — Landscape snapshot

Today is {TODAY}. You are building the current-state baseline for a search for AI product areas in this scope:

{SCOPE_SUMMARY}

Read `{SKILL_DIR}/references/freshness.md` first. Your training data is out of date for everything in this task, so look things up instead of recalling them. Later agents will rely on this file instead of their own memory, so an error here spreads through the whole run. Search budget: about 30 searches.

Research and write `{RUN_DIR}/landscape.md` with these sections. Tag every claim `[F: source, date]`, or `[M]` if it is stable background:

1. **Frontier and open-weight models now:** current leading models from the major providers. For each: what they now do reliably (reasoning, coding, long context, vision, voice, agents and computer use), notable limitations, and release dates.
2. **Inference pricing:** current API prices per million input and output tokens for the main tiers (frontier, mid, small), plus batch and caching discounts. Use the providers' own pricing pages.
3. **Capability thresholds crossed recently (last 12–18 months):** what became practical that wasn't before, with evidence from real use rather than demos where possible. Include what a single builder can now ship quickly with current agent SDKs, coding tools and hosting.
4. **Model provider product moves:** first-party apps, agents, plugins and integrations from the major providers that could absorb product ideas in this scope.
5. **Incumbents in the scope:** the main software platforms and service providers, and the AI features they have shipped or announced (with dates).
6. **AI startups and small products in the scope:** funded startups (with funding, stage and launch date) and small self-serve AI products or indie tools, with their price points where public. Note shutdowns and pivots.
7. **Distribution surfaces:** where the scope's users discover and install tools: marketplaces and app stores for the platforms they use, browser extension stores, AI assistant plugin and agent directories, and the main communities. For each, any public size signal, listing rules, review times and rules on self-promotion.
8. **Regulation:** AI-specific and sector rules affecting the scope in the target region, including recent and upcoming changes.
9. **Search status and gaps:** whether search worked, and which sections are thin.

Aim for breadth with dates rather than depth. Around 2,000–3,000 words is enough. Return a 5-line summary of the most decision-relevant findings.
