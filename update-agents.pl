#!/usr/bin/env perl
use strict ;
use warnings ;
use utf8 ;
use feature 'signatures' ;
use FindBin ;
use lib "$FindBin::Bin/lib" ;
use Agents::Update  qw(analyze update_file run_git) ;
use Agents::Publish qw(resolve_upstream prepare_publish publish_update) ;
use Agents::Report  qw(start_block event set_outcome print_summary) ;
use Getopt::Long    qw(GetOptions) ;
use Cwd             qw(abs_path) ;
use File::Basename  qw(dirname basename) ;
use Encode          qw(decode FB_CROAK) ;

binmode STDOUT, ':encoding(UTF-8)' or die "Cannot encode stdout: $!" ;
binmode STDERR, ':encoding(UTF-8)' or die "Cannot encode stderr: $!" ;
@ARGV = map { decode( 'UTF-8', $_, FB_CROAK ) } @ARGV ;
my ( $apply, $commit_push, $to, $help ) ;
GetOptions( 'apply' => \$apply, 'commit-push' => \$commit_push, 'to=s' => \$to, 'help' => \$help ) or exit 2 ;
$apply = 1 if $commit_push ;
if ( $help || !@ARGV ) {
  print "Usage: $0 [--apply | --commit-push] [--to X.Y.Z] REPO_OR_AGENTS_FILE ...\n",
    "Default: report only; --apply updates clean repositories without commit or push\n",
    "--commit-push implies --apply, fetches upstream, commits and pushes without confirmation\n" ;
  exit( $help ? 0 : 2 ) ;
}
my $source = canonical_path($FindBin::Bin) ;
my $failed = 0 ;
my %seen ;
my @rows ;
for my $input (@ARGV) {
  my $candidate = -d $input ? "$input/AGENTS.md" : $input ;
  my $symlink   = -l $candidate ;
  my $path      = $symlink ? undef : canonical_path($candidate) ;
  next if defined($path) && -f $path && $seen{$path}++ ;
  my $row = start_block( $input, basename( dirname($candidate) ) ) ;
  push @rows, $row ;
  if ( $symlink || !defined($path) || !-f $path ) {
    my $reason = $symlink ? 'refusing symlink' : 'file not found' ;
    event( $row, 'REVIEW', "$input: manual — $reason" ) ;
    set_outcome( $row, 'Review required', $reason ) ;
    $failed = 1 ; next ;
  }
  my ( $code, $root, $error ) = run_git( dirname($path), 'rev-parse', '--show-toplevel' ) ;
  if ($code) {
    event( $row, 'REVIEW', "$input: manual — not a Git repository: $error" ) ;
    set_outcome( $row, 'Review required', "not a Git repository: $error" ) ;
    $failed = 1 ; next ;
  }
  chomp $root ;
  if ( canonical_path($root) eq $source ) {
    event( $row, 'SKIP', "$input: excluded — source repository" ) ;
    set_outcome( $row, 'Excluded', 'source repository' ) ; next ;
  }
  my $result = analyze( source => $source, path => $path, ( defined $to ? ( to => $to ) : () ) ) ;
  my $level  = $result->{status} eq 'manual' ? 'REVIEW' : $result->{status} eq 'unchanged' ? 'OK' : 'UPDATE' ;
  event( $row, $level,    "$input: $result->{status}" . ( $result->{reason} ? " — $result->{reason}" : '' ) ) ;
  event( $row, 'WARNING', $_ ) for @{ $result->{notes} } ;
  print $result->{diff} // '' ;
  if ( $result->{status} eq 'manual' ) {
    set_outcome( $row, 'Review required', $result->{reason} ) ;
    $failed = 1 ; next ;
  }
  if ( $result->{status} eq 'unchanged' ) { set_outcome( $row, 'Unchanged' ) ; next  }
  set_outcome( $row, 'Proposed', "target v$result->{version}" ) ;
  if ($apply) {
    if ( !check_clean_worktree( $root, $row, $path ) ) { $failed = 1 ; next  }
    my $destination ;
    if ($commit_push) {
      eval { $destination = prepare_publish($root) ; 1  } or do {
        my $reason = $@ ;
        event( $row, 'ERROR', "Not applied: $reason" ) ;
        set_outcome( $row, 'Blocked', $reason ) ; $failed = 1 ; next ;
      } ;
      if ( !check_clean_worktree( $root, $row, $path, ' after upstream preparation' ) ) { $failed = 1 ; next  }
    }
    eval { update_file($result) ; 1  } or do {
      my $reason = $@ ;
      event( $row, 'ERROR', "Not applied: $reason" ) ;
      set_outcome( $row, 'Error, not applied', $reason ) ; $failed = 1 ; next ;
    } ;
    event( $row, 'OK', "Applied v$result->{version}" ) ;
    set_outcome( $row, 'Applied', "v$result->{version}" ) ;
    if ($commit_push) {
      my $publication ;
      my $relative = substr( $path, length($root) + 1 ) ;
      eval { $publication = publish_update( $root, $relative, $result->{version}, $destination ) ; 1  } or do {
        my $reason = $@ ;
        event( $row, 'ERROR', "Not published: $reason" ) ;
        my ( $head_code, $head ) = run_git( $root, 'rev-parse', 'HEAD' ) ; chomp $head ;
        my $outcome = !$head_code && $head ne $destination->{head} ? 'Local commit retained' : 'Applied, commit failed' ;
        set_outcome( $row, $outcome, $reason ) ; $failed = 1 ; next ;
      } ;
      if ( !$publication->{pushed} ) {
        event( $row, 'ERROR', "Push failed; local commit $publication->{commit} retained: $publication->{error}" ) ;
        print '  Retry: ', push_command( $root, $destination ), "\n" ;
        set_outcome( $row, 'Local commit, push failed', "$publication->{commit}: $publication->{error}" ) ;
        $failed = 1 ; next ;
      }
      event( $row, 'OK', "Published $publication->{commit} to $destination->{remote}:$destination->{merge}" ) ;
      set_outcome( $row, 'Published', "$publication->{commit} -> $destination->{remote}:$destination->{merge}" ) ; next ;
    }
  }
  suggest_commands( $root, $path, $result->{version}, $row ) ;
}
print_summary( \@rows ) ;
exit $failed ;

