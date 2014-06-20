#!/usr/bin/perl

use strict;
use warnings;
use PDL;
use Tie::File;
use Time::HiRes qw/gettimeofday tv_interval/;

my $t0 = [gettimeofday];

my $debug = 0;

my $fn = shift;
my (undef,$zi,$zf,$zs,$yi,$yf,$ys) = split '_', $fn;
$ys =~ s/\.\w+$//;

tie my @datafile, 'Tie::File', $fn  or die "Can't open file $fn: $!";

open my $FIELDZ, '>' . "fieldz-" . $fn or die $!;
open my $FIELDY, '>' . "fieldy-" . $fn or die $!;
open my $TEST, '>' . "compare_fields.dat" or die $! if $debug;

my $z_rows = ($zf-$zi)/$zs;
my $y_cols = ($yf-$yi)/$ys;  

for my $i (1..$z_rows-1) {
  for my $j (1..$y_cols-1) {
    my ($Ez,$Ey) = ij_Ezy($i,$j);
    print $FIELDZ sprintf("%.16f", $Ez) . ", ";
    print $FIELDY sprintf("%.16f", $Ey) . ", ";
  }
  print $FIELDZ "\n";
  print $FIELDY "\n";
}
print tv_interval ( $t0 ) . "\n";

sub zy_pot {
  return ij_pot(zy_ij(@_));
}

sub ij_pot {
  my ($i,$j) = @_;
  my @row = split ', ', $datafile[$i];
  return $row[$j];
}

sub ij_zy {
  my ($i,$j) = @_;
  return ($zi + $zs*$i, $yi + $ys*$j);
}

sub zy_ij {
  my ($z, $y) = @_;
  return (int ($z-$zi)/$zs, int ($y-$yi)/$ys);
}

sub ij_Ezy {
  my ($i,$j) = @_;
  my ($z,$y) = ij_zy($i,$j);
  my (@pz, @py);
  for ($i-1..$i+1) {
    my ($z,$y) = ij_zy($_,$j);
    $pz[$_-$i+1] = pdl ($z, ij_pot($_,$j), $z**2);
  }
  for ($j-1..$j+1) {
    my ($z,$y) = ij_zy($i,$_);
    $py[$_-$j+1] = pdl ($y, ij_pot($i,$_), $y**2);
  } 
  my $nz = crossp($pz[1] - $pz[0], $pz[2] - $pz[0]);
  my $ny = crossp($py[1] - $py[0], $py[2] - $py[0]);
  $nz /= $nz->index(1);
  $ny /= $ny->index(1);
  return (2 * $nz->index(2) * $z + $nz->index(0), 2 * $ny->index(2) * $y + $ny->index(0))
}

__END__

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
