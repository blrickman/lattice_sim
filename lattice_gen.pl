#!/usr/bin/perl

use strict;
use warnings;

my $step = 0.1;
my $xlen = 1;
my $ylen = 1;

my $debug = 0;

sub func {
  my ($x,$y) = @_;
  my $func = $x * $y;
  return $func unless $debug;
  return ($func,3*$x**2 * $y**4,4*$x**3 * $y**3);
}

open my $FH, "> lattice.dat";

for my $x (-$xlen/$step-1..$xlen/$step+1) {
  $x *= $step;
  for my $y (-$ylen/$step-1..$ylen/$step+1) {
    $y *= $step;
    print $FH (join (", ", ($x,$y,func($x,$y))) . "\n");
  }
  print $FH "\n";
}
