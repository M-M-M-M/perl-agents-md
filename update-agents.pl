#!/usr/bin/env perl
use strict ;
use warnings ;
use utf8 ;
use feature 'signatures' ;
use FindBin ;
use lib "$FindBin::Bin/lib" ;
use Agents::Update  qw(analyze update_file run_git) ;
use Agents::Publish qw(resolve_upstream prepare_publish publish_update) ;
use Getopt::Long    qw(GetOptions) ;
use Cwd             qw(abs_path) ;
use File::Basename  qw(dirname) ;
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
for my $input (@ARGV) {
  my $path = -d $input ? "$input/AGENTS.md" : $input ;
  if ( -l $path ) { print "$input: manual — refusing symlink\n" ; $failed = 1 ; next  }
  $path = canonical_path($path) ;
  if ( !defined $path || !-f $path ) { print "$input: manual — file not found\n" ; $failed = 1 ; next  }
  next if $seen{$path}++ ;
  my ( $code, $root, $error ) = run_git( dirname($path), 'rev-parse', '--show-toplevel' ) ;
  if ($code) { print "$input: manual — not a Git repository: $error" ; $failed = 1 ; next  }
  chomp $root ;
  if ( canonical_path($root) eq $source ) { print "$input: excluded — source repository\n" ; next  }
  my $result = analyze( source => $source, path => $path, ( defined $to ? ( to => $to ) : () ) ) ;
  print "$input: $result->{status}", ( $result->{reason} ? " — $result->{reason}" : '' ), "\n" ;
  print "  $_\n" for @{ $result->{notes} } ;
  print $result->{diff} // '' ;
  if ( $result->{status} eq 'manual' ) { $failed = 1 ; next  }
  next if $result->{status} eq 'unchanged' ;

  if ($apply) {
    if ( !check_clean_worktree($root) ) {
      $failed = 1 ;
      next ;
    }
    my $destination ;
    if ($commit_push) {
      eval { $destination = prepare_publish($root) ; 1  } or do { print "  Not applied: $@" ; $failed = 1 ; next  } ;
      if ( !check_clean_worktree( $root, ' after upstream preparation' ) ) {
        $failed = 1 ; next ;
      }
    }
    eval { update_file($result) ; 1  } or do { print "  Not applied: $@" ; $failed = 1 ; next  } ;
    print "  Applied v$result->{version}\n" ;
    if ($commit_push) {
      my $publication ;
      my $relative = substr( $path, length($root) + 1 ) ;
      eval { $publication = publish_update( $root, $relative, $result->{version}, $destination ) ; 1  }
        or do { print "  Not published: $@" ; $failed = 1 ; next  } ;
      if ( !$publication->{pushed} ) {
        print "  Push failed; local commit $publication->{commit} retained: $publication->{error}\n",
          "  Retry: ", push_command( $root, $destination ), "\n" ;
        $failed = 1 ; next ;
      }
      print "  Published $publication->{commit} to $destination->{remote}:$destination->{merge}\n" ;
      next ;
    }
  }
  suggest_commands( $root, $path, $result->{version} ) ;
}
exit $failed ;

sub check_clean_worktree ( $root, $phase = '' ) {
  my ( $code, $status, $error ) = run_git( $root, 'status', '--porcelain=v1', '--untracked-files=normal' ) ;
  if ($code) {
    print "  Not applied: git status failed (exit $code)$phase\n" ;
    my $diagnostic = length( $error . $status ) ? $error . $status : 'Git returned no diagnostic' ;
    print "    $_\n" for split /\n/, $diagnostic ;
    return 0 ;
  }
  if ( length $status ) {
    print "  Not applied: dirty working tree$phase\n" ;
    print "    $_\n" for split /\n/, $status ;
    return 0 ;
  }
  return 1 ;
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

sub suggest_commands ( $root, $path, $version ) {
  my $relative = substr( $path, length($root) + 1 ) ;
  my $prefix   = 'git -C ' . quote_shell($root) ;
  print "  Suggested after application and review:\n",
    "    $prefix diff -- ",          quote_shell($relative), "\n",
    "    $prefix add -- ",           quote_shell($relative), "\n",
    "    $prefix commit --only -m ", quote_shell("docs: update AGENTS.md to v$version"), " -- ", quote_shell($relative), "\n" ;
  my $destination ;
  eval { $destination = resolve_upstream($root) ; 1  } or do { print "    $@" ; return  } ;
  print '    ', push_command( $root, $destination ), "\n" ;
}

sub push_command ( $root, $destination ) {
  return 'git -C ' . quote_shell($root) . ' push ' . quote_shell( $destination->{remote} ) . ' ' . quote_shell("HEAD:$destination->{merge}") ;
}
