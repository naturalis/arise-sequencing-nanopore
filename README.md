# arise-sequencing-nanopore
## data description
This repository documents initial attempts to demultiplex and consensus call ONT (Oxford Nanopore Technology) pilot data.
The data are from a single Flongle run consisting of three datasets (marine 48 specimens, fungal 82 specimens and insect 61 specimens)
and were provided as one zip folder (fastq_pass-20210927T115415Z-001.zip) containing 367 gzipped fastq files. The reason for creating
this number of fastq.gz files seems to be a cut-off of thousand reads per file; BLAST searches on random reads of some of these
gzip files showed representatives of each of the three datasets (ie. the data still have to be demultiplexed). For the marine and insect
samples partial COI amplicons (~300 nt and ~658 nt, respectively) were used; for the fungal samples consist of (variable length, non 
protein coding) ITS sequences (~700-900 nt). The total number of reads is 365.218

`unzip fastq_pass-20210927T115415Z-001.zip`\
`cd fastq_pass`\
`zcat *.gz > Test_all.fastq`

## demultiplex options
[ONTbarcoder](https://github.com/asrivathsan/ONTbarcoder)
[NGSpeciesID](https://github.com/ksahlin/NGSpeciesID)
[Decona](https://github.com/Saskia-Oosterbroek/decona)
ONTbarcoder does not seem to work without a GUI, making it a less suitable for scripting. It might be an option for temporary tests on
a standalone machine, but this solution is not scalable. ONTbarcoder worked with the provided [testdata](https://drive.google.com/drive/folders/1F-ojNW-gj2YL1vj8QXsuDxB1BAdZsw20) (DatasetA_mixed_Diptera), but gave no output with our testdata (Test_all.fastq). NGSpeciesID still needs to be tested; 
Pierre-Étienne is working on Decona. For now, to get things going, sorting is done in bash.

## demultipex datasets (bash)
Index and primer sequences are provided in Samplelist_metadata_nanopore. Basically the three datasets can be distinguished by their
forward index sequence and the within each dataset the amplicons ('specimens') can be distinguished based on the reverse index sequence.
Mind that the number of reverse index sequences is limited, so the same reverse indices will occur in each of the three datasets (ie. split
on dataset and then on amplicon). Most likely due to sequence errors, searching for the complete (including index) forward primer (length 36 nt)
retrieves only a limited number (76.601) of reads:\
`grep -c "GGTAGAAGGCTGTATAAGTGTAAAACGACGGCCAGT\|ACTGGCCGTCGTTTTACACTTATACAGCCTTCTACC" Test_all.fastq`\
#insect  22.823\
`grep -c "GGTAGAACCATTCTCACCTGTAAAACGACGGCCAGT\|ACTGGCCGTCGTTTTACAGGTGAGAATGGTTCTACC" Test_all.fastq`\
#marine  19.893\
`grep -c "GGTAGAACCTGGAAGCCTTGTAAAACGACGGCCAGT\|ACTGGCCGTCGTTTTACAAGGCTTCCAGGTTCTACC" Test_all.fastq`\
#fungi   33.885

We assume that using the forward index only decreases the chance of incomplete match due to sequence errors. Using the forward indices
(length 11 nt) retrieves about half (177.617) of the total number of reads. The output was saved for each dataset:\
`grep -B1 -A2 "GGCTGTATAAG\|CTTATACAGCC" Test_all.fastq | sed '/^--$/d' > insect.fastq`\
#insect  56.351\
`grep -B1 -A2 "CCATTCTCACC\|GGTGAGAATGG" Test_all.fastq | sed '/^--$/d' > marine.fastq`\
#marine  43.155\
`grep -B1 -A2 "CCTGGAAGCCT\|AGGCTTCCAGG" Test_all.fastq | sed '/^--$/d' > fungi.fastq`\
#fungi   78.111

## demultiplex amplicons (within datasets)
