# Documentation

This document gives practical details for using the repository conventions. The
main README explains the purpose of the project; this file explains how to apply
the tooling.

The French version is available in [DOCUMENTATION.fr.md](DOCUMENTATION.fr.md).

## Version

This documentation applies to version 1.6.1. Release details are recorded in
[CHANGELOG.md](CHANGELOG.md).

## Perl Formatting With perltidy

This repository provides a `.perltidyrc` file at the repository root. It is the
reference formatting configuration for Perl code and should be used as-is.

`perltidy` automatically looks for `.perltidyrc` in the current working
directory, so running commands from the repository root is enough.

## Perl Signatures

When a new function or a targeted refactor has parameters whose meaning is made
clearer by signatures, enable them explicitly in that file:

```perl
use feature 'signatures';
```

Use signatures to improve readability, not as a mechanical rewrite rule. Keep
simple code simple, and respect the existing style of files that do not already
use signatures unless the refactor clearly benefits from them.

## Preview Formatting

To print formatted code to the terminal without changing the source file:

```bash
perltidy -st -se path/to/script.pl
```

`-st` sends the formatted code to standard output. `-se` sends errors and
warnings to standard error.

## Format One File

To reformat a file in place and keep a `.bak` backup:

```bash
perltidy -b path/to/script.pl
```

To reformat a file in place without creating a backup:

```bash
perltidy -b -bext='/' path/to/script.pl
```

## Format Several Files

To format all Perl scripts in the current directory:

```bash
perltidy -b *.pl
```

For larger projects, prefer passing explicit paths or using the project's
existing test or formatting command if one exists.

## Validate Formatting Without Editing Sources

To check that `perltidy` can process files without writing beside the source
files:

```bash
mkdir -p /tmp/perltidy-check
perltidy -se -opath=/tmp/perltidy-check path/to/script.pl
```

`-opath=/tmp/perltidy-check` writes the formatted output to another directory
instead of modifying files in the repository.

## Option Summary

`-b` formats files in place and creates `.bak` backups.

`-bext='/'` disables backup creation when `-b` is used.

`-st` writes formatted code to standard output.

`-se` writes errors and warnings to standard error.

`-opath=DIR` writes formatted files into another directory.

`-pro=FILE` selects a specific perltidy configuration file. It is usually not
needed from this repository root because `.perltidyrc` is already there.

## Updating Existing AGENTS.md Files

The helper updates only `AGENTS.md`. It neither copies nor modifies
`.perltidyrc`, including with `--apply` or `--commit-push`. Each project keeps
its own formatting configuration. `.perltidyrc` is already tracked in Git
and included in releases; it needs no separate version number.

The helper requires Perl 5.36 or newer and Git, using only core Perl
modules. Text files, command-line arguments, and Git output are interpreted
as UTF-8. Keep `update-agents.pl` alongside its `lib` directory and the
source Git repository with its release tags. Report mode and `--apply` alone
make no network requests; `--commit-push` fetches and pushes to the
configured upstream.

```bash
./update-agents.pl ../*/AGENTS.md
./update-agents.pl --to 1.5.0 ../project/AGENTS.md
./update-agents.pl --apply ../project
./update-agents.pl --commit-push ../project
```

Arguments can be repository directories or file paths. By default, the
helper prints proposed diffs and performs no writes. The target is the
highest stable `vX.Y.Z` tag available locally, not the uncommitted source
file; `--to X.Y.Z` selects a specific tagged release. Duplicate paths are
processed once and the source repository is excluded.

Exact old copies are replaced with the target model. Identified custom
versions are merged against their tagged base, preserving local additions,
replacements, and deletions. Entire top-level sections omitted locally
remain omitted, including new upstream rules within those sections; the
report identifies ignored section updates. This is a textual merge, so a
successful result still needs review for semantic compatibility with the
project.

Conflicts leave the entire file unchanged. The report prints the candidate
with line numbers and LOCAL, BASE, and TARGET conflict markers for manual
comparison. Missing or unknown version markers, newer local versions,
unreadable files, invalid targets, and symlinks are reported for manual
review. Version markers advance only when the complete merge succeeds.

`--apply` writes only in clean Git working trees, including untracked files
in the cleanliness check. It preserves file permissions, replaces files
atomically, and rejects changes made since analysis. Each repository is
handled independently; successful earlier updates remain applied if another
repository fails.

When application is refused, `dirty working tree` lists the blocking paths
with Git status codes: `??` means untracked, the first column describes
staged changes, and the second describes unstaged changes. A Git command
failure instead reports `git status failed`, its exit code, and the Git
diagnostic. The same distinction applies after upstream preparation with
`--commit-push`. Untracked backups are not ignored or deleted automatically.

Suggested commands include diff review, staging only the target file, a
Conventional Commit limited to that file, and pushing the current branch to
its configured upstream. In report mode or with `--apply` alone, no commit,
push, fetch, or pull is executed. Missing upstream configuration requires
manual setup. Review the diff and repository state before running any
suggested commands.

`--commit-push` implies `--apply` and runs without additional confirmation.
Before writing, it requires a clean working tree, an active branch, and a
configured upstream. It fetches only that upstream branch without tags or
submodules and requires local HEAD to equal the fetched commit. Ahead,
behind, or divergent branches are skipped for manual synchronization; no
merge or rebase is performed.

The helper creates `docs: update AGENTS.md to vX.Y.Z`, committing only the
target file with normal Git hooks. It verifies the commit contains only that
file before pushing explicitly to the configured upstream branch, without
force. Successful publication reports the commit hash and destination.
Already current files cause no fetch, commit, or push.

If commit fails, the updated file remains available for review and no push
occurs. If push fails, the local commit remains and a retry command is
printed. No reset or rollback is performed. Other repositories continue
independently. A rerun on an already current file does not retry an earlier
failed push; use the printed command after checking the repository state.

Exit status is `0` for successful reports or applications, `1` when any item
needs manual review or cannot be applied, and `2` for invalid command-line
syntax. An unchanged file or exclusion of the source repository is
successful.

Run offline tests from the source repository root:

```bash
prove -l t
perlcritic lib/Agents/*.pm update-agents.pl t/*.t
PERL5OPT=-MDevel::Cover prove -l t
cover
```

Coverage requires Devel::Cover; formatting uses the repository
`.perltidyrc`. Tests use temporary Git repositories and local bare remotes,
with no Internet access or updates to neighboring projects.
