# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.7.0] - 2026-10-08

### Added

- Suggested manual stash, update, and restore commands for dirty working trees,
  preserving the requested publication mode and target version.
- Labeled output blocks per repository and a final table identifying actual
  update and publication outcomes, warnings, and blocking diagnostics.

## [1.6.1] - 2026-10-08

### Fixed

- Distinguish dirty working trees from Git status errors when refusing guideline
  updates, listing blocking paths or the exit code and Git diagnostic, including
  checks after upstream preparation.

## [1.6.0] - 2026-10-08

### Added

- Perl helper to preview or apply updates from tagged AGENTS.md releases while
  preserving project-specific additions, edits, and deletions.
- Manual-review reports for conflicts and unidentified versions, clean-tree
  checks for application, and suggested commit and push commands.
- Offline tests and bilingual helper documentation.
- `--commit-push` to apply, commit, and push guideline updates automatically to
  synchronized upstream branches, with recovery reports for publication failures.

## [1.5.0] - 2026-10-08

### Added

- Browser-testing guidance covering Playwright, Docker, isolated environments,
  dedicated credentials, production safeguards, approval requirements, and
  accurate reporting of executed and skipped tests.

### Changed

- Updated version markers and English and French documentation for version 1.5.0.

## [1.4.0] - 2026-10-05

### Added

- Guidance to consult relevant existing project documentation before changes,
  including project tasks and release history when relevant.
- Guidance for an optional documentation index identifying authoritative
  documents and when to consult them.

### Changed

- Made documentation maintenance part of each change, preserving canonical
  documents and keeping language translations synchronized.
- Clarified that document names are examples and do not require creating new
  files or imposing a documentation structure on other projects.
- Replaced unconditional Git pulls with working-tree and branch inspection,
  preserving existing changes and synchronizing with upstream only when safe.
- Updated English and French documentation for version 1.4.0.

## [1.3.1] - 2026-09-30

### Changed

- Clarified dependency selection wording for newly introduced modules.
- Clarified when Prettier should not be run on `AGENTS.md` or `CHANGELOG.md`.

## [1.3.0] - 2026-09-30

### Added

- Markdown formatting and linting guidance for agent-maintained documentation.

### Changed

- Clarified when README, documentation, TODO, and changelog files should be
  updated.

## [1.2.0] - 2026-07-14

### Added

- Guidance to use `perltidy -b -bext='/'` when formatting in place to avoid
  creating `.bak` backup files.
- Version marker at the top of `AGENTS.md`.

## [1.1.0] - 2026-07-14

### Added

- Guidance for enabling Perl signatures explicitly when they improve parameter
  readability.

## [1.0.0] - 2026-06-09

### Added

- Reusable `AGENTS.md` guidelines for Perl coding agents.
- Reference `.perltidyrc` configuration and bilingual usage documentation.
- English and French project documentation.
- MIT license and third-party attribution notices.

[Unreleased]: https://github.com/M-M-M-M/perl-agents-md/compare/v1.7.0...HEAD
[1.7.0]: https://github.com/M-M-M-M/perl-agents-md/compare/v1.6.1...v1.7.0
[1.6.1]: https://github.com/M-M-M-M/perl-agents-md/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/M-M-M-M/perl-agents-md/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/M-M-M-M/perl-agents-md/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/M-M-M-M/perl-agents-md/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/M-M-M-M/perl-agents-md/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/M-M-M-M/perl-agents-md/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/M-M-M-M/perl-agents-md/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/M-M-M-M/perl-agents-md/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/M-M-M-M/perl-agents-md/releases/tag/v1.0.0
