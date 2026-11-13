# Improving as-prose

Improve [.agents/skills/as-prose/SKILL.md](.agents/skills/as-prose/SKILL.md)
through small experiments and human review. Use this workflow for skill
iterations; setup and fixture maintenance do not start an experiment.

## Iteration

1. **Choose a problem.** Read the skill, reviewer brief, and previous PR feedback,
   including inline comments. Identify a concrete reader problem to improve.
2. **Update the skill first.** Keep guidance reusable rather than tailored to
   benchmark examples. Validate metadata, links, and changed scripts; use the
   skill-creator validator when available.
3. **Apply it in place.** Run the updated skill on all four projects in
   `projects/`. Follow its independent reviewer and implementation roles, using
   fresh contexts without coaching expected comments or scores. If results
   reveal a skill weakness, revise the guidance and rerun; apply the final skill
   version across all four projects.
4. **Verify.** Preserve behavior and public interfaces. For documentation edits,
   check executable syntax or compiled output is unchanged, accounting for
   Python docstrings. Explain and test structural changes separately.
5. **Commit and push.** Use a `feat/as-prose-<improvement>` branch and conventional,
   atomic commits. Commit skill changes and resulting project edits separately
   in the same PR; push as work progresses.
6. **Request human review.** Open a PR with the problem, skill change, direct
   `projects/` diffs, checks, limitations, and links to relevant feedback. Ask
   whether the explanations improve understanding and remain accurate and
   concise. Return the PR URL and wait for human feedback; agent scores are
   diagnostic, not acceptance. Report publishing blockers honestly.
7. **Incorporate feedback.** Revise the skill before rerunning it and update the
   same PR. Start a new branch and PR for the next experiment after it is merged
   or closed.

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
