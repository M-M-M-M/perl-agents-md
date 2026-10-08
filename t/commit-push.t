use strict ;
use warnings ;
use Test::More ;
use File::Temp qw(tempdir) ;
use File::Path qw(make_path) ;
use IPC::Open3 ;
use Symbol qw(gensym) ;
use lib 'lib' ;
use Agents::Update qw(run_git) ;

my $root = tempdir( CLEANUP => 1 ) ;
my ( $source_code, $old ) = run_git( '.', 'show', 'v1.4.0:AGENTS.md' ) ;
die 'Cannot read released fixture' if $source_code ;

sub write_text {
  my ( $path, $text ) = @_ ;
  open my $fh, '>:encoding(UTF-8)', $path or die "Cannot write $path: $!" ;
  print {$fh} $text or die "Cannot write $path: $!" ;
  close $fh         or die "Cannot close $path: $!" ;
}

sub git {
  my ( $repo, @args ) = @_ ;
  my ( $code, $out, $error ) = run_git( $repo, @args ) ;
  die "Git fixture failed: $error" if $code ;
  return $out ;
}

sub fixture {
  my ($name) = @_ ;
  my $repo   = "$root/$name" ;
  my $remote = "$root/$name.git" ;
  make_path( $repo, $remote ) ;
  git( $remote, 'init',   '--bare',         '-q' ) ;
  git( $repo,   'init',   '-q',             '-b', 'work' ) ;
  git( $repo,   'config', 'user.name',      'Test' ) ;
  git( $repo,   'config', 'user.email',     'test@example.invalid' ) ;
  git( $repo,   'config', 'commit.gpgsign', 'false' ) ;
  write_text( "$repo/AGENTS.md", $old ) ;
  write_text( "$repo/other.txt", 'untouched' ) ;
  git( $repo, 'add',    '.' ) ;
  git( $repo, 'commit', '-qm',                'base' ) ;
  git( $repo, 'remote', 'add',                'origin', $remote ) ;
  git( $repo, 'push',   '-q',                 'origin', 'HEAD:refs/heads/destination' ) ;
  git( $repo, 'config', 'branch.work.remote', 'origin' ) ;
  git( $repo, 'config', 'branch.work.merge',  'refs/heads/destination' ) ;
  return ( $repo, $remote ) ;
}

sub cli {
  my (@repos) = @_ ;
  local $SIG{ALRM} = sub { die 'Publication test timed out'  } ;
  alarm 20 ;
  my $error = gensym ;
  my $pid   = open3( my $input, my $output, $error, $^X, 'update-agents.pl', '--to', '1.5.0', '--commit-push', @repos ) ;
  close $input or die 'Cannot close command input' ;
  local $/ ;
  my $out = <$output> // '' ;
  my $err = <$error>  // '' ;
  close $output or die 'Cannot close command output' ;
  close $error  or die 'Cannot close command error' ;
  waitpid( $pid, 0 ) ;
  alarm 0 ;
  return ( $? >> 8, $out . $err ) ;
}

sub unchanged {
  my ( $repo, $remote, $initial, $description ) = @_ ;
  is( git( $repo,   'status',    '--porcelain' ),            '',       "$description leaves worktree intact" ) ;
  is( git( $repo,   'rev-parse', 'HEAD' ),                   $initial, "$description creates no commit" ) ;
  is( git( $remote, 'rev-parse', 'refs/heads/destination' ), $initial, "$description creates no push" ) ;
}
my ( $repo, $remote ) = fixture('success with spaces') ;
my $initial = git( $repo, 'rev-parse', 'HEAD' ) ;
my ( $exit, $out ) = cli($repo) ;
is( $exit,                                                           0,                                    'commit-push implies apply and succeeds' ) ;
is( git( $repo, 'status', '--porcelain' ),                           '',                                   'successful publication leaves clean worktree' ) ;
is( git( $repo, 'show', '--pretty=format:', '--name-only', 'HEAD' ), "AGENTS.md\n",                        'commit includes only target file' ) ;
is( git( $repo, 'log', '-1', '--format=%s' ),                        "docs: update AGENTS.md to v1.5.0\n", 'commit uses conventional message' ) ;
my $published = git( $repo, 'rev-parse', 'HEAD' ) ;
isnt( $published, $initial, 'update has a new commit' ) ;
is( git( $remote, 'rev-parse', 'refs/heads/destination' ), $published, 'configured upstream receives commit' ) ;
like( $out, qr/Published.*refs\/heads\/destination/, 'result reports destination' ) ;
like( $out, qr/\Q$repo\E\s*\|\s*Published\s*\|/,     'summary records successful publication' ) ;
( $exit, $out ) = cli($repo) ;
is( $exit,                             0,          'already current file is successful' ) ;
is( git( $repo, 'rev-parse', 'HEAD' ), $published, 'already current file creates no commit' ) ;
git( $repo, 'remote', 'set-url', 'origin', "$root/missing-remote" ) ;
( $exit, $out ) = cli($repo) ;
is( $exit, 0, 'current file needs no fetch or accessible remote' ) ;

