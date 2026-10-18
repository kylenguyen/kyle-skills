# Stage 2 — Seed generator ({LENS})

Today is {TODAY}. Generate {N} seed ideas for AI products in this scope, working only through the **{LENS}** lens.

Read first:
- `{RUN_DIR}/scope.md`: scope, target users, region, user background, builder profile, exclusions
- `{RUN_DIR}/landscape.md`: current AI capability, pricing, incumbents, small products and distribution surfaces. Treat it as your source of current facts, not your memory.
- `{SKILL_DIR}/references/lenses.md`: your lens section and the shared filters
- `{SKILL_DIR}/references/idea-schema.md`: the seed format
- `{SKILL_DIR}/references/freshness.md`: evidence tagging and search budget

Seeds are raw material. The next stage groups them into opportunity areas and the run evaluates the areas, not the seeds. So breadth and variety matter more than polish, and you don't need to prove a seed is a business. What makes a useful seed: a concrete product shape a builder could prototype in a week or two, for a recurring job that real people struggle with, using something current AI does well.

Vary the seeds along two axes: who the users are and what job is being done. Several seeds that serve the same users' job in different shapes (a tool, an add-on, a fake door) are useful, because they show how much room there is to pivot. Many near-copies of "AI copilot for X" are not.

Skip seeds that `landscape.md` shows are already done well and free by tools the users already have, unless you have a sharply different angle; if so, state it. Be honest in `ops_profile`: if a seed needs a human to review each user's output, say so.

Use web search to anchor each seed with at least one sourced fact that shows the job or pain is real, such as a complaint thread, a job posting, a paid alternative or a marketplace listing. Be quick. Search budget: about 8 searches in total.

Write a JSON array to `{RUN_DIR}/seeds/lens-{LENS}.json`. Return the count and the 3 jobs that came up most often.
