#!/usr/local/bin/perl -w

use strict;
use warnings;
########################################################################
# Parse date files and update summary data file
######### ###############################################################
open(INPUT, "<input.txt");

my @letters;

my %board;
my %steps;
my $cur_step;
my $wire_id = 0;
my $x;
my $y;
my $dir;
my $dist;

#get input
foreach(<INPUT>) {

	$x=0;
	$y=0;
	$wire_id++;
	$cur_step = 0;

	chomp;
	my $id = $_;
	@letters = split(/,/, $id);

	foreach my $move (@letters) { &move($move); }

	print "Done wire $wire_id\n";

}

sub move {
	my $move = shift;
	my $newx = $x;
	my $newy = $y;

	if ($move =~ /(\w)(\d*)/) {
          $dir = $1;
          $dist = $2;
          }

	while ($dist>0) {

          if    ($dir eq "D") { $newy = $y-1; }
          elsif ($dir eq "U") { $newy = $y+1; }
          elsif ($dir eq "R") { $newx = $x+1; }
          elsif ($dir eq "L") { $newx = $x-1; }

          if (exists ($board{$newx}{$newy}) and ($board{$newx}{$newy} ne $wire_id)) { $board{$newx}{$newy} = "X"; }
	  else                                                                      { $board{$newx}{$newy} = "$wire_id"; }

	  $cur_step++;
          if (exists ($steps{$wire_id}{$newx}{$newy})) { } #print "  -Been here before $newx $newy $cur_step\n";}
	  else                                         { $steps{$wire_id}{$newx}{$newy} = $cur_step; }

	  $x = $newx;
	  $y = $newy;
	  $dist--;
	}
}

my $result = 99999;
foreach my $cx (keys %board) {
  foreach my $cy (keys %{$board{$cx}}) {
    if ($board{$cx}{$cy} eq "X") { 
      print "Cross at $cx $cy = $steps{1}{$cx}{$cy} $steps{2}{$cx}{$cy} \n";
      if (($steps{1}{$cx}{$cy} + $steps{2}{$cx}{$cy}) < $result) { $result = $steps{1}{$cx}{$cy} + $steps{2}{$cx}{$cy}; print "Shortest = $result\n"; }
    }
  }
}

exit;
