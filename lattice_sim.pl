#!/usr/bin/perl

use strict;
use warnings;
use PDL;

open my $FH, '<' . "lattice_field.dat"  or die "Can't open directory: $!";
my %efield;
while (<$FH>) {
  next if $_ eq "\n";
  my ($z,$y,@efields) = split ', ', $_;
  $efield{$z}{$y} = \@efields;
}
my @z = sort {$a <=> $b} keys %efield;
my @y = sort {$a <=> $b} keys %{$efield{$z[0]}};

my $pos = pdl (.19,.19);

print join( ', ', get_efield($pos)) . "\n";

sub get_efield {
  my $pos = shift;
  my ($z, $y) = ( arr_map($pos->index(0),\@z), arr_map($pos->index(1),\@y) );
  return ($z,$y,$z + $y - floor($z) - floor($y) - 1);
}

sub arr_map {
  my ($pos, $array) = @_;
  my ($x0,$x1,$num) = ($$array[0],$$array[-1], scalar @$array-1);
  return $num*($pos-$x0)/($x1-$x0);
}
