#!/usr/bin/perl
#
# modified by manabu 11.11.2011
#

use strict;
use LWP::Simple;

# my $pmid = shift;
#
# my $url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$pmid&retmode=text&rettype=medline";

my $baseurl = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi";

# my $MAX=1000;
# my ($MAX,$LIMIT)=(200,1000);
my ($MAX,$LIMIT)=(200,2000);

#
# process arguments
#
my (%pmids);
for my $arg (@ARGV) {
  if(-f $arg && open(fin,$arg)) {
    while(<fin>) {
      chomp;
      # push @pmids, $& if(/^\d+$/);
      $pmids{$1}++ if(/^\s*(?:PMID\s*)?(\d+)/);
    }
    close(fin);
  } elsif($arg=~/^\s*(?:PMID\s*)?(\d+)/) {
    # push @pmids, $&;
    my $id=$1;
    $pmids{$id}++;
  } else {
    printf(stderr "error: unexpected argument \"%s\"\n\n",$arg);
    exit(0);
  }
}

my @pmids=sort keys %pmids;

# printf(stderr "pmids: [%s]\n",join(":",@pmids));
# exit(0);

#
#
#
for(my $i=0; $i<@pmids && $i<$LIMIT; $i+=$MAX) {
  my $j=($#pmids < $i + $MAX - 1?$#pmids:$i + $MAX - 1);

  printf(stderr "%d..%d of %d",$i+1,$j+1,scalar(@pmids));
  # my $url=sprintf("%s?db=pubmed&retmode=text&rettype=medline&id=%s",$baseurl,join(",",@pmids));
  my $url=sprintf("%s?db=pubmed&retmode=text&rettype=medline&id=%s",$baseurl,join(",",@pmids[$i..$j]));
  # print $url;

  my $txt = get($url);
  die "error: failed\n$url\n\n" unless defined $txt;
  # print $txt;

  # exit(0);

  # my $filename = $pmid . "_abstract.txt";

  for my $record (split /\n\n/, $txt) {
    # printf("record:\n[%s]\n\n",$record);

    my ($label,%record) = ("UNKNOWN");
    for my $line (grep !/^\W*$/, split /\n/, $record) {
      # printf("line: %s\n\n",$line);
      if ($line =~ s/^(\S+)\s*- //) {
        $label=$1;
        push @{$record{$label}}, $line;
      } else { # if ($line =~ /^ {6}/) {
        $record{$label}[ $#{$record{$label}} ] .= "\n".$line;
        # $record{$label}[ $#{$record{$label}} ] .= " ".$line;
      # } else {
      # printf(stderr "error: unknown format.\n[%s]\n\n",$line);
      }
    }

    # for my $label (keys %record) {
    #   printf("label: %s\n",$label);
    #   for my $record (@{$record{$label}}) {
    #     printf("\t[[%s]]\n",substr($record,0,20));
    #   }
    # }

    if (! defined $record{PMID}) {
      printf(stderr "error: PMID is not defined.\n\n");
      exit;
    }

    for my $label (grep defined $record{$_}, ("PMID", "TI", "AB", "PT", "MH")) {
      for my $txt (@{$record{$label}}) {
        # $txt=~s/\s\s+/ /g; $txt=~s/^ | $//g;

        $txt=~s/\&/\&amp;/g;
        $txt=~s/\</\&lt;/g;    $txt=~s/\>/\&gt;/g;
        $txt=~s/\{/\&\#123;/g; $txt=~s/\}/\&\#125;/g;

        printf("%-4s- %s\n",$label,$txt);

        # printf("%s\n",$record{$label}[0]);
      }
    }

    printf("\n");
  }

  printf(stderr "\n");

  sleep(4) if($j<$#pmids);
}
