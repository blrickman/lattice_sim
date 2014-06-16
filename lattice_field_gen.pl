#!/usr/bin/perl

use strict;
use warnings;
use PDL;

my $debug = 0;

my $fn = shift;
open my $FH, '<' . $fn  or die "Can't open file $fn: $!";
open my $OUT, '>' . "lattice_field.dat" or die $!;
open my $TEST, '>' . "compare_fields.dat" or die $! if $debug;

my %potential;
my %efield_d;

while (<$FH>) {
  next if $_ eq "\n";
  my ($z,$y,$V,$Ez,$Ey) = split ', ', $_;
  $potential{$z}{$y} = $V;
  $efield_d{$z}{$y}{z} = $Ez if $debug;
  $efield_d{$z}{$y}{y} = $Ey if $debug;
}

my @z = sort {$a <=> $b} keys %potential;
my @y = sort {$a <=> $b} keys %{$potential{$z[0]}};

for my $i (1..@z-2) {
  for my $j (1..@y-2) {
    my %efield;
    $efield{$z[$i]}{$y[$j]} = avg_div($i,$j);
    print $OUT join( ', ',($z[$i], $y[$j], $efield{$z[$i]}{$y[$j]}{z}, $efield{$z[$i]}{$y[$j]}{y})) . "\n";

    print $TEST join( ', ',($z[$i], $y[$j], $efield{$z[$i]}{$y[$j]}{z}-$efield_d{$z[$i]}{$y[$j]}{z}, $efield{$z[$i]}{$y[$j]}{y}-$efield_d{$z[$i]}{$y[$j]}{y})) . "\n" if $debug;
  }
  print $OUT "\n";
  print $TEST "\n" if $debug;
}

sub avg_div {
  my ($i,$j) = @_;
  my (@pz, @py);
  for ($i-1..$i+1) {
    $pz[$_-$i+1] = pdl ($z[$_], $potential{$z[$_]}{$y[$j]}, $z[$_]**2);
  }
  for ($j-1..$j+1) {
    $py[$_-$j+1] = pdl ($y[$_], $potential{$z[$i]}{$y[$_]}, $y[$_]**2);
  } 
  my $nz = crossp($pz[1] - $pz[0], $pz[2] - $pz[0]);
  my $ny = crossp($py[1] - $py[0], $py[2] - $py[0]);
  $nz /= -$nz->index(1);
  $ny /= -$ny->index(1);
  return { 
    'z' => 2 * $nz->index(2) * $z[$i] + $nz->index(0),
    'y' => 2 * $ny->index(2) * $y[$j] + $ny->index(0),
  }
}
