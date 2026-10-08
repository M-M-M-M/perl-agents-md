package Agents::Update ;
use strict ;
use warnings ;
use feature 'signatures' ;
use Exporter 'import' ;
use Encode         qw(encode decode FB_CROAK) ;
use File::Temp     qw(tempdir tempfile) ;
use File::Basename qw(dirname) ;
use IPC::Open3 ;
use IO::Select ;
use Symbol qw(gensym) ;
our @EXPORT_OK = qw(analyze update_file run_git) ;

sub command (@args) {
  my $error = gensym ;
  my $pid   = open3( my $input, my $output, $error, map { encode( 'UTF-8', $_ ) } @args ) ;
  close $input or die "Cannot close command input: $!" ;
  my $select = IO::Select->new( $output, $error ) ;
  my %data   = ( fileno($output) => '', fileno($error) => '' ) ;
  my ( $out_id, $err_id ) = ( fileno($output), fileno($error) ) ;
  while ( my @ready = $select->can_read ) {
    for my $fh (@ready) {
      my $count = sysread $fh, my $chunk, 65536 ;
      die "Cannot read command output: $!" unless defined $count ;
      if ($count) { $data{ fileno($fh) } .= $chunk  }
      else        { $select->remove($fh) ; close $fh or die "Cannot close command output: $!"  }
    }
  }
  waitpid( $pid, 0 ) == $pid or die "Cannot wait for command: $!" ;
  my $status = $? ;
  return ( $status & 127 ? 128 + ( $status & 127 ) : $status >> 8,
    decode( 'UTF-8', $data{$out_id}, FB_CROAK ), decode( 'UTF-8', $data{$err_id}, FB_CROAK ) ) ;
}

sub run_git ( $root, @args ) { return command( 'git', '-C', $root, @args )  }

