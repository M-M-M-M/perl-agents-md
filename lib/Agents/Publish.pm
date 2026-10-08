package Agents::Publish ;
use strict ;
use warnings ;
use feature 'signatures' ;
use Exporter 'import' ;
use Agents::Update qw(run_git) ;
our @EXPORT_OK = qw(resolve_upstream prepare_publish publish_update) ;

sub git_output ( $root, $context, @args ) {
  my ( $code, $out, $error ) = run_git( $root, @args ) ;
  die "$context: $error$out\n" if $code ;
  chomp $out ;
  return $out ;
}

sub resolve_upstream ($root) {
  my $branch = git_output( $root, 'Push requires an active branch with a configured upstream', 'symbolic-ref', '--quiet', '--short', 'HEAD' ) ;
  my $remote = git_output( $root, 'Push requires a configured upstream remote', 'config', '--get', "branch.$branch.remote" ) ;
  my $merge  = git_output( $root, 'Push requires a configured upstream branch', 'config', '--get', "branch.$branch.merge" ) ;
  die "Upstream must identify a branch: $merge\n" unless $merge =~ m{\Arefs/heads/} ;
  return { branch => $branch, remote => $remote, merge => $merge } ;
}

sub prepare_publish ($root) {
  my $destination = resolve_upstream($root) ;
  my $head        = git_output( $root, 'Cannot read HEAD', 'rev-parse', 'HEAD' ) ;
  git_output( $root, 'Fetch failed before application', 'fetch', '--no-tags', '--no-recurse-submodules', '--', $destination->{remote}, $destination->{merge} ) ;
  my $upstream = git_output( $root, 'Cannot read fetched upstream', 'rev-parse', 'FETCH_HEAD' ) ;
  die "Synchronize the branch with its upstream before publication\n" unless $head eq $upstream ;
  $destination->{head} = $head ;
  return $destination ;
}

sub publish_update ( $root, $relative, $version, $destination ) {
  my $current = resolve_upstream($root) ;
  for my $key (qw(branch remote merge)) {
    die "Publication destination changed since analysis\n" unless $current->{$key} eq $destination->{$key} ;
  }
  my $head = git_output( $root, 'Cannot read HEAD', 'rev-parse', 'HEAD' ) ;
  die "HEAD changed since analysis\n" unless $head eq $destination->{head} ;
  git_output( $root, 'Commit failed; update retained for review', 'commit', '--only', '-m', "docs: update AGENTS.md to v$version", '--', $relative ) ;
  my $commit = git_output( $root, 'Cannot read created commit',  'rev-parse', 'HEAD' ) ;
  my $parent = git_output( $root, 'Cannot verify commit parent', 'rev-parse', 'HEAD^' ) ;
  my $files  = git_output( $root, 'Cannot verify commit files',  'diff-tree', '--no-commit-id', '--name-only', '-r', '-z', 'HEAD' ) ;
  die "Created commit contains unexpected changes; retained locally without push\n"

    unless $parent eq $destination->{head} && $files eq "$relative\0" ;
  my ( $code, $out, $error ) = run_git( $root, 'push', '--', $destination->{remote}, "HEAD:$destination->{merge}" ) ;
  return { commit => $commit, error => $code ? "$error$out" : '', pushed => !$code } ;
}

1 ;

=head1 NAME

Agents::Publish - Publish only a guideline update to a synchronized upstream

=head1 CONTRACT

C<resolve_upstream> returns the active branch and configured remote branch.
C<prepare_publish> fetches that branch without tags or submodules and requires
the fetched commit to equal local HEAD. Call it before modifying the file.

C<publish_update> verifies the prepared destination and HEAD, commits only the
target path with normal Git hooks, verifies the commit contents, then pushes
without force. Commit failures throw; push failures return the local commit and
error for recovery. No rollback is performed. The caller enforces a clean working
tree before preparation. Text inputs and outputs are UTF-8 character strings.

=cut