for my $case (qw(no-upstream detached fetch-failure ahead behind diverged)) {
  ( $repo, $remote ) = fixture($case) ;
  $initial = git( $repo, 'rev-parse', 'HEAD' ) ;
  if ( $case eq 'no-upstream' )   { git( $repo, 'config',   '--unset', 'branch.work.remote' )  }
  if ( $case eq 'detached' )      { git( $repo, 'checkout', '-q',      '--detach' )  }
  if ( $case eq 'fetch-failure' ) { git( $repo, 'remote', 'set-url', 'origin', "$root/nonexistent" )  }
  if ( $case eq 'ahead' || $case eq 'diverged' ) {
    git( $repo, 'commit', '-qm', 'unpublished change', '--allow-empty' ) ;
  }
  if ( $case eq 'behind' || $case eq 'diverged' ) {
    my $clone = "$root/$case-writer" ;
    make_path($clone) ;
    git( $clone, 'clone',  '-q',             '-b', 'destination', $remote, '.' ) ;
    git( $clone, 'config', 'user.name',      'Test' ) ;
    git( $clone, 'config', 'user.email',     'test@example.invalid' ) ;
    git( $clone, 'config', 'commit.gpgsign', 'false' ) ;
    git( $clone, 'commit', '-qm',            'remote change', '--allow-empty' ) ;
    git( $clone, 'push',   '-q' ) ;
  }
  my $before        = git( $repo,   'rev-parse', 'HEAD' ) ;
  my $remote_before = git( $remote, 'rev-parse', 'refs/heads/destination' ) ;
  ( $exit, $out ) = cli($repo) ;
  is( $exit, 1, "$case prevents publication" ) ;
  is( git( $repo,   'status',    '--porcelain' ),            '',             "$case leaves file untouched" ) ;
  is( git( $repo,   'rev-parse', 'HEAD' ),                   $before,        "$case creates no commit" ) ;
  is( git( $remote, 'rev-parse', 'refs/heads/destination' ), $remote_before, "$case creates no push" ) ;
}
( $repo, $remote ) = fixture('dirty') ;
write_text( "$repo/other.txt", 'local change' ) ;
( $exit, $out ) = cli($repo) ;
is( $exit, 1, 'dirty repository is skipped' ) ;
like( $out, qr/update-agents\.pl' --commit-push --to '1\.5\.0'/, 'stash recovery preserves publication mode and explicit version' ) ;
is( git( $repo, 'stash', 'list' ), '', 'publication refusal does not create a stash' ) ;
is( git( $repo, 'diff', '--', 'AGENTS.md' ), '', 'dirty rejection leaves target untouched' ) ;

( $repo, $remote ) = fixture('conflict') ;
my $conflicting = $old ;
$conflicting =~ s/AGENTS.md version: 1.4.0/AGENTS.md version: 1.4.0\nProject-specific insertion/ ;
write_text( "$repo/AGENTS.md", $conflicting ) ;
git( $repo, 'commit', '-qam', 'local adaptation' ) ;
git( $repo, 'push', '-q', 'origin', 'HEAD:refs/heads/destination' ) ;
$initial = git( $repo, 'rev-parse', 'HEAD' ) ;
( $exit, $out ) = cli($repo) ;
is( $exit, 1, 'merge conflict is not published' ) ;
unchanged( $repo, $remote, $initial, 'conflict' ) ;

( $repo, $remote ) = fixture('commit-failure') ;
$initial = git( $repo, 'rev-parse', 'HEAD' ) ;
write_text( "$repo/.git/hooks/pre-commit", "#!/bin/sh\nexit 1\n" ) ;
chmod oct('0755'), "$repo/.git/hooks/pre-commit" or die 'Cannot enable commit hook' ;
( $exit, $out ) = cli($repo) ;
is( $exit, 1, 'commit hook failure is reported' ) ;
like( $out, qr/\Q$repo\E\s*\|\s*Applied, commit failed\s*\|/, 'summary records applied file with failed commit' ) ;
is( git( $repo,   'rev-parse', 'HEAD' ),                   $initial, 'failed commit leaves HEAD intact' ) ;
is( git( $remote, 'rev-parse', 'refs/heads/destination' ), $initial, 'failed commit is not pushed' ) ;
like( git( $repo, 'diff', '--', 'AGENTS.md' ), qr/1.5.0/, 'failed commit preserves update for review' ) ;

( $repo, $remote ) = fixture('push-failure') ;
$initial = git( $repo, 'rev-parse', 'HEAD' ) ;
write_text( "$remote/hooks/pre-receive", "#!/bin/sh\nexit 1\n" ) ;
chmod oct('0755'), "$remote/hooks/pre-receive" or die 'Cannot enable push hook' ;
my ($second) = fixture('continued') ;
( $exit, $out ) = cli( $repo, $second ) ;
is( $exit, 1, 'push failure yields nonzero combined exit' ) ;
like( $out, qr/\Q$repo\E\s*\|\s*Local commit, push failed\s*\|/, 'summary records retained commit after push failure' ) ;
like( $out, qr/\Q$second\E\s*\|\s*Published\s*\|/,               'summary records later successful repository independently' ) ;
isnt( git( $repo, 'rev-parse', 'HEAD' ), $initial, 'failed push preserves local commit' ) ;
is( git( $remote, 'rev-parse', 'refs/heads/destination' ), $initial, 'rejected remote remains intact' ) ;
like( $out, qr/Retry.*push/s, 'push failure prints retry command' ) ;
is( git( $second, 'rev-list', '--count', 'HEAD' ), "2\n", 'later repository is still processed' ) ;
( $repo, $remote ) = fixture('unexpected-hook-change') ;
$initial = git( $repo, 'rev-parse', 'HEAD' ) ;
write_text( "$repo/.git/hooks/pre-commit", "#!/bin/sh\nprintf extra > other.txt\ngit add other.txt\n" ) ;
chmod oct('0755'), "$repo/.git/hooks/pre-commit" or die 'Cannot enable modifying hook' ;
( $exit, $out ) = cli($repo) ;
is( $exit,                                                 1,        'unexpected hook changes prevent push' ) ;
is( git( $remote, 'rev-parse', 'refs/heads/destination' ), $initial, 'unexpected changes are not published' ) ;
like( $out, qr/unexpected changes/, 'unexpected commit contents are reported' ) ;

for my $case (qw(dirty-after-fetch error-after-fetch)) {
  ( $repo, $remote ) = fixture($case) ;
  $initial = git( $repo, 'rev-parse', 'HEAD' ) ;
  git( $repo, 'update-ref', '-d', 'refs/remotes/origin/destination' ) ;
  my $action = $case eq 'dirty-after-fetch'
    ? 'printf backup > AGENTS.md.bak'
    : 'printf broken > .git/index' ;
  write_text( "$repo/.git/hooks/reference-transaction", "#!/bin/sh\nif [ \"\$1\" = committed ]; then\n  $action\nfi\n" ) ;
  chmod oct('0755'), "$repo/.git/hooks/reference-transaction" or die 'Cannot enable fetch fixture hook' ;
  ( $exit, $out ) = cli($repo) ;
  is( $exit, 1, "$case prevents application" ) ;
  like( $out, qr/after upstream preparation/, "$case identifies the preparation phase" ) ;

  if ( $case eq 'dirty-after-fetch' ) {
    like( $out, qr/dirty working tree.*\n\s+\?\? AGENTS.md.bak/,                        'post-fetch dirty report lists blocking backup' ) ;
    like( $out, qr/stash push -u.*\n.*update-agents\.pl.*--commit-push.*\n.*stash pop/, 'post-fetch dirty refusal includes stash sequence' ) ;
    is( git( $repo, 'stash', 'list' ), '', 'post-fetch refusal does not create a stash' ) ;
  } else {
    like( $out, qr/git status failed \(exit 128\)/, 'post-fetch Git failure is distinguished' ) ;
    like( $out, qr/fatal:/,                         'post-fetch Git diagnostic is included' ) ;
    unlike( $out, qr/stash push|stash pop/, 'post-fetch Git error has no stash suggestion' ) ;
  }
  open my $file, '<:encoding(UTF-8)', "$repo/AGENTS.md" or die 'Cannot read target fixture' ;
  my $contents = do { local $/ ; <$file>  } ;
  close $file or die 'Cannot close target fixture' ;
  is( $contents, $old, "$case leaves target intact" ) ;
  is( git( $repo,   'rev-parse', 'HEAD' ),                   $initial, "$case creates no commit" ) ;
  is( git( $remote, 'rev-parse', 'refs/heads/destination' ), $initial, "$case creates no push" ) ;
}
done_testing ;
