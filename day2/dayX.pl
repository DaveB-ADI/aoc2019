#!/usr/local/bin/perl -w

use strict;

########################################################################
# Parse date files and update summary data file
######### ###############################################################
open(INPUT, "<input.txt");

my $total;
my @letters;
my @test;

#get input
foreach(<INPUT>) {
	chomp;
	my $id = $_;
	@letters = split(/,/, $id);
}


my $found = 0;
my $noun = 12;
my $verb = 2;
while (!$found) {

  @test = ();

  my $idx = 0;
  foreach my $val (@letters) {
    $test[$idx] = $letters[$idx];
    $idx++;
  }

  $test[1] = $noun;
  $test[2] = $verb;

  my $loc=0;
  my $res;

  while($test[$loc] != 99) {
    &execute_opcode($loc);
    $loc +=4;
  }	

  if ($test[0] == 19690720) {$found = 1;} 

  print "$noun $verb $test[0]\n";

  $noun++;
  if ($noun == 100) { 
    $verb++;
    exit if ($verb == 100) ;
    $noun=0;
    $verb=0 if ($verb == 100);
  }
}

#Opcode execution
sub execute_opcode {

  my $addr = shift;
  my $res;
  my $a = $test[$addr];
  my $b = $test[$addr+1];
  my $c = $test[$addr+2];
  my $d = $test[$addr+3];


  if ($a == 1) { $res = $test[$b] + $test[$c]; }
  if ($a == 2) { $res = $test[$b] * $test[$c]; }
		
  $test[$d] = $res;

}


print "checksum = $letters[0]\n";

