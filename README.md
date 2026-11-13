# prose-bench

Small, working projects for evaluating `as-prose`. Each project has multiple
runtime source units.

The skill lives in [.agents/skills/as-prose/](.agents/skills/as-prose/).
See [AGENTS.md](AGENTS.md) for the improvement workflow: update the skill,
apply it directly to projects under `projects/`, and open a PR for
human review. The PR shows the skill's in-place source changes as a normal diff.

| Project | Languages | Runtime source units |
| --- | --- | --- |
| [TCP socket](projects/tcp-socket/) | Java | 3 classes across 2 packages |
| [Password generator](projects/password-generator/) | Python | 2 modules |
| [Make text uppercase](projects/make-text-uppercase/) | JavaScript, HTML, CSS | 2 JavaScript files, plus HTML and CSS |
| [Huffman compressor](projects/huffman-compressor/) | C++, Python | 3 cooperating programs |

## License

The copied fixtures use the upstream [GNU GPL version 3](LICENSE). Their original
authors and local modifications are listed in [NOTICE](NOTICE).
