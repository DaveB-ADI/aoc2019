#!/usr/local/bin/perl -w

use strict;
use LWP::Simple;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$mon = $mon+1; $year = $year - 100;
if ($mon < 10) { $mon = "0" . $mon; }
if ($mday < 10) { $mday = "0" . $mday; }
if ($hour < 10) { $hour = "0" . $hour; }
if ($min < 10) { $min = "0" . $min; }
if ($sec < 10) { $sec = "0" . $sec; }
my $currentdate = "${year}${mon}${mday}_${hour}${min}${sec}";

my $htmlgraphdate = "${mon}${mday}$year";

########################################################################
# Parse date files and update summary data file
######### ###############################################################
open(INPUT, "<input.txt");

my $total;
my @letters;
my @test;
my $rel_base = 0;

#get input
foreach(<INPUT>) {
	chomp;
	my $id = $_;
	@letters = split(/,/, $id);
}

#Load Mem
@test = ();
my $idx = 0;
foreach my $val (@letters) {
  $test[$idx] = $letters[$idx];
  $idx++;
}

#Execute
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
  for (my $at=$len-3;$at>=0;$at--) { $mode[$cnt++] = $bits[$at];  }

  #Decode
  if (($a==1) or ($a==2) or ($a==7) or ($a==8) ) {
    $b = &get_value($mode[0], $addr+1);
    $c = &get_value($mode[1], $addr+2);
    if ($mode[2]=="2") { $d = $test[$addr+3] + $rel_base; }
    else               { $d = $test[$addr+3]; }
  } 
  elsif ($a==3) { 
    $step=2; 
    if ($mode[0]=="2") { $b = $test[$addr+1] + $rel_base; }
    else               { $b = $test[$addr+1]; }
  }
  elsif ($a==4) { $step=2; $b = &get_value($mode[0], $addr+1); }
  elsif ($a==9) { $step=2; $b = &get_value($mode[0], $addr+1); }
  else {
    $step = 3;
    $b = &get_value($mode[0], $addr+1);
    $c = &get_value($mode[1], $addr+2);
  }
 

  #Execute
  if ($a == 1) { $res = $b + $c; $test[$d] = $res;}
  if ($a == 2) { $res = $b * $c; $test[$d] = $res;}
  if ($a == 3) {
                  print "addr=$addr opcode=$opcode (@mode) $opcode2 $rel_base\n";
                  print "Value to store at $b: ";
                  $res = <STDIN>;
                  chomp $res;
		  $test[$b] = $res;
		  print "\n";
	  }
  if ($a == 4) { print "Output Code = $b \n"; }
  if ($a == 5) { return ($c) if ($b !=0); }
  if ($a == 6) { return ($c) if ($b ==0); }
  if ($a == 7) { if ($b < $c)  {$res = 1;} else {$res=0;} $test[$d] = $res; }
  if ($a == 8) { if ($b == $c) {$res = 1;} else {$res=0;} $test[$d] = $res;}
  if ($a == 9) { $res = $rel_base + $b; $rel_base = $res;}

  return $addr+$step; 

}

sub get_value {

	my $mode = shift;
	my $addr = shift;
	my $val;

	my $src_addr;

	if ($mode == "0") { $src_addr = $test[$addr]; }
	if ($mode == "1") { $src_addr = $addr; }
	if ($mode == "2") { $src_addr = $test[$addr] + $rel_base; }

	if (exists $test[$src_addr]) { $val = $test[$src_addr];}
	else { $val = 0; }

	return $val;
}


