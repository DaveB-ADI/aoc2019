#!/usr/local/bin/perl -w

use strict;
########################################################################
# Parse date files and update summary data file
######### ###############################################################
open(INPUT, "<input.txt");

my $wide = 25;
my $tall = 6;
my $layer = 1;

my $curx = 0;
my $cury = 0;
my %image;

foreach(<INPUT>) {

	chomp;
	my $id = $_;
	my @letters = split(//, $id);

	foreach my $pixel(@letters) {

		$image{$layer}{$curx}{$cury} = $pixel;

		if ($pixel == 0) {$image{$layer}{count0}++;}
                if ($pixel == 1) {$image{$layer}{count1}++;}
                if ($pixel == 2) {$image{$layer}{count2}++;}

		$curx++;

		$cury++  if ($curx==$wide);
		$layer++ if ($cury==$tall);

		$curx=0  if ($curx==$wide);
		$cury=0  if ($cury==$tall);
	}	

  }

$curx=0; 
$cury=0;
while ($cury<$tall){
  $curx = 0;
  while ($curx<$wide) {
    $layer=1;
    my $found = 0;
    while (!$found) {
      if ($image{$layer}{$curx}{$cury} != 2) {
        print "$image{$layer}{$curx}{$cury}";
	$found = 1;
      } else { $layer++; }
    }
    $curx++;
  }
  print "\n";
  $cury++;

}
