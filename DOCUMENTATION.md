# Documentation

This document gives practical details for using the repository conventions. The
main README explains the purpose of the project; this file explains how to apply
the tooling.

The French version is available in [DOCUMENTATION.fr.md](DOCUMENTATION.fr.md).

## Version

This documentation applies to version 1.1.0. Release details are recorded in
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
