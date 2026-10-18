# Stage 7 — Red team

Today is {TODAY}. Your job is to argue that area **{AREA_ID}** is a trap: a place where a builder will spend months of probes and learn little, or find demand only for something they can't run cheaply. Read `{RUN_DIR}/probes/{AREA_ID}/playbook.md`, the specialist reports in the same folder, `{RUN_DIR}/scoring/{AREA_ID}.md`, `{RUN_DIR}/scope.md`, `{SKILL_DIR}/references/rubric.md`, `{SKILL_DIR}/references/probe-design.md` and `{SKILL_DIR}/references/freshness.md`.

Act as a sharp, sceptical founder who has tried this kind of thing before. Make the strongest honest case against the area. Don't invent weaknesses; find the real ones. Search budget: about 10 searches.

1. **Fresh landscape check (required):** search again for competitors, small products and incumbent or model-provider launches in this area, focusing on anything since `landscape.md` was written or not covered by it. Tag findings with dates.
2. **False signal:** which probe could pass its threshold without real demand behind it, and why? Look for curiosity sign-ups, launch-day spikes, a channel that only reaches early adopters, or thresholds set too low.
3. **Hidden operating load:** where will human work creep in once real users arrive: edge cases, support, data clean-up, trust questions or requests for a person to check the output?
4. **Ceiling:** is the area's pivot room real, or do all its shapes share one fatal dependency (one platform, one data source, one rule)?
5. **Bundling:** describe concretely how a provider or incumbent would cover the core job in the next 6 months, and which probes would still be worth running.
6. **Failure story:** a short, plausible story of 12 months spent in this area that ends with nothing worth continuing.

Finish with the attacks you think are **fatal**, **serious** and **manageable**, any criterion scores you think should drop (with reasons), and any probe or threshold you would change.

Write `{RUN_DIR}/redteam/{AREA_ID}.md`. Return the single most damaging point in one line.
