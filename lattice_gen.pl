#!/usr/bin/perl

use strict;
use warnings;

my $step = 0.1;
my $xlen = 2;
my $ylen = 2;

sub func {
  my ($x,$y) = @_;
  return $x**2 - $y*4;
}

open my $FH, "> lattice.dat";

for my $x (-$xlen/$step-1..$xlen/$step+1) {
  for my $y (-$ylen/$step-1..$ylen/$step+1) {
    print $FH (join (", ", ($x,$y,func($x,$y))) . "\n");
  }
  print $FH "\n";
}
