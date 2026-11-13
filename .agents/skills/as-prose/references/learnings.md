# Accepted human feedback

Add a lesson only after a human explicitly comments `clean` on the relevant PR.
Capture what the accepted feedback demonstrates; do not invent lessons from
agent scores or treat every example as a universal rule.

For each accepted change, record:

- PR URL, accepted revision SHA, and links to the human feedback and `clean` comment.
- The reader problem and the reusable guidance that resolved it.
- A concrete before/after example or source location, with its relevant context.
- A regression check describing the observable result future runs must preserve.

The iteration coordinator reads these lessons before changing the skill and
checks their regression criteria before requesting review. Independent reviewers
still receive the fresh, uncoached brief required by the skill.
