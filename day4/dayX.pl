#!/usr/local/bin/perl -w

use strict;
use warnings;
########################################################################
# Parse date files and update summary data file
######### ###############################################################
my $x = 123257;
my $y = 647015;
my @letters;
my $valid_cnt = 0;
for (my $cur=$x; $cur<=$y; $cur++) {

	@letters = split(//, $cur);
	my $length = scalar @letters;
	my $valid1 = 1;
	my $valid2 = 0;

	my %hash;
	for (my $idx=0; $idx<$length-1; $idx++) {
		$valid1 = 0 if ( $letters[$idx] > $letters[$idx+1]);
		$valid2 = 1 if ( $letters[$idx+1] eq $letters[$idx]);
		$hash{$letters[$idx]}++ if ( $letters[$idx+1] eq $letters[$idx]);
	}

	if (($valid1 ==1) and ($valid2==1)) {

	  my $val = 0;
	  foreach my $key (keys %hash){ 
		  if ($hash{$key} == 1) {
			  #print "$cur ACCEPTED for $key\n";
		    $val = 1;
		  }
	  }

	  if ($val == 1) {
			  $valid_cnt++;
			  #print "$cur $valid_cnt \n";
	  } 

	}

	#print "$cur $valid1 $valid2 \n";

}

print "$valid_cnt\n";
exit;
