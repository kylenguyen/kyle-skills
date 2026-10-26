# Rules: cut, keep, rewrite

Read before Stage 3. Text in `never-compress.md` overrides everything here.

## Order of work

Do two passes per file: cut first, then tighten what is left. Cutting first stops you polishing sentences that should not exist.

## Know the reader

| Reader | Files | What they need |
|---|---|---|
| An agent executing | `agent` and `schema` categories | Every instruction that changes what it does, plus a one-sentence reason per rule so it can handle cases the rule does not cover. Nothing else. |
| A person skimming | `doc`, `template`, comments | What it is, what to do, in the order they do it. Detail only where they would get stuck. |

## Cut

| Cut | Example | Note |
|---|---|---|
| History and change trails | "Previously we used X; in v2 we switched to Y." | Keep the current state ("Uses Y.") unless the old way still matters to the reader, such as a migration step. |
| Meta-text | "This section describes…", "As mentioned above", "Note that", "It is important to note that" | State the thing itself. |
| Restatement | A rule given twice in one file; a summary repeating the section above it | Keep the clearest copy, in the place the reader looks first. |
| Motivation essays | Paragraphs on why the approach was chosen | Keep one sentence when it guides edge cases; move nothing to new files. |
| Filler | just, really, basically, actually, simply, very, quite, "in order to" (to), "a number of" (several), "at this point in time" (now) | |
| Hedging | "you may want to consider", "it might be a good idea to" | State the instruction. If it is optional and unimportant, delete it. |
| Pleasantries and cheerleading | "Feel free to", "Happy coding!", "Be thorough and careful" | Generic exhortations do not change what an agent does. |
| Stale references | Mentions of files, flags, tools or steps that no longer exist | Check with `ls` or `grep` before cutting; live references stay. |
| Extra examples | Three examples showing the same point | Keep the one that best shows the edge; keep two only if they show different edges. |
| Comments that restate code | `# loop over the items and check each one` | Keep comments that say why, warn, or state an invariant. |

Do not delete TODO or FIXME comments or commented-out code: they are decisions for the owner. List stale ones in the notes.

## Keep

- Every instruction that changes what the reader does: steps, conditions, defaults, thresholds, prohibitions, inputs, outputs and paths.
- The one-sentence reason behind a rule.
- Examples that settle an ambiguity.
- Definitions of terms used later.
- Everything in `never-compress.md`.

## Rewrite

1. Lead with the action: "Run X", not "You will need to run X".
2. Active voice, present tense.
3. One term per concept. Do not alternate "run directory" and "output folder".
4. Short words: use (utilise), help (facilitate), start (commence), so (consequently), about (approximately, but never round a number).
5. Tables for inputs, options and comparisons; numbered steps for ordered procedures; bullets for unordered sets.
6. Split sentences over about 25 words that carry more than one instruction.
7. Keep the repo's spelling and style conventions (check AGENTS.md, CLAUDE.md or the existing text). Do not switch British and American spelling.
8. Keep the file's existing structure unless it clearly hurts the reader. Large restructures make the diff hard to review.
9. Bold at most the one word per section that must not be missed.

## Styles

| Style | Applies to | Rules |
|---|---|---|
| `plain` (default) | All files | Full sentences, articles kept, everything above. |
| `terse` (on request: "terse", "caveman", "compress hard") | `agent` category only; other files stay `plain` | Also drop articles and filler, fragments allowed, `X -> Y` for causality, common abbreviations (config, repo, dir, env, auth, DB), one word when one is enough. Items in `never-compress.md` stay full sentences. |

## Examples

Agent instruction with a history trail:

> Before: In earlier versions of this skill we used to ask the user for the depth up front, but this turned out to be annoying, so now we default to `quick`. You should probably still mention to the user that they can change it if they want to.
>
> After: Default depth: `quick`. Tell the user they can change it.

README with meta-text and hedging:

> Before: This section explains how you can go about installing the tool. It's generally a good idea to make sure that you have Node 20 or later installed before you begin.
>
> After: Requires Node 20 or later.

Keep the reason, cut the story:

> Before: Always run the verify commands yourself rather than trusting what the sub-agent reports, because sub-agents frequently claim success even when tests are failing, which has caused a lot of problems for us in the past and led to broken builds on several occasions.
>
> After: Run the verify commands yourself rather than trusting the sub-agent's report, because sub-agents often claim success when tests fail.

Code comment that restates the code:

> Before: `# This function basically just loops over all of the items and checks whether each one of them is valid or not`
>
> After: delete it if the function name says the same; otherwise `# Return the invalid items.`

`terse` style, agent file:

> Before: If the user has not provided a scope, you should use the current working directory as the scope.
>
> After: No scope given -> use current dir.
