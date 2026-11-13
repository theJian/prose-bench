# Accepted human feedback

Repository tracking record for the iteration agent's decisions about skill
updates. This file is not part of the `as-prose` skill.

Add a lesson only after a human explicitly comments `clean` on the relevant PR.
That comment authorizes the agent to update this record and the skill directly
on `main`, then commit and push, without changing the original PR or branch.
Capture what the accepted feedback demonstrates; do not invent lessons from
agent scores or treat every example as a universal rule.

For each accepted change, record:

- PR URL, accepted revision SHA, and links to the human feedback and `clean` comment.
- The reader problem and the reusable guidance that resolved it.
- A concrete before/after example or source location, with its relevant context.
- A regression check describing the observable result future runs must preserve.

The iteration agent reads these lessons before changing the skill and checks
their regression criteria before requesting review. Skill application and
independent review receive the updated skill and fresh task briefs, not this
tracking record.

## Record policy

This file is append-only meeting notes. Never edit, delete, reorder, or rewrite
existing entries. Append new dated notes at the end. For a correction or
superseding decision, reference the earlier note in a new entry and retain the
original text.
