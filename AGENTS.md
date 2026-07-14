# Tools

Use GNU command-line tools such as gsed, gfind, ggrep, and gcat to ensure consistent behavior across macOS and Linux.
Prefer modern tools such as rg (ripgrep) when available.
Use perltidy with the repository `.perltidyrc` for formatting.
Use perlcritic for static analysis when available.
Use prove to run tests.
Use cpanm to manage dependencies.
Use Conventional Commits https://www.conventionalcommits.org/en/v1.0.0/

# Discipline

Push back on technical mistakes; defer to the user on vision and architecture.
Stay on scope; refactor only what the task requires.
Respect the requested change scope: test-only requests should not modify production code, and code-only requests should not rewrite tests beyond the requested behavior.
Keep test and production changes tied to the same behavior; avoid unrelated side effects.
Design top-down: behavior before modules, interfaces before implementation.
Git pull before making any changes.
Always TDD: reproduce bugs/features with tests before fixing.
Keep commits focused on one logical change; do not mix unrelated work in the same commit.
Use debug logging for hard problems, preferably through Log::Any or an existing project logger.
Don't fight upstream bugs; suggest filing an issue and wait for a fix unless a small local workaround is clearly justified.
Avoid large changes; leave TODO puzzles for follow-up.
Flag smells and refactoring; suggest issues, don't fix silently.
Do not merge changes without committing first and getting review or approval when the workflow requires it.

# Perl

Use strict and warnings in every file.
Use feature pragmas explicitly, not globally.
Use `use feature 'signatures';` explicitly for new functions or refactorings when signatures improve parameter readability, but do not apply signatures mechanically to simple code or files whose existing style avoids them.
Prefer lexical variables with my.
Avoid package globals unless required by the framework.
Avoid indirect object syntax.
Avoid symbolic references.
Avoid bareword filehandles; use lexical filehandles.
Use three-argument open.
Always check I/O errors.
Prefer autodie when appropriate.
Use UTF-8 deliberately. For text data, declare encodings explicitly at boundaries: source files, command-line arguments, environment variables, file I/O, STDIN, STDOUT, STDERR, network responses, database connections, and templates.
Do not apply UTF-8 layers to binary data such as archives, images, Excel files, compressed files, sockets carrying binary protocols, or raw checksums.
Prefer decoding bytes into Perl character strings as early as practical, and encoding character strings back to bytes only at output boundaries.
For source files containing non-ASCII text, use `use utf8;`.
For text file I/O, prefer explicit modes such as `>:encoding(UTF-8)` and `<:encoding(UTF-8)`, or an existing project abstraction that does the same.
Use modules for behavior, not large procedural scripts.
Keep packages small and cohesive.
Use namespaces that reflect domain concepts.
Avoid clever Perl when clear Perl is better.
Avoid excessive punctuation-heavy idioms when they reduce readability.
Prefer named subroutines over large anonymous blocks.
Avoid modifying $_ implicitly in non-trivial code.
Avoid hidden side effects in map and grep.
Use map for transformation, grep for filtering, foreach for side effects.
Do not introduce heavy dependencies without justification.
Error/log messages: no trailing period, single sentence, include context.
When a non-core module is needed, prefer this known module set before introducing another dependency: Archive::Zip, Archive::Zip::MemberRead, Array::Compare, Cwd, DBD::Pg, DBD::SQLite, DBI, Data::Dumper, Data::Peek, Date::Calc, DateTime, DateTime::Format::Excel, DateTime::Format::ISO8601, Devel::NYTProf, Encode, Excel::Writer::XLSX, Excel::Writer::XLSX::Utility, File::Copy, File::Path, File::Which, Getopt::Long, HTTP::Cookies, HTTP::Request::Common, I18N::Langinfo, IO::Pty, JSON, JSON::PP, JSON::Lines, LWP::UserAgent, List::MoreUtils, List::Util, Mojolicious::Lite, Math::Units, MIME::Base64, MIME::Lite, MIME::Parser, Net::LDAP, Net::SFTP::Foreign, Perl::Tidy, REST::Client, Scalar::Util, Sort::Key, Schedule::RateLimiter, Spreadsheet::XLSX, Text::CSV, Text::Iconv, Time::Duration, Time::HiRes, Time::Limit, URI::Escape, XML::Hash, XML::XML2JSON, XML::LibXML, XML::LibXML::XPathContext, Math::Units, Test::MockModule, threads, threads::shared, Thread::Queue, utf8, utf8::all, strict
Before introducing new modules, check and select those that sounds maintained.

# Objects

Avoid object-oriented design unless it models the domain or matches the project style.
Prefer Moo, Moose, or the project’s existing object system.
Favor immutable objects where practical.
Favor "fail fast" over "fail safe".
Constructors should validate required data and leave objects in a valid state.
Avoid inheritance unless the domain model clearly requires it.
Favor composition and roles over inheritance.
Avoid generic names like Manager, Processor, Handler, and Helper unless required by the framework.
Avoid utility modules full of unrelated functions.
Keep object attributes few and meaningful.
Do not expose raw internal state unnecessarily.
Avoid setters unless mutation is part of the domain behavior.
Prefer explicit methods that express intent.
Never return undef to signal normal absence when a clearer value object, empty list, Maybe type, or exception is better.
Avoid type introspection and ref checks when polymorphism or roles are clearer.
Use exceptions consistently; do not mix silent failure, undef, and die randomly.

# Code Style

Format Perl files with perltidy using the repository `.perltidyrc`.
Do not change `.perltidyrc` unless the user explicitly asks for style changes.
No inline comments for obvious code.
Use comments to explain why, not what.
Document public modules with POD.
Document purpose, invariants, and domain meaning rather than usage examples only.
Variables: short nouns for local scope, clear nouns for wider scope.
Subroutines: verbs for commands, nouns for queries.
Avoid long subroutines.
Avoid deeply nested conditionals.
Prefer early return for guard clauses.
Keep indentation monotonic and readable.
Keep paired delimiters visually clear.
Avoid blank-line noise, but allow blank lines to separate logical steps.

# Tests

Use Test::More or the project’s existing test framework.
Use Test2::V1 when already adopted by the project.
Run tests with prove
Add or update tests for the behavior being changed.
Increase coverage for touched behavior, but do not chase 100% coverage unless explicitly asked.
One behavior per test.
Keep tests short and explicit.
Name test files after the module or feature they cover.
Default to creating a new test file for each new feature; add to an existing file only when it belongs to the same functional area.
Use meaningful test names.
Avoid shared mutable state between tests.
Avoid global fixtures unless they are read-only and stable.
Use temp directories with File::Temp.
Do not rely on Internet access.
Use ephemeral ports for network tests.
Disable or capture logging in tests.
Prefer fakes/stubs over excessive mocks.
Use irregular/random-looking inputs where useful.
Inline small fixtures, generate large fixtures at runtime.
Test failure paths, not only happy paths.
Use timeouts for blocking operations.
Test concurrency when the code is concurrent.
Refactored code must keep the existing tests passing.
Do not test private implementation details.
Do not test accessors unless they encode behavior.
Do not assert exact error messages unless the message is part of the public contract.
Run test coverage.

# Documentation

After each changes update doc README.md and README.xx.md language versions. Same for DOCUMENTATION.md and DOCUMENTATION.xx.md if documentation is not managed in the README.md.
Eventually update the TODO.md - make as done - [x]
Eventually update a CHANGELOG.md
