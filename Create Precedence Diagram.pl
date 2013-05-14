#!/usr/bin/perl

open(IN, "lines.txt") || $!;
open(OUT,">recurse.txt") || $!;

my $count = 0;
while(<IN>) {
  chop;
  my (@field) = split(/\t/);
  my $area = shift(@field);
  (@field) = map {$_ if $_} @field;
  (@field) = map {"\"".$_."\""} @field;
  my $dest = shift(@field);
  $node{$dest}{$count++} = join("\t",@field);
}


my %track;

print OUT "digraph world {\n";
my $term = "\"Sustainability\"";
getsrc($term, 10);
print OUT "\n\n}";

close(OUT);

exit;

sub getsrc {
my ($dest, $count) = @_;
my @list;
return if $count == 0;
foreach ( values %{$node{$dest}}) {
  my (@field) = split(/\t/);
  my $mode = shift(@field); my $force = shift(@field);
  my $ref = shift(@field); my $source = shift(@field);
  getsrc($source, $count-1);
  my $line = "$source -> $dest";
  next if $track{$line};
  print OUT $line; $track{$line}++;
  $force =~ s/\'//g; $force =~ s/\"//g; $ref =~ s/\"//g;
  my $label = "$force  $ref";
  if ($label) {
    print OUT " [ label = \"$label\"]";
  }
  print OUT ";\n";
  print OUT "$dest [style=filled, color=",&map_colour($mode),"];\n"

}
}

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

sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}

