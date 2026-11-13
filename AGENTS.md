# Improving as-prose

Improve [.agents/skills/as-prose/SKILL.md](.agents/skills/as-prose/SKILL.md)
through small experiments and human review. Use this workflow for skill
iterations; setup and fixture maintenance do not start an experiment.

## Context boundaries

- **Skill editor:** use only the current goal, human feedback, accepted learning
  history, and skill files. Do not inspect project implementations, generated
  source diffs, or internal reviewer feedback and scores. Use file lists and
  runner status for commits and PR bookkeeping.
- **Isolated runner:** read the implementations and own the skill's application,
  implementation, review, and verification process. Internal reviewer feedback
  stays here. Return only completion status, changed paths, check pass/fail, and
  operational blockers, without source excerpts or review findings.
- Only skill-file edits may steer the result. Do not give the runner the
  editor's conversation, goal, human feedback, learning record, or desired output.

## Starting point

- **Existing PR:** read its stated goal and human feedback, including inline
  comment text and human reviews, without loading source diffs. Continue on that
  branch to address the feedback. If a human has already commented `clean`,
  follow acceptance below instead.
- **No existing PR:** use the problem described by the human and start a
  `feat/as-prose-<improvement>` branch from `main`.

## Iteration

1. **Understand the problem.** Read the skill and
   [accepted learnings](learnings.md). Use the current PR's human feedback or
   the human-described problem as the goal.
2. **Update the skill first.** Keep guidance reusable rather than tailored to
   benchmark examples. Validate metadata, links, and changed scripts; use the
   skill-creator validator when available.
3. **Run in isolation.** Start a fresh runner with `fork_turns: "none"` or an
   equivalent clean context. Use the same neutral request each time: "As the
   isolated runner, apply the repository's as-prose skill to all four projects
   in `projects/`, in place."
   The runner follows [runner-checks.md](runner-checks.md). For another trial,
   edit the skill and start another fresh runner; do not coach the run directly.
4. **Verify the guidance.** Check the skill edit against the current goal, human
   feedback, and accepted learning history. Use the runner's check status for
   readiness; human review judges the generated project output. Do not invent
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
- Project-specific verification belongs to the isolated runner. The skill editor
  does not load `runner-checks.md` or detailed execution and review logs.
