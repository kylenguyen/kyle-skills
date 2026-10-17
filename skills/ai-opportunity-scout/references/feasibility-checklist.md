# Execution feasibility checklist (Gate 3)

Each specialist covers its own section completely. If a point can't be answered from available evidence, list it under **Open questions**. Don't guess silently. The synthesiser reads all four sections side by side, so use the headings below exactly. That makes contradictions easy to spot.

Search for every time-sensitive point; `freshness.md` section 2 lists them. Tag evidence as `[F]`, `[I]`, `[A]` or `[M]`.

## A. Business viability
1. **Market size, bottom-up:** the number of reachable buyers × a realistic annual price = the reachable revenue. Show the arithmetic and the source for the buyer count. Don't use top-down "TAM is $X bn".
2. **Pricing model and annual contract value:** the value metric (per task, per outcome, per volume, or per seat only if justified). Anchor on the cost replaced, and compare with the current prices of alternatives.
3. **Customer acquisition and payback:** acquisition cost assumptions by channel, sales cycle, payback period in months, and expected churn drivers.
4. **Revenue path:** customers needed and a realistic timeline to SGD 1M annual recurring revenue, or another milestone if that one doesn't fit.
5. **Competitor map:** direct AI competitors (with funding and launch date), incumbents, services firms and DIY options. State where this idea is positioned and why a buyer would switch.
6. **Gross margin after inference:** tokens or calls per task × current price per million tokens (sourced) × tasks per customer per month, plus hosting and human review cost. Compare with the price.

## B. Technical feasibility
1. **Reference architecture:** components, model choice (current models, from `landscape.md` or a search), retrieval or tools, and how much is agentic versus single-call.
2. **Data:** what data is needed, how to get it (cold start), who owns it, and whether it's legally usable.
3. **Accuracy:** the target accuracy for the buyer compared with what is plausible today, with evidence. State the evaluation method and how ground truth would be built.
4. **Integration points:** the systems it must read from or write to, whether their APIs are available and open enough, their rate limits, and whether the incumbent can restrict access.
5. **MVP build effort:** person-weeks by component and the skills required.
6. **Hardest technical risk:** the single thing most likely to make it fail, and the cheapest way to test it.
7. **Smoke test (if enabled):** setup, results and limitations. See `prompts/feas-technical.md`.

## C. Operational feasibility
1. **Human review:** where people must review AI output, who those people are (customer or vendor), and the time per task.
2. **Customer onboarding:** effort per customer, and whether it is really software or software plus services. Services-heavy onboarding changes margin and scalability.
3. **Support load:** expected ticket types and volume, and whether domain experts must handle support.
4. **Team:** founding team composition, key hires, and the hardest role to fill.
5. **Dependencies:** model providers, platforms, data vendors and partners. Note the concentration risk and the switching cost for each.
6. **Scaling:** what breaks first at 10× customers (people, inference cost, data, integrations), and how it would be fixed.

## D. Go-to-market and risk
1. **Ideal customer profile and first 10 customers:** the segment, firmographics and trigger events. Describe where the first 10 would come from by segment and channel, not by naming individuals.
2. **Channel:** direct, partners, integration marketplaces, communities or content. Note the cost and the evidence the channel works for similar products.
3. **Buyer and user:** who signs, who uses, who blocks, and the sales cycle length.
4. **Procurement hurdles:** security reviews, required certifications (e.g. SOC 2, ISO 27001), data residency, and AI-specific policy reviews.
5. **Liability:** who is accountable when the AI is wrong, the contract and insurance implications, and the human sign-off design.
6. **Regulation and compliance:** data protection (PDPA, GDPR or local equivalents), sector rules, AI-specific regulation in target markets, and model provider usage policies.

## Specialist output format

Each specialist file has these parts:
1. A header: idea ID, specialist, date, and search status (`ok`, `partial` or `unavailable`).
2. The section's numbered points, with tagged evidence.
3. **Score:** 1–5 for this dimension's feasibility (higher means more feasible), with a two-line justification.
4. **Top 3 risks:** each with likelihood (L/M/H), impact (L/M/H) and mitigation.
5. **Execution knockouts found:** any from the rubric, or "None".
6. **Key numbers:** a short list of the figures other specialists may depend on, e.g. onboarding weeks, price, tokens per task, team size. The synthesiser compares these across specialists.
7. **Open questions.**
