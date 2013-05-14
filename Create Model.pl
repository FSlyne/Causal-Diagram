#!/usr/bin/perl

open(OUT,">model.txt") || die $!;
my $n = 0;
open(IN,"lines.txt") || die $!;
while(<IN>) {
  chop;
  my ($area,$dest,$mode,$force,$ref, $source) = split(/\t/);
  $link{$source}{$n} = $dest;
  $force{$source}{$n} = $force;
  $n++;
  $sep{$dest}++;
}
close(IN);

foreach my $source (keys %sep) {
  if (!$link{$source}) {
    $link{$source}{$n} = "AAA";
    $force{$source}{$n} = "\'+";
  $n++;
  }
}


my %set = ( "Economic Policy", 10, "Available Land for Biomass Crops",-10);
my $set = 0;
foreach my $source (keys %set) {
  $value{$source}{$set} = $set{$source};
  &getsrc($source, $set);
  $set++;
}

foreach my $source (sort keys %value) {
  my $val=0; my $count =0;
  foreach my $set (sort keys %{$value{$source}}) {
    $val += $value{$source}{$set}; $count++;
  }
  $val{$source} = sprintf("%.2f",$val/$count) if $count > 0;
}

foreach my $source (sort {$val {$b} <=> $val {$a}} keys %val) {
  print $val{$source},"\t",$source,"\n" if $source !~ /AAA/i;
}

exit;


foreach my $source (sort keys %value) {
  foreach my $set (sort values %{$value{$source}}) {
    my $value =  $value{$source}{$set};
    print $set, "\t", $value,"\t",$source,"\n" if !$value == 0;
  }
}

exit;

my $max_scen = 2; my $max_t = 100;

for (my $scen=0; $scen<$max_scen; $scen++) {
# seed variable for t=0;
my $t = 0;
foreach my $source (sort keys %link) {
   $value{$scen}{$source}{$t} = 0;
   foreach my $n (sort keys %{$link{$source}}) {
      $value{$scen}{$link{$source}{$n}}{$t} = 0;
   }
}
#
# Set initial indept variables for Scenarios

# Scenario 1
if ($scen == 0) {
  $value{$scen}{"Economic Policy"}{$t} = 1;
} elsif ($scen == 1) {
  $value{$scen}{"Growth of Biomass"}{$t} = 1;
  $value{$scen}{"Available Land for Biomass Crops"}{$t} = -1;
}

# iterate through variables for changes
for ($t=$t; $t < $max_t; $t++) {
  my $delta = 0;
  foreach my $dest (sort keys %link) {
    $value{$scen}{$dest}{$t+1} = $value{$scen}{$dest}{$t};
    foreach my $n (sort keys %{$link{$dest}}) {
       $value{$scen}{$dest}{$t+1} += calc_value($value{$scen}{$link{$dest}{$n}}{$t+1}, $force{$dest}{$n});
    }
    $delta += $value{$scen}{$dest}{$t+1}-$value{$scen}{$dest}{$t};
  }
} # End of step iteration
} # End of Scenario iteration

# print out the final values
foreach my $dest (sort keys %link) {
  for (my $scen=0; $scen<$max_scen; $scen++) {
    my $ret = sprintf("%.2f",$value{$scen}{$dest}{$max_t});
    print OUT $ret,"\t";
  }
  print OUT $dest;
  print OUT "\n";
}

close(OUT);

exit;

sub getsrc {
my ($source, $set) = @_;
my $value = $value{$source}{$set};
print "$source, $set\n" if $debug;
foreach my $n( sort keys %{$link{$source}}) {
  my $dest = $link{$source}{$n};
#  next if $set{$dest};
  my $force = $force{$source}{$n};
  my $newvalue = calc_value($value,$force);
  my $oldvalue =  $value{$dest}{$set};
  print ">>> $source $dest $force $value\n" if $debug;
  if (!$oldvalue) {
    $value{$dest}{$set} = $newvalue;
  } else {
    $value{$dest}{$set} = ($oldvalue + $newvalue)/2;
  }
  getsrc($dest, $set);
}
}

sub calc_value {
my ($val, $force) = @_;
$force =~ s/\'//g;
my $mult = 0;
if ($force eq "+") {
  $mult = 0.1;
} elsif ($force eq "++") {
  $mult = 1;
} elsif ($force eq "+++") {
  $mult = 10
} elsif ($force eq "++++") {
  $mult = 100
} elsif ($force eq "+++++") {
  $mult = 1000
} elsif ($force eq "-") {
  $mult = -0.1;
} elsif ($force eq "--") {
  $mult = -1;
} elsif ($force eq "---") {
  $mult = -10
} elsif ($force eq "----") {
  $mult = -100
} elsif ($force eq "-----") {
  $mult = -1000
}
return $val*$mult;
}
