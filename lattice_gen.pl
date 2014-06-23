#!/usr/bin/perl

use strict;
use warnings;

my $step = 1;
my ($xi,$xf) = (-1,101);
my ($yi,$yf) = (-1,101);

my $debug = 0;
my $dec = 16;

sub func {
  my ($x,$y) = @_;
  my $func = $x**2/2 + $y**2/2000;
  return $func unless $debug;
  return ($func,3*$x**2 * $y**4,4*$x**3 * $y**3);
}

open my $FH, "> lattice_$xi\_$xf\_$step\_$yi\_$yf\_$step.dat";

for my $x (0..($xf-$xi)/$step) {
  $x = $xi + $x*$step;
  for my $y (0..($yf-$yi)/$step) {
    $y = $yi + $y*$step;
     print $FH sprintf("%2.${dec}f", func($x,$y)) . ", ";
  }
  print $FH "\n";
}
