# perl-agents-md

Reusable `AGENTS.md` guidelines for coding agents working on Perl projects.

This repository contains an initial version of an `AGENTS.md` file designed to
help coding agents work correctly on Perl projects.

The goal is to define clear, reusable instructions for guiding a development
assistant while it reads, changes, and validates Perl code. The file is intended
as a working reference for tools such as Codex, with the option to adapt it later
for other agent environments such as Claude or Antigravity.

The French version is available in [README.fr.md](README.fr.md).

## Purpose

`AGENTS.md` describes the expected practices for writing Perl with discipline:

- disciplined workflow before changing code;
- use of common Perl tools such as `perltidy`, `perlcritic`, `prove`, `yath`,
  `cpanm`, or `carton`;
- readable, explicit, and maintainable code style;
- conventions for modules, objects, errors, tests, and dependencies;
- preference for small, focused changes over implicit rewrites.

The intent is not to create a framework, but an instruction document that can be
copied, adapted, or included in Perl repositories to improve the quality of
agent-generated contributions.

## Intended Usage

The primary use case is Codex: placing this file in a Perl repository gives the
agent the project's expectations before it writes or modifies code.

Over time, the content may also serve as a base for other development
assistants. The wording should therefore remain general enough to be useful
outside Codex, while keeping the practical details needed for day-to-day Perl
work.

## Deployment

To use these guidelines in another Perl repository, copy these files to the root
of the target repository:

- `AGENTS.md`
- `.perltidyrc`

Then review `AGENTS.md` and adapt project-specific details such as test commands,
dependency tooling, preferred modules, or workflow rules. Keep `.perltidyrc`
unchanged if you want to preserve the formatting style provided by this project.

## Perl Formatting

The repository includes a reference perltidy configuration in
[`.perltidyrc`](.perltidyrc). Agents should use this file as-is when formatting
Perl code, because it matches the intended local style.

Detailed perltidy usage notes are documented in
[`DOCUMENTATION.md`](DOCUMENTATION.md). The main README only records the
project-level rule: format with perltidy, use the provided configuration, and do
not change it unless the user explicitly asks for style changes.

## Acknowledgements

This project was inspired by Yegor Bugayenko's
[`yegor256/prompt`](https://github.com/yegor256/prompt), adapted here for
Perl-focused coding agents. See
[`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md) for license notices.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

## Project Status

`AGENTS.md` is an initial version. It may still evolve to clarify instructions,
remove duplication, separate general rules from tool-specific rules, or add
variants for different kinds of Perl projects.
