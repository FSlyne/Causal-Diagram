#!/usr/bin/perl

open(IN, "lines.txt") || $!;
open(OUT,">recurse_count.txt") || $!;

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

my $maxlevel = 4;
my %track;
my $term;
foreach my $dest (sort keys %node) {
  $term = $dest;
  getsrc($term, 4);
}

foreach my $key1 (sort keys %track) {
  my $count = 0;
  print OUT $key1,"\t";
  foreach my $key2 (sort keys %{$track{$key1}}) {
    $count += $track{$key1}{$key2};
    print OUT $key2,"(".$track{$key1}{$key2}.")","\t";
  }
  print OUT "\t$count\n";
}

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
  $track{$term}{$count}++;
}
}