sub read_text ($path) {
  open my $fh, '<:raw', $path or die "Cannot read $path: $!" ;
  local $/ ;
  my $text = <$fh> ;
  close $fh or die "Cannot close $path: $!" ;
  return decode( 'UTF-8', $text // '', FB_CROAK ) ;
}

sub write_text ( $path, $text ) {
  open my $fh, '>:encoding(UTF-8)', $path or die "Cannot write $path: $!" ;
  print {$fh} $text or die "Cannot write $path: $!" ;
  close $fh         or die "Cannot close $path: $!" ;
}

sub version_parts ($version) { return split /\./, $version  }

sub compare_versions ( $left, $right ) {
  my @left  = version_parts($left) ;
  my @right = version_parts($right) ;
  for my $i ( 0 .. 2 ) { return $left[$i] <=> $right[$i] if $left[$i] != $right[$i]  }
  return 0 ;
}

sub sections ($text) {
  my %sections ;
  while ( $text =~ /(^# ([^\n]+)\n.*?)(?=^# |\z)/msg ) {
    die "Duplicate section heading $2" if exists $sections{$2} ;
    $sections{$2} = $1 ;
  }
  return \%sections ;
}

sub analyze (%args) {
  my $result = { path => $args{path}, status => 'manual', notes => [] } ;
  eval { analyze_content( $result, %args ) ; 1  } or do {
    my $error = $@ ;
    $error =~ s/\s+\z// ;
    my $location = __FILE__ ;
    $error =~ s/ at \Q$location\E line [0-9]+\.\z// ;
    $result->{status} = 'manual' ;
    delete $result->{content} ;
    $result->{reason} = $error ;
  } ;
  return $result ;
}

sub analyze_content ( $result, %args ) {
  my $path = $args{path} ;
  die "Refusing symlink $path" if -l $path ;
  my $local = read_text($path) ;
  $result->{original} = $local ;
  $local =~ /\AAGENTS\.md version: ((?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*))\r?\n/
    or die "No identifiable version in $path" ;
  my $version = $1 ;
  my ( $code, $tags, $error ) = run_git( $args{source}, 'tag', '--list' ) ;
  die "Cannot list source tags: $error" if $code ;
  my @versions = map { substr( $_, 1 ) } grep {/^v(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)$/} split /\n/, $tags ;
  @versions = sort { compare_versions( $a, $b ) } @versions ;
  die 'No stable source release available' unless @versions ;
  my $target_version = $args{to} // $versions[-1] ;
  die "Unknown target version $target_version" unless grep { $_ eq $target_version } @versions ;
  die "Unknown local version $version"         unless grep { $_ eq $version } @versions ;
  die "Local version $version is newer than target $target_version" if compare_versions( $version, $target_version ) > 0 ;
  $result->{version} = $target_version ;
  my ( $base_code, $base, $base_error ) = run_git( $args{source}, 'show', "v$version:AGENTS.md" ) ;
  die "Cannot read source version $version: $base_error" if $base_code ;
  my ( $target_code, $target, $target_error ) = run_git( $args{source}, 'show', "v$target_version:AGENTS.md" ) ;
  die "Cannot read target version $target_version: $target_error" if $target_code ;
  my $dir = tempdir( CLEANUP => 1 ) ;
  my ( $local_path, $base_path, $target_path ) = map {"$dir/$_"} qw(local base target) ;
  my $candidate = $target ;

  if ( $local ne $base ) {
    my $base_sections   = sections($base) ;
    my $local_sections  = sections($local) ;
    my $target_sections = sections($target) ;
    for my $title ( sort keys %{$base_sections} ) {
      next if exists $local_sections->{$title} ;
      if ( exists $target_sections->{$title} && $target_sections->{$title} ne $base_sections->{$title} ) {
        push @{ $result->{notes} }, "Ignored upstream changes in locally omitted section: $title" ;
      }
      $base   =~ s/\Q$base_sections->{$title}\E// ;
      $target =~ s/\Q$target_sections->{$title}\E// if exists $target_sections->{$title} ;
    }
    write_text( $local_path,  $local ) ;
    write_text( $base_path,   $base ) ;
    write_text( $target_path, $target ) ;
    my ( $merge_code, $merged, $merge_error ) = command( 'git', 'merge-file', '-p', '-L', 'LOCAL', '-L', "BASE v$version", '-L', "TARGET v$target_version", $local_path, $base_path, $target_path ) ;
    die "Cannot merge $path: $merge_error" if $merge_code > 127 ;
    if ($merge_code) {
      $result->{reason} = 'Concurrent upstream and project edits require manual review' ;
      my $line = 0 ;
      $result->{diff} = join '', map { sprintf( "%5d %s\n", ++$line, $_ ) } split /\n/, $merged ;
      return ;
    }
    $candidate = $merged ;
  }
  $result->{content} = $candidate ;
  $result->{status}  = $candidate eq $local ? 'unchanged' : 'update' ;
  write_text( $local_path,  $local ) ;
  write_text( $target_path, $candidate ) ;
  my ( $diff_code, $diff, $diff_error ) = command( 'git', 'diff', '--no-index', '--no-ext-diff', '--', $local_path, $target_path ) ;
  die "Cannot compare $path: $diff_error" if $diff_code > 1 ;
  $diff =~ s/\Q$local_path\E/\/AGENTS.md/g ;
  $diff =~ s/\Q$target_path\E/\/AGENTS.md/g ;
  $result->{diff} = $diff ;
}

sub update_file ($result) {
  die 'No automatic update available' unless $result->{status} eq 'update' ;
  my $path = $result->{path} ;
  die "File changed since analysis: $path" if -l $path || read_text($path) ne $result->{original} ;
  my @stat = stat($path) ;
  die "Cannot stat $path: $!" unless @stat ;
  my ( $fh, $temporary ) = tempfile( '.agents-update-XXXXXX', DIR => dirname($path), UNLINK => 1 ) ;
  close $fh or die "Cannot close temporary file: $!" ;
  write_text( $temporary, $result->{content} ) ;
  chmod( $stat[2] & oct('07777'), $temporary ) or die "Cannot preserve permissions for $path: $!" ;
  die "File changed since analysis: $path" if -l $path || read_text($path) ne $result->{original} ;
  rename( $temporary, $path ) or die "Cannot replace $path: $!" ;
  return ;
}

1 ;

=head1 NAME

Agents::Update - Preserve project adaptations when updating released guidelines

=head1 CONTRACT

C<analyze> reads a local file and tagged source models, returning an update,
unchanged result, or a manual-review report. It never writes the local file.
Locally omitted top-level sections remain omitted. Overlapping edits require
manual review of the complete file rather than a partial update.

C<update_file> atomically installs a successful proposal, preserving permissions
and rejecting changes made since analysis. The caller must enforce repository
eligibility and clean-working-tree checks before invoking it.

C<run_git> executes Git without a shell and returns exit code, UTF-8 stdout,
and UTF-8 stderr. All public text inputs and outputs are character strings.

=cut
