# Stage 1 — Landscape snapshot

Today is {TODAY}. You are building the current-state baseline for a search for AI product areas in this scope:

{SCOPE_SUMMARY}

Read `{SKILL_DIR}/references/freshness.md` first. Your training data is out of date for everything in this task, so look things up instead of recalling them. Later agents will rely on this file instead of their own memory, so an error here spreads through the whole run. Search budget: about 35 searches.

Research and write `{RUN_DIR}/landscape.md` with these sections. Tag every claim `[F: source, date]`, or `[M]` if it is stable background:

1. **Frontier and open-weight models now:** current leading models from the major providers. For each: what they now do reliably (reasoning, coding, long context, vision, voice, agents and computer use), notable limitations, and release dates.
2. **Inference pricing:** current API prices per million input and output tokens for the main tiers (frontier, mid, small), plus batch and caching discounts. Use the providers' own pricing pages.
3. **Capability thresholds crossed recently (last 12–18 months):** what became practical that wasn't before, with evidence from real use rather than demos where possible. Include what a single builder can now ship quickly with current agent SDKs, coding tools and hosting.
4. **Model provider product moves:** first-party apps, agents, plugins and integrations from the major providers that could absorb product ideas in this scope.
5. **Incumbents in the scope:** the main software platforms and service providers, and the AI features they have shipped or announced (with dates).
6. **AI startups and small products in the scope:** funded startups (with funding, stage and launch date) and small self-serve AI products or indie tools, with their price points where public. Note shutdowns and pivots, and why they happened where reported, because past failures show where the tarpits are.
7. **Capital flows:** where investors are putting money in and near the scope in the last 6 months: notable rounds, accelerator batch themes, and published requests for startups (check YC's current list at ycombinator.com/rfs and any others relevant to the region). Heavy funding validates a job but crowds the head-on product shapes, so note which shapes are crowded.
8. **Proven models elsewhere:** AI products with sourced traction in another region, segment or adjacent industry that could plausibly be adapted to this scope, and what users pay freelancers or agencies today for jobs in the scope.
9. **Distribution surfaces:** where the scope's users discover and install tools: marketplaces and app stores for the platforms they use, browser extension stores, AI assistant plugin and agent directories, and the main communities. For each, any public size signal, listing rules, review times and rules on self-promotion.
10. **Regulation:** AI-specific and sector rules affecting the scope in the target region, including recent and upcoming changes.
11. **Search status and gaps:** whether search worked, and which sections are thin.

Aim for breadth with dates rather than depth. Around 2,500–3,500 words is enough. Return a 5-line summary of the most decision-relevant findings.
