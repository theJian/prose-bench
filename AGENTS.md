# Improving as-prose

This repository improves the reusable `as-prose` skill through small experiments
and human review. The canonical skill is
[.agents/skills/as-prose/SKILL.md](.agents/skills/as-prose/SKILL.md).
Its reviewer brief and agent metadata belong to the same package.

Use the iteration below when asked to improve or evaluate the skill. Repository
setup and fixture maintenance do not automatically start an experiment.

## Inputs and outputs

- `projects/` contains the four benchmark projects. Run the updated skill on
  these files **in place**. Their changes in the PR must be the direct result of
  applying `as-prose`, so a human can review the ordinary source diff.
- Do not put generated project copies in `results/` or another output directory.
  The original comment-free inputs remain available in Git history at baseline
  commit `f3c328a`; use that history for comparisons when needed. Do not reset
  project files or remove existing prose automatically between iterations.
- `SOURCES.json`, `NOTICE`, and `LICENSE` preserve upstream provenance and rights.
  Keep them intact. Read `README.md` for project prerequisites and run commands.

## Iterate

1. **Choose an improvement.** Read the current skill, reviewer brief, relevant
   implementation, and available human feedback from earlier PRs, including
   inline comments and reviews. State the concrete reader problem and the
   improvement you expect. Use feedback links and examples as evidence; do not
   assume feedback exists or invent a desired score.

2. **Update the skill first.** Make a focused, reusable change in
   `.agents/skills/as-prose/`. Keep benchmark-specific knowledge out of the skill.
   Avoid adding a new universal rule for every example. Check frontmatter,
   relative links, metadata, and any changed scripts; run the skill-creator
   validator when available. Revise until the proposed guidance is coherent and
   ready to test.

3. **Run the updated skill on all four projects in place.** Apply this
   repository's updated skill directly to the source files under `projects/`.
   Follow its independent reviewer and implementation roles. Use fresh agent
   contexts for application and review when available, supplying the actual
   task, updated skill, target paths, and scope constraints. Do not coach the outcome or supply
   expected comments. Do not hand-polish outputs outside the skill's workflow
   to hide a weakness in its guidance. If a result exposes a weakness, revise the
   skill and rerun it on the affected projects in place, then run the final
   skill version across all four projects before opening the PR.

4. **Verify the results.** Preserve executable behavior and public interfaces.
   Prefer comment and docstring changes so the review measures explanations.
   Verify executable syntax or compiled output is unchanged for documentation
   edits, accounting for Python docstrings. Explain and validate any naming or
   structural changes separately. Do not fix pre-existing fixture bugs as part
   of an explanation experiment, weaken checks, or rewrite provenance to make
   a result pass. Run the relevant project checks below. Record actual outcomes
   and limitations; automated review scores do not establish human acceptance.

5. **Commit and push atomically.** Use a conventional feature branch such as
   `feat/as-prose-<improvement>` and conventional commit messages. Keep skill
   changes and the resulting in-place `projects/` edits in separate, focused
   commits in the same PR. Keep the project edits as the direct output of the
   skill run, without mixing in unrelated cleanup. Commit each coherent,
   validated change and push the branch as work progresses. Preserve unrelated
   work; do not force-push or merge the PR.

6. **Open a PR for human review.** Include the reader problem, skill change,
   source diffs for all four projects, validation evidence, and remaining
   limitations. The PR's `projects/` diff is the review artifact; do not replace
   it with copied files, a report, or screenshots. Link earlier feedback that
   motivated the change. Explicitly ask a human to review whether the guidance
   and resulting explanations improve
   understanding, especially responsibilities, data flow, API contracts, and
   economy of prose. Request a named reviewer when one is designated. Return the
   PR URL and wait for human feedback before starting another improvement cycle.
   If publishing is unavailable, leave the commits ready and report the concrete
   blocker rather than claiming that a PR exists.

7. **Use human feedback for the next iteration.** Read all new review feedback,
   connect each material point to the skill guidance and generated examples,
   and revise the general guidance before regenerating results. Update the same
   PR while addressing its review; after it is merged or closed, start a new
   branch and PR for the next experiment. Human review is the acceptance step.

## Project checks

- **TCP socket:** compile all three Java classes; verify an echo and client exit.
  If port 5000 is occupied, test on an unused port in a disposable copy and
  report the substitution. Keep tracked source ports unchanged.
- **Password generator:** check the selected character sets, requested length
  range, and no-options outcome. Exercise the Tkinter UI when a display is
  available; distinguish core checks from GUI checks.
- **Make text uppercase:** check JavaScript syntax, served HTML/assets, and the
  input-to-uppercase interaction. Use browser interaction when available and
  report when only HTTP or handler checks were possible.
- **Huffman compressor:** compile the C++ codebook generator, then run both
  Python programs through a complete encode/decode round trip using a controlled
  input supported by the existing implementation.

Put build artifacts and temporary test data in disposable locations when
practical; skill-generated source edits stay in `projects/`. Compare executable
behavior against the branch's starting point and report skipped checks or
existing failures without changing the benchmark to conceal them.
