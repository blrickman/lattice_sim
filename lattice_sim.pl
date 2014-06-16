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
my $fields = @{$efield{$z[0]}{$y[0]}};

my $pos = pdl (.150, 0.2);

get_efield($pos);

sub get_efield {
  my $pos = shift;
  my $dir = 0;
  my ($ez, $ey) = ( arr_grab($pos->index(0),\@z), arr_grab($pos->index(1),\@y) );
  my $line_test = $pos->index(0) + ($pos->index(1) * ($$ey[0]-$$ey[1]) + ($$ez[1]*$$ey[1]-$$ez[0]*$$ey[0])) / ($$ez[0] - $$ez[1]);
  my @points;
  for my $i (0..1) {
    $points[$i] = pdl ($$ez[!$i], $$ey[$i],$efield{$$ez[!$i]}{$$ey[$i]}[$dir]);
  }
  $points[2] = pdl ($$ez[0], $$ey[0],$efield{$$ez[0]}{$$ey[0]}[$dir]);
  if (sprintf "%.14f", $line_test > 0) {
    $points[2] = pdl ($$ez[1], $$ey[1],$efield{$$ez[1]}{$$ey[1]}[$dir]);
  }
  my $plane = crossp($points[0]-$points[2],$points[1]-$points[2]);
  $plane /= $plane->index(2);
  print inner($plane,$points[2]) - inner($plane,pdl ($pos->index(0),$pos->index(1),0));

}

sub arr_map {
  my ($pos, $array) = @_;
  my ($x0,$x1,$num) = ($$array[0],$$array[-1], scalar @$array-1);
  return $num*($pos-$x0)/($x1-$x0);
}

sub arr_grab {
  my ($pos, $array) = @_;
  my $step = $$array[1] - $$array[0];
  my @return = grep $_ >= $pos - $step, grep $_ <= $pos + $step, @$array;
  push @return, $return[0] + $step if @return == 1;
  shift @return if @return == 3;
  die "I grabbed " . @return . " elemtents when I only meant to grab 2: $!" if @return != 2;
  return \@return;
}
