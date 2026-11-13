# Isolated runner checks

This file is for a fresh test session, not the persistent skill editor. Apply
the current repository skill to the requested paths in place and follow its
internal implementation/reviewer workflow. Do not edit the skill, call the test
helper recursively, commit, push, or manage PRs. Do not read the editor's human
feedback or `learnings.md`.

## Project checks

Run checks relevant to the requested targets. The final all-project trial must
cover all four projects. Preserve behavior and public interfaces; for prose
edits, check executable syntax or compiled output is unchanged, accounting for
Python docstrings. Explain and validate structural changes separately.

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

Keep build artifacts and test data in disposable locations. Compare behavior
with the branch's starting point and report failed or skipped checks.

Return a concise description of the generated explanations, changed paths,
verification outcomes, limitations, and operational blockers. The editor will
evaluate the result against its goal; do not decide that goal is satisfied.
Keep internal reviewer conversations and scores out of the final response.
The helper captures the actual source diff separately for the editor to inspect.
