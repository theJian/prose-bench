# Improving as-prose

Improve [.agents/skills/as-prose/SKILL.md](.agents/skills/as-prose/SKILL.md)
through small experiments and human review. Use this workflow for skill
iterations; setup and fixture maintenance do not start an experiment.

## Starting point

- **Existing PR:** read its description and human feedback, including inline
  comments and reviews. Continue on that branch to address the feedback. If a
  human has already commented `clean`, follow acceptance below instead.
- **No existing PR:** use the problem described by the human and start a
  `feat/as-prose-<improvement>` branch from `main`.

## Iteration

1. **Understand the problem.** Read the skill, reviewer brief, and
   [accepted learnings](learnings.md). Use the current PR's human feedback or
   the human-described problem as the goal.
2. **Update the skill first.** Keep guidance reusable rather than tailored to
   benchmark examples. Validate metadata, links, and changed scripts; use the
   skill-creator validator when available.
3. **Apply it in place.** Run the updated skill on all four projects in
   `projects/`. Follow its independent reviewer and implementation roles, using
   fresh contexts without coaching expected comments or scores. If results
   reveal a skill weakness, revise the guidance and rerun; apply the final skill
   version across all four projects.
4. **Verify.** Judge the change against the current goal, human feedback, and
   accepted learnings from history. Report evidence and gaps; do not invent
   additional acceptance criteria.
5. **Commit and push.** Use conventional, atomic commits on the chosen branch.
   Commit skill changes and resulting project edits separately in the same PR;
   push as work progresses.
6. **Request human review.** Open a draft PR, or update the existing PR, with the
   problem, skill change, direct `projects/` diffs, checks, limitations, and links
   to relevant feedback. Ask for human feedback and an explicit `clean` comment
   when satisfied. Return the PR URL and wait; report publishing blockers honestly.
7. **Incorporate feedback.** Before `clean`, revise the skill, rerun it, and
   update the same PR. After `clean`, update skills and append learnings directly
   on `main` as described below. Start new experiments from the updated `main`.

## Acceptance and learning

- A human's explicit `clean` comment accepts the reviewed revision and authorizes
  the agent to update skills and append to root `learnings.md` directly on `main`.
  Bot comments, approvals, and agent scores do not substitute for it.
- Append lessons from accepted human feedback to
  [learnings.md](learnings.md), with evidence and a concrete regression check.
  This is the iteration agent's tracking record, outside the skill package.
  Keep unaccepted feedback in its PR.
- **Learnings are append-only meeting notes.** Never edit, delete, reorder, or
  rewrite existing entries. Append dated corrections or superseding decisions
  that reference the earlier note; preserve the full history.
- After `clean`, carry forward the accepted skill changes and incorporate the
  accepted feedback on `main`. Validate, commit atomically, and push. This
  follow-up may change only `.agents/skills/as-prose/` and root `learnings.md`;
  do not carry over benchmark edits. Keep changes tied to the accepted feedback.
- **Never merge the PR.** After `clean`, leave the original PR and branch
  untouched: no further commits, edits, comments, closing, or merging. Keep
  acceptance links and follow-up details in `learnings.md` instead.

## Constraints

- Project diffs must come directly from the skill workflow; do not hand-polish
  results outside it or mix in unrelated cleanup and bug fixes.
- Preserve unrelated work and keep `SOURCES.json`, `NOTICE`, and `LICENSE` intact.
- Do not weaken checks to hide failures, force-push, or merge the PR.
- Keep build artifacts and test data in disposable locations. Compare behavior
  with the branch's starting point and report failed or skipped checks.

## Project checks

- **TCP socket:** compile all classes; check echo and client exit. If port 5000
  is occupied, substitute a free port in a disposable copy and report it;
  leave tracked ports unchanged.
- **Password generator:** check character sets, length range, and no-options
  behavior; exercise Tkinter when available and distinguish GUI from core checks.
- **Make text uppercase:** check JavaScript syntax, served HTML/assets, and
  uppercase conversion. Use a browser when available; report HTTP-only or
  handler-only checks.
- **Huffman compressor:** compile C++ and verify a complete codebook generation,
  encoding, and decoding round trip with supported input.
