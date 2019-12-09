#!/usr/local/bin/perl -w

use strict;
########################################################################
# Parse date files and update summary data file
######### ###############################################################
open(INPUT, "<input.txt");

my $total;
my %orbits;
foreach(<INPUT>) {

	chomp;
	my $id = $_;
	my @letters = split(/\)/, $id);

	my $l1 = $letters[0]; #$1;
	my $l2 = $letters[1]; #$2;

	push @{$orbits{$l1}} , $l2;

}

my %yes;
my $cur_source;

#Walk for every source planet and save if connected to YOU or SAN
foreach my $pln (keys %orbits) {
  $cur_source = $pln;
  &orbit_count($pln,-1);

}

#
my $shortest = 999999;
foreach my $idx (keys %yes) {

	if ((exists $yes{$idx}{SAN}) and (exists $yes{$idx}{YOU})) {
		my $sum = $yes{$idx}{SAN} + $yes{$idx}{YOU};
		print "$idx has both $sum\n";
		$shortest = $sum if ($sum < $shortest);
	
	}
}


sub orbit_count {

	my $cur = shift;
	my $depth = shift;

	my $direct = 0;
	foreach my $plnt (@{$orbits{$cur}}) {

          $yes{$cur_source}{YOU} = $depth+1 if ($plnt eq "YOU");
	  $yes{$cur_source}{SAN} = $depth+1 if ($plnt eq "SAN");

	  &orbit_count($plnt, $depth+1);
          $direct++;
	}

	$total += $direct + $depth;
}

$total=1;
&orbit_count("COM",-1);
print "Total = $total and shortest = $shortest\n";
