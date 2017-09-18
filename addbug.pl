#!/usr/bin/env perl
use strict;
use warnings;

use File::Basename qw( dirname );
use File::Spec::Functions qw( rel2abs catfile );
use constant MY_PWD => dirname(rel2abs(__FILE__));

my ( $package, $bug ) = @ARGV;

if ( not $package or $package !~ /\d\z/ or $package !~ qr{/} ) {
  $package = "(undef)" unless defined $package;
  die "$package is not an atom with a version and CAT/PN format";
}
if ( not $bug or $bug !~ /\A\d+\z/ ) {
  $bug = "(undef)" unless defined $bug;
  die "$bug is not a bug number";
}
my ( $cat, $pnv ) = split q[/], $package; 
if ( not -e catfile( MY_PWD , $cat ) ) {
  die "No such category directory $cat in " . MY_PWD;
}
my $source_file = catfile( MY_PWD, 'last.sh' );
my $target_file = "$cat/$pnv-$bug";
{
  open my $ifh, "<", $source_file or die "Can't read $source_file, $!";
  open my $ofh, ">", $target_file or die "Can't write to $target_file, $!";
  while ( my $line = <$ifh> ) {
    $line =~ s{\Aexport\s*BUG=.*$}{export BUG=$bug};
    print $ofh $line;
  }
}
system('git', '-C', MY_PWD, "add", $target_file );
system('git','commit', '-m', "Add $cat/$pnv #$bug\n\nBug: https://bugs.gentoo.org/$bug");
