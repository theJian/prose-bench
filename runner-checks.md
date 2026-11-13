# Isolated runner checks

This file is for the isolated runner, not the skill editor. Apply the current
repository skill in place and follow its internal implementation/reviewer
workflow. Keep implementation details, reviewer feedback, and scores inside
this run. Do not read the editor's human feedback or `learnings.md`.

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

Keep build artifacts and test data in disposable locations. Compare behavior
with the branch's starting point and report failed or skipped checks.

Return only completion status, changed paths, check pass/fail (including skipped
checks), and operational blockers. Do not return source excerpts, detailed
execution logs, reviewer findings, or suggestions for changing the skill.
