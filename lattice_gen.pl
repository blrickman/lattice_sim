#!/usr/bin/perl

use strict;
use warnings;

my $step = 1;
my ($xi,$xf) = (0,1000);
my ($yi,$yf) = (0,100);

my $debug = 0;
my $dec = 3;

sub func {
  my ($x,$y) = @_;
  my $func = $x + $y/1000;
  return $func unless $debug;
  return ($func,3*$x**2 * $y**4,4*$x**3 * $y**3);
}

open my $FH, "> lattice_$xi\_$xf\_$step\_$yi\_$yf\_$step.dat";

for my $x (-1..($xf-$xi)/$step+1) {
  $x = $xi + $x*$step;
  for my $y (-1..($yf-$yi)/$step+1) {
    $y = $yi + $y*$step;
     print $FH sprintf("%2.${dec}f", func($x,$y)) . ", ";
  }
  print $FH "\n";
}
