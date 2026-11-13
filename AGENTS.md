# Improving as-prose

Improve [.agents/skills/as-prose/SKILL.md](.agents/skills/as-prose/SKILL.md)
through the same loop as manual skill optimization: one persistent editor,
fresh test sessions, and human feedback. Setup and maintenance do not start an
optimization experiment.

## Sessions and inputs

- **Editor:** keep this session alive across trials and PR feedback. Retain the
  current goal, human feedback, [accepted learnings](learnings.md), and skill
  edits. Assess returned test output and generated diffs against those inputs;
  do not independently explore benchmark implementations or internal reviews.
- **Test session:** each invocation of `scripts/test-as-prose` starts a new
  ephemeral `codex exec`, without resuming or forking the editor. It receives a
  fixed neutral task and target paths, never the editor's conversation, goal,
  human feedback, or learning record. Only skill-file edits steer its output.
  Internal reviewer feedback stays inside the test session.

Start from the human feedback on an existing PR and its branch, or from a
human-described problem on a new `feat/as-prose-<improvement>` branch from `main`.
If the PR already has a human `clean` comment, go directly to acceptance.

## Editor loop

1. **Update the skill.** Address the current goal and feedback with reusable
   guidance. Consult accepted learning history and validate the skill package.
2. **Test in a fresh session.** Call `./scripts/test-as-prose`, or pass specific
   paths under `projects/` for a focused trial. The helper applies the current
   skill in place and returns its result, changed paths, and a `changes_patch`
   artifact. Raw session logs stay separate.
3. **Evaluate and repeat.** Read the returned result and diff. Decide whether the
   current issue is resolved using the goal, human feedback, and accepted
   learnings; report evidence and gaps. A successful command only means the run
   completed. If the issue persists, edit the skill and call the helper again.
   Never hand-edit project output or coach the next test with extra instructions.
   Report operational blockers instead of inventing a pass.
4. **Publish when satisfied.** Test the final skill on all four projects with
   `./scripts/test-as-prose`. Commit skill changes and generated project edits
   separately with conventional, atomic commits; push as work progresses. Open
   or update a **draft PR** containing the goal, direct `projects/` diffs,
   validation evidence, limitations, and feedback links.
5. **Wait for human feedback.** Return the PR URL and await its human comments.
   Feed new feedback into this same editor session and repeat from step 1 on the
   same branch. Do not start a new editor session or discard the current goal.
   A human `clean` ends this loop.

## Acceptance and learning

- Only a human's explicit `clean` accepts the reviewed revision. Bot comments,
  approval states, and agent scores are not substitutes.
- After `clean`, carry forward only skill changes and accepted feedback directly
  on `main`. Append dated lessons, evidence links, and regression checks to root
  `learnings.md`. Never edit, delete, reorder, or rewrite existing notes; append
  corrections or superseding decisions with references to the earlier notes.
- Validate, commit atomically, and push. This follow-up may change only
  `.agents/skills/as-prose/` and root `learnings.md`; never carry over benchmark
  edits. Keep changes tied to accepted feedback.
- **Never merge the PR.** After `clean`, leave the original PR and branch
  untouched: no commits, edits, comments, closing, or merging. Record follow-up
  details in `learnings.md`. New experiments start from the updated `main`.

## Test helper

```sh
./scripts/test-as-prose
./scripts/test-as-prose projects/password-generator
```

The command returns JSON with `output`, `changes_patch`, changed paths, and
execution status. The patch shows this trial's changes; it does not reset prior
output. Results and raw logs are stored in a unique temporary directory.
The editor decides local pass/revise; only human `clean` decides acceptance.
The helper requires an installed, authenticated Codex CLI and uses its configured
model with a workspace-write sandbox. Out-of-scope edits fail the run and are
reported without automatically discarding changes.

Project verification is defined in [runner-checks.md](runner-checks.md).
Preserve unrelated work and keep `SOURCES.json`, `NOTICE`, and `LICENSE` intact.
Do not weaken checks, force-push, or fix unrelated benchmark bugs.
