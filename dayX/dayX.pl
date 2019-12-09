#!/usr/local/bin/perl -w

use strict;
########################################################################
# Parse date files and update summary data file
######### ###############################################################
open(INPUT, "<input.txt");

my %ids;
my $id_cnt;
my %counts;
my $twocount;
my $threecount;

foreach(<INPUT>) {

	my $flag2 = 0;
	my $flag3 = 0;
	undef %counts;
	chomp;
	my $id = $_;
	my @letters = split(undef, $id);

	push @{$ids{$id_cnt++}} , @letters;

	foreach my $letter (@letters) {
		$counts{$letter}++;
	}

	foreach my $check (keys %counts) {
		if ($counts{$check} == 2) { $flag2 = 1; }
                if ($counts{$check} == 3) { $flag3 = 1; }
	}

	$twocount++ if ($flag2);
	$threecount++ if ($flag3);

}

my $checksum = $twocount * $threecount;
print "checksum = $twocount * $threecount = $checksum\n";

foreach my $cnt1 (keys %ids) {
  foreach my $cnt2 (keys %ids) {

	  my $idx = 0;
	  my $diff_cnt = 0;

	  while ($idx < scalar @{$ids{$cnt1}}) { 
		  my @arr1 = @{$ids{$cnt1}};
                  my @arr2 = @{$ids{$cnt2}};
            $diff_cnt++ if ($arr1[$idx] ne $arr2[$idx]);
	    $idx++;
          }

	  if ($diff_cnt == 1) {
	    print "$cnt1 @{$ids{$cnt1}} \n";
            print "$cnt2 @{$ids{$cnt2}} \n";
          }
  }

}