sub check_clean_worktree ( $root, $row, $path, $phase = '' ) {
  my ( $code, $status, $error ) = run_git( $root, 'status', '--porcelain=v1', '--untracked-files=normal' ) ;
  if ($code) {
    my $diagnostic = length( $error . $status ) ? $error . $status : 'Git returned no diagnostic' ;
    event( $row, 'ERROR', "Not applied: git status failed (exit $code)$phase" ) ;
    print "    $_\n" for split /\n/, $diagnostic ;
    set_outcome( $row, 'Error, not applied', "git status failed (exit $code)$phase: $diagnostic" ) ; return 0 ;
  }
  if ( length $status ) {
    event( $row, 'ERROR', "Not applied: dirty working tree$phase" ) ;
    print "    $_\n" for split /\n/, $status ;
    set_outcome( $row, 'Blocked', "dirty working tree$phase: $status" ) ;
    suggest_stash( $root, $path, $row ) ;
    return 0 ;
  }
  return 1 ;
}

sub suggest_stash ( $root, $path, $row ) {
  event( $row, 'WARNING', 'A temporary stash may help; restoring it may require manual conflict resolution' ) ;
  my $prefix = 'git -C ' . quote_shell($root) ;
  my $update = quote_shell("$source/update-agents.pl") . ( $commit_push ? ' --commit-push' : ' --apply' ) ;
  $update .= ' --to ' . quote_shell($to) if defined $to ;
  $update .= ' ' . quote_shell($path) ;
  print "  Suggested commands (not executed):\n",
    "    $prefix stash push -u -m \"Temporary stash before AGENTS.md update\"\n",
    "    $update\n",
    "    $prefix stash pop\n" or die "Cannot write stash suggestions: $!" ;
}

sub canonical_path ($path) {
  my $absolute = abs_path($path) ;
  return unless defined $absolute ;
  return utf8::is_utf8($absolute) ? $absolute : decode( 'UTF-8', $absolute, FB_CROAK ) ;
}

sub quote_shell ($text) {
  $text =~ s/'/'"'"'/g ;
  return "'$text'" ;
}

sub suggest_commands ( $root, $path, $version, $row ) {
  my $relative = substr( $path, length($root) + 1 ) ;
  my $prefix   = 'git -C ' . quote_shell($root) ;
  print "  Suggested after application and review:\n",
    "    $prefix diff -- ",          quote_shell($relative), "\n",
    "    $prefix add -- ",           quote_shell($relative), "\n",
    "    $prefix commit --only -m ", quote_shell("docs: update AGENTS.md to v$version"), " -- ", quote_shell($relative), "\n" ;
  my $destination ;
  eval { $destination = resolve_upstream($root) ; 1  } or do { event( $row, 'WARNING', $@ ) ; return  } ;
  print '    ', push_command( $root, $destination ), "\n" ;
}

sub push_command ( $root, $destination ) {
  return 'git -C ' . quote_shell($root) . ' push ' . quote_shell( $destination->{remote} ) . ' ' . quote_shell("HEAD:$destination->{merge}") ;
}
