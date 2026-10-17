# Candidate idea schema

Every candidate uses this JSON shape, so the main agent can merge, dedupe and pass ideas between stages without rereading prose. Generators write an array of these objects.

```json
{
  "id": "lab-03",
  "lens": "labour",
  "title": "Short name",
  "one_liner": "What it does, for whom, replacing what, in one sentence.",
  "buyer": "Role and organisation type and size that pays",
  "user": "Who uses it day to day, if different from the buyer",
  "job_replaced": {
    "who_does_it_today": "Role, in-house or outsourced",
    "effort": "Hours per week/month or volume, with the basis",
    "cost": "Estimated cost per month or year, with the basis"
  },
  "ai_capability": "The specific current AI capability that makes this work now",
  "why_now": "What changed recently: a capability, a price, a regulation or behaviour",
  "accuracy_bar": "Accuracy the buyer needs, and whether human review is acceptable",
  "current_alternatives": ["How it's done today: tools, services, manual work"],
  "incumbent_threats": ["Providers or platforms that could ship this as a feature"],
  "pricing_hypothesis": "Value-based price anchored on the labour or outcome replaced",
  "evidence": [
    {"claim": "…", "tag": "F|I|A|M", "source": "URL or name", "date": "YYYY-MM-DD"}
  ]
}
```

Rules:
- ID prefixes by lens: `lab-`, `wf-`, `cap-`, `gap-`, `fdr-`, followed by a two-digit number.
- `evidence` needs at least two entries tagged `F` for the job-replaced cost or the AI capability. Generators are not expected to research deeply, but an idea with no sourced anchor at all is usually a hunch.
- Keep each field short. The schema is for comparing ideas, not pitching them.
- On merge, the main agent adds `"merged_from": ["id", …]`.
