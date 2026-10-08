package Agents::Report ;
use strict ;
use warnings ;
use feature 'signatures' ;
use Exporter 'import' ;
our @EXPORT_OK = qw(start_block event set_outcome print_summary) ;

sub start_block ( $target, $repository ) {
  print "\n", '=' x 72, "\nRepository: $repository\nTarget: $target\n", '-' x 72, "\n"
    or die "Cannot write repository block: $!" ;
  return { target => $target, outcome => 'Review required', details => '', warnings => [] } ;
}

sub event ( $row, $level, $message ) {
  $message =~ s/\s+\z// ;
  push @{ $row->{warnings} }, $message if $level eq 'WARNING' ;
  print "[$level] $message\n" or die "Cannot write report event: $!" ;
  return ;
}

sub set_outcome ( $row, $outcome, $details = '' ) {
  $row->{outcome} = $outcome ;
  $row->{details} = $details ;
  return ;
}

sub cell ($text) {
  $text =~ s/[\r\n\t]+/ /g ;
  $text =~ s/\|/\\|/g ;
  $text =~ s/\s+\z// ;
  return $text ;
}

sub print_summary ($rows) {
  my @table = ( [ 'Repository / target', 'Outcome', 'Details' ] ) ;
  for my $row ( @{$rows} ) {
    my @details = map { my $detail = $_ ; $detail =~ s/\r?\n.*//s ; $detail }
      grep {length} ( $row->{details}, @{ $row->{warnings} } ) ;
    push @table, [ map { cell($_) } ( $row->{target}, $row->{outcome}, join( '; ', @details ) ) ] ;
  }
  my @width = ( 0, 0, 0 ) ;
  for my $cells (@table) {
    for my $i ( 0 .. 2 ) { $width[$i] = length( $cells->[$i] ) if length( $cells->[$i] ) > $width[$i]  }
  }
  print "\n", '=' x 72, "\nSummary\n" or die "Cannot write summary heading: $!" ;
  for my $index ( 0 .. $#table ) {
    my @cells = @{ $table[$index] } ;
    print join( ' | ', map { sprintf( '%-*s', $width[$_], $cells[$_] ) } 0 .. 2 ), "\n"
      or die "Cannot write summary row: $!" ;
    if ( !$index ) {
      print join( '-+-', map { '-' x $_ } @width ), "\n" or die "Cannot write summary separator: $!" ;
    }
  }
  return ;
}

1 ;

=head1 NAME

Agents::Report - Attribute guideline update events and outcomes to each target

=head1 CONTRACT

C<start_block> prints a repository heading and returns its report row.
C<event> prints a labeled event and retains warnings for the final table.
C<set_outcome> records the actual final action and its diagnostic.
C<print_summary> prints one row per processed target, keeping paths complete
and flattening multiline details. Output is plain text without ANSI colors.
The caller supplies UTF-8 character strings and an encoded output stream.
Presentation never changes update policy or exit codes.

=cut
