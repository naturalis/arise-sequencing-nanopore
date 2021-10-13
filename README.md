# arise-sequencing-nanopore
## data description
This repository documents initial attempts to demultiplex and consensus call ONT (Oxford Nanopore Technology) pilot data.
The data are from a single Flongle run consisting of three datasets (marine 48 specimens, fungal 82 specimens and insect 61 specimens)
and were provided as a folder ([fastq_pass](https://drive.google.com/drive/u/1/folders/1b-3ZsvCA9DyMpFp9QCmAJBaPFgScnIY1)) containing 367 gzipped fastq files. 
The reason for creating this number of fastq.gz files seems to be a cut-off of thousand reads per file; BLAST searches on random reads of some of these
gzip files showed representatives of each of the three datasets (ie. the data still have to be demultiplexed). For the marine and insect
samples partial COI amplicons (~300 nt and ~658 nt, respectively) were used; the fungal samples consist of (variable length, non 
protein coding) ITS sequences (~700-900 nt). The total number of reads is 365.218

`cd fastq_pass`\
`zcat *.gz > Test_all.fastq`

## demultiplex options
[ONTbarcoder](https://github.com/asrivathsan/ONTbarcoder)\
[NGSpeciesID](https://github.com/ksahlin/NGSpeciesID)\
[Decona](https://github.com/Saskia-Oosterbroek/decona)\
ONTbarcoder does not seem to work without a GUI, making it a less suitable for scripting. It might be an option for temporary tests on
a standalone machine, but this solution is not scalable. ONTbarcoder worked with the provided [testdata](https://drive.google.com/drive/folders/1F-ojNW-gj2YL1vj8QXsuDxB1BAdZsw20) (DatasetA_mixed_Diptera), but gave no output with Test_all.fastq, nor with insect.fastq (see below). ONTbarcoder has been 
optimized for COI and is less suited for length variable non coding genes. InsectNGSpeciesID still needs to be tested; 
Pierre-Étienne is working on Decona. For now, to get things going, sorting is done in bash.

## demultipex datasets (bash)
Index and primer sequences are provided in Samplelist_metadata_nanopore. Basically the three datasets can be distinguished by their
forward index sequence and the within each dataset the amplicons ('specimens') can be distinguished based on the reverse index sequence.
Mind that the number of reverse index sequences is limited, so the same reverse indices will occur in each of the three datasets (ie. split
on dataset and then on amplicon). Most likely due to sequence errors, searching for the complete (including index) forward primer (length 36 nt)
retrieves only a limited number (76.601) of reads:

`grep -c "GGTAGAAGGCTGTATAAGTGTAAAACGACGGCCAGT\|ACTGGCCGTCGTTTTACACTTATACAGCCTTCTACC" Test_all.fastq`\
#insect  22.823\
`grep -c "GGTAGAACCATTCTCACCTGTAAAACGACGGCCAGT\|ACTGGCCGTCGTTTTACAGGTGAGAATGGTTCTACC" Test_all.fastq`\
#marine  19.893\
`grep -c "GGTAGAACCTGGAAGCCTTGTAAAACGACGGCCAGT\|ACTGGCCGTCGTTTTACAAGGCTTCCAGGTTCTACC" Test_all.fastq`\
#fungi   33.885

We assume that using only the forward index decreases the chance of incomplete matches due to sequence errors. The obvious downside is that 
the use of shorter search strings increases the chance of picking up false positives. Using only the forward indices (length 11 nt) retrieves about
half (177.617) of the total number of reads. The [output](https://drive.google.com/drive/folders/1zYL8aNuHByU2BTK5xHu8yUuSoyxTK69E?usp=sharing) was saved for each dataset:

`grep -B1 -A2 "GGCTGTATAAG\|CTTATACAGCC" Test_all.fastq | sed '/^--$/d' > insect.fastq`\
#insect  56.351\
`grep -B1 -A2 "CCATTCTCACC\|GGTGAGAATGG" Test_all.fastq | sed '/^--$/d' > marine.fastq`\
#marine  43.155\
`grep -B1 -A2 "CCTGGAAGCCT\|AGGCTTCCAGG" Test_all.fastq | sed '/^--$/d' > fungi.fastq`\
#fungi   78.111

## demultiplex amplicons ('specimens') within datasets (bash)
The shell script [retrieve_reads.sh]() will count the number of reads and create a fastq file for each reverse index sequence provided in the [rv_index file](https://github.com/naturalis/arise-sequencing-nanopore/tree/main/index_files) given the accompanying dataset ([insect.fastq, marine.fastq, fungi.fastq](https://drive.google.com/drive/folders/1zYL8aNuHByU2BTK5xHu8yUuSoyxTK69E?usp=sharing)).
A requirement for retrieve_reads.sh is the perl-scipt [rc.pl](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/scripts/rc.pl)(modified by ... from https://www.biostars.org/p/70319/) to enable searching for the reverse complement of the index sequence:

`./retrieve_reads.sh insect_rv_index.txt insect.fastq`

The retrieved read count is shown in this [table](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/metadata/Retrieved_reads.md) 
