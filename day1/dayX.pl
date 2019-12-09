#!/usr/local/bin/perl -w

use strict;
use strict "vars";

########################################################################
# Parse date files and update summary data file
######### ###############################################################
open(INPUT, "<input.txt");

my $total;

foreach(<INPUT>) {

	chomp;
	my $id = $_;
	my @letters = split(//, $id);

	while ($id >=0)  {
	  my $cur = &fuel($id);
	  if ($cur >=0) { $total += $cur; }
	  $id = $cur;
  }

}

print "checksum = $total\n";

sub fuel {
	my $mass = shift;

	my $fuel = int($mass/3) - 2;

	print "$mass $fuel \n";

	return $fuel;
}



