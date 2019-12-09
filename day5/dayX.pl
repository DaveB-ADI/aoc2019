#!/usr/local/bin/perl -w

use strict;
########################################################################
# Parse date files and update summary data file
######### ###############################################################
open(INPUT, "<input.txt");
my @letters;
my @test;

#get input
foreach(<INPUT>) {
	chomp;
	my $id = $_;
	@letters = split(/,/, $id);
}

#set program
@test = ();
my $idx = 0;
foreach my $val (@letters) {
  $test[$idx] = $letters[$idx];
  $idx++;
}

#Run
my $loc=0;
while($test[$loc] != 99) {
  my $next;
  $next = &execute_opcode($loc);
  $loc = $next;
}	


#Opcode execution
sub execute_opcode {

  my $addr = shift;
  my $res;
  my $opcode = $test[$addr];
  my $opcode2 = $test[$addr+1];
  my @mode = (0,0,0,0,0);
  my $step = 4;

  my @bits = split(//, $opcode);
  my $len = scalar @bits;

  my $a = $bits[$len-1];
  my $b;
  my $c;
  my $d;

  my $cnt=0;
  for (my $at=$len-3;$at>=0;$at--) { $mode[$cnt++] = $bits[$at]; }

  print "addr=$addr opcode=$opcode (@mode) $opcode2\n";

  if (($a==1) or ($a==2) or ($a==7) or ($a==8) ) {
    if ($mode[0]eq"1") { $b = $test[$addr+1] } else { $b = $test[$test[$addr+1]]; }
    if ($mode[1]eq"1") { $c = $test[$addr+2] } else { $c = $test[$test[$addr+2]]; }
    $d = $test[$addr+3];
  } 
  elsif ($a==3) { $b = $test[$addr+1]; } 
  elsif ($a==4) { if ($mode[0]eq"1") { $b = $test[$addr+1] } else { $b = $test[$test[$addr+1]]; } }
  else {
    $step = 3;
    if ($mode[0]eq"1") { $b = $test[$addr+1] } else { $b = $test[$test[$addr+1]]; }
    if ($mode[1]eq"1") { $c = $test[$addr+2] } else { $c = $test[$test[$addr+2]]; }
  }
 
  if ($a == 1) { $res = $b + $c; $test[$d] = $res;}
  if ($a == 2) { $res = $b * $c; $test[$d] = $res;}
  if ($a == 3) {
	          $step = 2;
                  print "Value to store at $b: ";
                  $res = <STDIN>;
                  chomp $res;
		  $test[$b] = $res;
		  print "\n";
	  }
  if ($a == 4) { 
    $step = 2; 
    print "Output Code = $b \n";
    if ($b !=0) { exit; } 
  }
  if ($a == 5) { return($c) if ($b !=0); }
  if ($a == 6) { return($c) if ($b ==0); }
  if ($a == 7) { if ($b < $c)  {$res = 1} else {$res=0} ; $test[$d] = $res; }
  if ($a == 8) { if ($b == $c) {$res =1;} else {$res=0} ; $test[$d] = $res;}

  return $addr+$step; 

}

print "checksum = $letters[0]\n";
