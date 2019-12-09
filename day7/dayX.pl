#!/usr/local/bin/perl -w

use strict;
########################################################################
# Parse date files and update summary data file
######### ###############################################################
open(INPUT, "<input.txt");

my @letters;
my %test;
my %amp_settings;
my $largest = 0;

#get input
foreach(<INPUT>) {
	chomp;
	my $id = $_;
	@letters = split(/,/, $id);
}


my $found = 0;
my $comb = 56789;
my $cur_amp = 0;
my $cur_input = 0;

while ($comb <= 98765) {

  if (($comb =~ "9") and ($comb =~ "8") and ($comb =~ "7") and ($comb =~ "6") and ($comb =~ "5") ) {

	  &check_setting($comb);
  }

  $comb++;
}

#reset program in each of the 5 amplifiers
sub reset_prog {
 %test = {};

 for( my $amp=0;$amp<5;$amp++) {
   my $idx = 0;
    foreach my $val (@letters) {
      push @{$test{$amp}} , $letters[$idx];
      $idx++;
    }
  }
}


sub check_setting {
  
  my $comb = shift;

  my @phases = split(//, $comb);

  $cur_amp   = 0;
  $cur_input = 1;
  $amp_settings{$comb}{0}{2} = 0;

  $amp_settings{$comb}{0}{pc} = 0; $amp_settings{$comb}{0}{1} = $phases[0]; $amp_settings{$comb}{0}{cur_input} = 1; $amp_settings{$comb}{0}{writeto} = 3;
  $amp_settings{$comb}{1}{pc} = 0; $amp_settings{$comb}{1}{1} = $phases[1]; $amp_settings{$comb}{1}{cur_input} = 1; $amp_settings{$comb}{1}{writeto} = 2;
  $amp_settings{$comb}{2}{pc} = 0; $amp_settings{$comb}{2}{1} = $phases[2]; $amp_settings{$comb}{2}{cur_input} = 1; $amp_settings{$comb}{2}{writeto} = 2;
  $amp_settings{$comb}{3}{pc} = 0; $amp_settings{$comb}{3}{1} = $phases[3]; $amp_settings{$comb}{3}{cur_input} = 1; $amp_settings{$comb}{3}{writeto} = 2;
  $amp_settings{$comb}{4}{pc} = 0; $amp_settings{$comb}{4}{1} = $phases[4]; $amp_settings{$comb}{4}{cur_input} = 1; $amp_settings{$comb}{4}{writeto} = 2;
  &reset_prog();

  print "\n-----------------------------\nChecking comb = $comb\n";
  my $done = 0;

  while (!$done) {

    my $pc     = $amp_settings{$comb}{$cur_amp}{pc};
    my $opcode = $test{$cur_amp}[ $pc ];

    #print "cur_amp $cur_amp pc=$pc opcode=$opcode\n";
    if (($opcode == 99)) {
      print "Done with Amp $cur_amp\n";
      $cur_amp++;
      if ($cur_amp ==5) { $done = 1;} 
    } else {
      $cur_amp = &execute_opcode($pc);
    }
  }

  if ($amp_settings{$comb}{result} > $largest) { $largest = $amp_settings{$comb}{result}; }
}


#Opcode execution
sub execute_opcode {

  my $addr = shift;
  my $res;
  my $opcode = $test{$cur_amp}[$addr];
  my @mode = (0,0,0,0,0);
  my $step = 4;
  my $next_amp;

  my @bits = split(//, $opcode);
  my $len = scalar @bits;

  my $a = $bits[$len-1];
  my $b;
  my $c;
  my $d;

  my $cnt=0;
  for (my $at=$len-3;$at>=0;$at--) { $mode[$cnt++] = $bits[$at];}

  if (($a==1) or ($a==2) or ($a==7) or ($a==8) ) {
    if ($mode[0]eq"1") { $b = $test{$cur_amp}[$addr+1] } else { $b = $test{$cur_amp}[$test{$cur_amp}[$addr+1]]; }
    if ($mode[1]eq"1") { $c = $test{$cur_amp}[$addr+2] } else { $c = $test{$cur_amp}[$test{$cur_amp}[$addr+2]]; }
    $d = $test{$cur_amp}[$addr+3];
  } 
  elsif ($a==3) { $b = $test{$cur_amp}[$addr+1]; } 
  elsif ($a==4) { if ($mode[0]eq"1") { $b = $test{$cur_amp}[$addr+1] } else { $b = $test{$cur_amp}[$test{$cur_amp}[$addr+1]]; } }
  else {
    $step = 3;
    if ($mode[0]eq"1") { $b = $test{$cur_amp}[$addr+1] } else { $b = $test{$cur_amp}[$test{$cur_amp}[$addr+1]]; }
    if ($mode[1]eq"1") { $c = $test{$cur_amp}[$addr+2] } else { $c = $test{$cur_amp}[$test{$cur_amp}[$addr+2]]; }
  }
 

  if ($a == 1) { $res = $b + $c;  $test{$cur_amp}[$d] = $res;}
  if ($a == 2) { $res = $b * $c;  $test{$cur_amp}[$d] = $res;}
  if ($a == 3) {
	          my $cur_input = $amp_settings{$comb}{$cur_amp}{cur_input};
	          if (exists $amp_settings{$comb}{$cur_amp}{$cur_input}) {
		    $step = 2;
		    $res = $amp_settings{$comb}{$cur_amp}{$cur_input};
		    $test{$cur_amp}[$b] = $res;
		    $amp_settings{$comb}{$cur_amp}{cur_input}++;
	          } 
		  else { $next_amp=1; }
  }
  if ($a == 4) { 
    $step = 2; 

    my $next = 0;
    if ($cur_amp == 4) { $next = 0; }
    else               { $next = $cur_amp + 1;}

    my $writeto = $amp_settings{$comb}{$next}{writeto};
    $amp_settings{$comb}{$next}{ $writeto} = $b;
    $amp_settings{$comb}{$next}{writeto}++;

    print "Amp $cur_amp Output = $b To Amp $next at Writeto $writeto\n"; 
    if ($cur_amp == 4) {
	    print "$comb Total = $b\n"; 
	    $amp_settings{$comb}{result} = $b;
    }
  }
    
    
  if ($a == 5) { 
    if ($b !=0) {
      $amp_settings{$comb}{$cur_amp}{pc} = $c;
      return($cur_amp);
    } 
  }
  if ($a == 6) { 
    if ($b ==0) {
      $amp_settings{$comb}{$cur_amp}{pc} = $c;
      return($cur_amp);
    }
  }
  if ($a == 7) { if ($b < $c)  {$res = 1} else {$res=0} ; $test{$cur_amp}[$d] = $res; }
  if ($a == 8) { if ($b == $c) {$res =1;} else {$res=0} ; $test{$cur_amp}[$d] = $res;}


   if ($next_amp) {
	   if ($cur_amp ==4) { return 0; }
	   else              { return ($cur_amp+1); }
   } else {
     $amp_settings{$comb}{$cur_amp}{pc} = $addr + $step;
     return $cur_amp; 
   }

}

print "checksum = $largest\n";

