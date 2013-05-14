#!/usr/bin/perl

open(OUT, ">lines_out.txt") || $!;
open(IN,"lines.txt") || die $!;
print OUT "digraph world {\nrankdir=LR;\n";
my $count = 0;
while(<IN>) {
  chop;
  my (@field) = split(/\t/);
  my $area = shift(@field);
  (@field) = map {$_ if $_} @field;
  (@field) = map {"\"".$_."\""} @field;
  $cluster{$area}{$count++} = join("\t",@field);
}

foreach my $key1 (sort keys %cluster) {
  next unless $key1;
  print OUT "subgraph cluster_$key1 {\n";
  foreach my $key2 (sort keys %{$cluster{$key1}}) {
     my (@field) = split(/\t/,$cluster{$key1}{$key2});
     my $dest = shift(@field);
     my $mode = shift(@field);
     my $force = shift(@field);
     my $ref = shift(@field);
     my $source = shift(@field);
     if ($source || $ref) {
        goto label1 unless $source;
        print OUT "$source -> $dest";
        $force =~ s/\'//g; $force =~ s/\"//g;
        $ref =~ s/\"//g;
        my $label = "$force  $ref";
        if ($label) {
         print OUT " [ label = \"$label\"]";
        }
        print OUT ";\n";
     }
     label1:
     print OUT "$dest [style=filled, color=",&map_colour($mode),"];\n"

  }
  print OUT "label = \"$key1\"\n";
  print OUT "}\n\n";
}

print OUT "}\n";
close(IN);
close(OUT);

exit;

sub map_colour {
my $level = $_[0];
$level =~ s/\"//g;
if ($level eq "Good") {
  return "Green";
} elsif ($level eq "Bad") {
  return "Red";
} elsif ($level eq "Neutral") {
  return "Grey";
} else {
  return "White";
}
return "White";
}
