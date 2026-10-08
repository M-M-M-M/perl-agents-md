use strict ;
use warnings ;
use Test::More ;
use File::Temp qw(tempdir) ;
use File::Path qw(make_path) ;
use IPC::Open3 ;
use Symbol qw(gensym) ;
use lib 'lib' ;
use Agents::Update qw(run_git) ;

my $dir = tempdir( CLEANUP => 1 ) ;
my ( undef, $old )     = run_git( '.', 'show', 'v1.4.0:AGENTS.md' ) ;
my ( undef, $current ) = run_git( '.', 'show', 'v1.6.1:AGENTS.md' ) ;

sub fixture {
  my ( $name, $text ) = @_ ;
  my $root = "$dir/$name" ;
  make_path($root) ;
  my ($code) = run_git( $root, 'init', '-q' ) ;
  die 'Cannot initialize fixture' if $code ;
  open my $fh, '>:encoding(UTF-8)', "$root/AGENTS.md" or die 'Cannot write fixture' ;
  print {$fh} $text or die 'Cannot write fixture' ;
  close $fh         or die 'Cannot close fixture' ;
  return "$root/AGENTS.md" ;
}
my $update    = fixture( 'needs-update', $old ) ;
my $unchanged = fixture( 'current',      $current ) ;
my $manual    = fixture( 'unknown',      'Unidentified instructions' ) ;
my ( undef, $adapted ) = run_git( '.', 'show', 'v1.2.0:AGENTS.md' ) ;
$adapted =~ s/^# Discipline\n.*?(?=^# )//ms ;
my $warning = fixture( 'custom-warning', $adapted ) ;
my $missing = "$dir/missing/AGENTS.md" ;
my $outside = "$dir/AGENTS.md" ;
open my $fh, '>:encoding(UTF-8)', $outside or die 'Cannot write outside fixture' ;
print {$fh} $old or die 'Cannot write outside fixture' ;
close $fh        or die 'Cannot close outside fixture' ;
my $link = "$dir/link/AGENTS.md" ;
make_path("$dir/link") ;
symlink $update, $link or die 'Cannot create symlink fixture' ;
local $SIG{ALRM} = sub { die 'Report test timed out'  } ;
alarm 20 ;
my $error = gensym ;
local $ENV{GIT_CONFIG_COUNT}   = 1 ;
local $ENV{GIT_CONFIG_KEY_0}   = 'color.ui' ;
local $ENV{GIT_CONFIG_VALUE_0} = 'always' ;
my $pid = open3( my $input, my $output, $error, $^X, 'update-agents.pl', '--to', '1.6.1', $update, $unchanged, $manual, $warning, $missing, $outside, $link, '.', $update ) ;
close $input or die 'Cannot close input' ;
my $out = do { local $/ ; <$output>  } ;
my $err = do { local $/ ; <$error>  } ;
close $output or die 'Cannot close output' ;
close $error  or die 'Cannot close error' ;
waitpid( $pid, 0 ) ;
my $exit = $? >> 8 ;
alarm 0 ;
is( $exit, 1,  'mixed report preserves manual-review exit code' ) ;
is( $err,  '', 'report has no stderr errors' ) ;
like( $out, qr/Repository: needs-update\nTarget: \Q$update\E/, 'block names repository and complete target' ) ;
like( $out, qr/\[UPDATE\].*update/,                            'proposed changes have explicit label' ) ;
like( $out, qr/\[WARNING\].*upstream/,                         'missing upstream suggestion is a warning' ) ;
like( $out, qr/\[REVIEW\].*No identifiable version/,           'unidentified version has review label' ) ;
like( $out, qr/\[OK\].*unchanged/,                             'unchanged file has success label' ) ;
like( $out, qr/\[SKIP\].*source repository/,                   'source exclusion has skip label' ) ;
my ( undef, $summary ) = split /Summary\n/, $out, 2 ;
ok( defined $summary, 'summary follows all blocks' ) ;
like( $summary // '', qr/Repository \/ target\s*\|\s*Outcome\s*\|\s*Details/,                                              'table includes required columns' ) ;
like( $out, qr/Repository: custom-warning.*?\[WARNING\] Ignored upstream changes in locally omitted section: Discipline/s, 'adaptation warning is inside its repository block' ) ;
like( $summary // '', qr/\Q$warning\E\s*\|\s*Proposed\s*\|[^\n]*Ignored upstream changes.*Discipline/, 'successful proposal retains its warning in summary' ) ;

for my $pair ( [ $update, 'Proposed' ], [ $unchanged, 'Unchanged' ], [ $manual, 'Review required' ], [ $missing, 'Review required' ], [ $outside, 'Review required' ], [ $link, 'Review required' ], [ '.', 'Excluded' ] ) {
  like( $summary // '', qr/\Q$pair->[0]\E\s*\|\s*\Q$pair->[1]\E/, "summary attributes $pair->[1] to its target" ) ;
}
is( scalar( () = $out =~ /Repository: needs-update/g ), 1, 'duplicate target creates only one block' ) ;
unlike( $out, qr/\e\[/, 'redirected output contains no ANSI sequences' ) ;
my ( undef, $status ) = run_git( "$dir/needs-update", 'status', '--porcelain' ) ;
is( $status, "?? AGENTS.md\n", 'report does not apply or stage changes' ) ;
done_testing ;
