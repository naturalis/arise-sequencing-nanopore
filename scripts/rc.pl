#!/usr/bin/perl
use strict;
my $dna=shift @ARGV;
my $rcdna= & reverse_complement_IUPAC($dna);
print "$rcdna\n";

# Modified from https://www.biostars.org/p/70319/
# To generate REVERSER COMPLEMENT DNA strings for 'missing value searches' e.g.
# GCGG(A|T|C|G)*TAA  -->  TTA(C|G|A|T)*CCGC
# for quick access: store in $PATH and set permissions to executable (chmod 777)
# usage: rc.pl "GCGG(A|T|C|G)*TAA"

sub reverse_complement_IUPAC {
        my $dna = shift;

        # reverse the DNA sequence
        my $revcomp = reverse($dna);
        # complement the reversed DNA sequence
        $revcomp =~ tr/ABCDGHMNRSTUVWXYabcdghmnrstuvwxy()/TVGHCDKNYSAABWXRtvghcdknysaabwxr)(/;
		# remove the * in front of (
        $revcomp =~ s/\*//;
		# reposition * behind )
		$revcomp =~ s/\)/\)\*/;
        return $revcomp;
}

