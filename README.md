# arise-sequencing-nanopore
## data description
This repository documents initial attempts to demultiplex and consensus call ONT (Oxford Nanopore Technology) pilot data.
Normally demultiplexing is done with [Guppy](https://community.nanoporetech.com/protocols/Guppy-protocol/v/gpb_2003_v1_revz_14dec2018/linux-guppy) (requires login to download) directly after basecalling. Because different indices were used than those from ONT, demultiplexing could not be done with Guppy.
The data are from a single Flongle run consisting of three datasets (insect 61 specimens, marine 48 specimens and fungal 82 specimens)
and were provided as a folder ([fastq_pass](https://drive.google.com/drive/u/1/folders/1b-3ZsvCA9DyMpFp9QCmAJBaPFgScnIY1)) containing 367 gzipped fastq files. 
The reason for creating this number of fastq.gz files seems to be a cut-off of thousand reads per file; BLAST searches on random reads of some of these
gzip files showed representatives of each of the three datasets (ie. the data still have to be demultiplexed). For the marine and insect
samples partial COI amplicons (~300 nt and ~658 nt, respectively) were used; the fungal samples consist of (variable length, non 
protein coding) ITS sequences (~700-900 nt). The total number of reads is 366.218

`cd fastq_pass`\
`zcat *.gz > Test_all.fastq`

## demultiplex options
[ONTbarcoder](https://github.com/asrivathsan/ONTbarcoder)\
[NGSpeciesID](https://github.com/ksahlin/NGSpeciesID)\
[Decona](https://github.com/Saskia-Oosterbroek/decona)\
ONTbarcoder does not seem to work without a GUI, making it less suitable for scripting. It might be an option for temporary tests on
a standalone machine, but this solution is not scalable. ONTbarcoder worked with the provided [testdata](https://drive.google.com/drive/folders/1F-ojNW-gj2YL1vj8QXsuDxB1BAdZsw20) (DatasetA_mixed_Diptera), but gave no output with Test_all.fastq, nor with insect.fastq (see below). ONTbarcoder has been 
optimized for COI and is less suited for length variable non coding genes. Likely because the variation within each sample was already very high for the pilot data, NGSpeciesID couldn't be used for demultiplexing, but can be used for [consensus calling](#consensus-calling-with-ngspeciesid) of demultiplexed samples. Decona is being tested by Pierre-Étienne. For now, to get things going, demultiplexing is done in bash.

## demultipex datasets (bash)
Index and primer sequences are provided in [Samplelist_metadata_nanopore](https://docs.google.com/spreadsheets/d/18Ms2JC2UmoVHpKIEy736SGRIA0DBC6dy/edit?usp=sharing&ouid=109237925768461347094&rtpof=true&sd=true). Basically the three datasets can be distinguished by their
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

We assume that using only the forward index decreases the number of incomplete matches due to sequence errors. The obvious downside is that 
the use of shorter search strings increases the chance of picking up false positives. Using only the forward indices (length 11 nt) retrieves about
half (177.617) of the total number of reads. The [output](https://drive.google.com/drive/folders/1zYL8aNuHByU2BTK5xHu8yUuSoyxTK69E?usp=sharing) was saved for each dataset:

`grep -B1 -A2 "GGCTGTATAAG\|CTTATACAGCC" Test_all.fastq | sed '/^--$/d' > insect.fastq`\
#insect  56.351\
`grep -B1 -A2 "CCATTCTCACC\|GGTGAGAATGG" Test_all.fastq | sed '/^--$/d' > marine.fastq`\
#marine  43.155\
`grep -B1 -A2 "CCTGGAAGCCT\|AGGCTTCCAGG" Test_all.fastq | sed '/^--$/d' > fungi.fastq`\
#fungi   78.111

## demultiplex amplicons ('specimens') within datasets (bash)
The shell script [retrieve_reads.sh](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/scripts/retrieve_reads.sh) will count the number of reads and create a fastq file for each reverse index sequence provided in the [rv_index file](https://github.com/naturalis/arise-sequencing-nanopore/tree/main/index_files) given the accompanying dataset ([insect.fastq, marine.fastq, fungi.fastq](https://drive.google.com/drive/folders/1zYL8aNuHByU2BTK5xHu8yUuSoyxTK69E?usp=sharing)).
A requirement of retrieve_reads.sh is the perl-scipt [rc.pl](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/scripts/rc.pl) (modified by ... from https://www.biostars.org/p/70319/) to enable searching for the reverse complement of the index sequence:

`./retrieve_reads.sh insect_rv_index.txt insect.fastq`

The retrieved read count (all datasets) is shown in this [table](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/metadata/Retrieved_reads.md).
The fastq files for each amplicon can be found [here](https://drive.google.com/drive/folders/1zYL8aNuHByU2BTK5xHu8yUuSoyxTK69E?usp=sharing).

## demultiplex summary
Total number of reads: 366.218
|Dataset|Specimens|Marker|Fw|Reads/   spec Fw|Fw Rv|Reads/  spec Fw Rv|Retrieved|Assigned|
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|insect|61|COI|56.351|924|15.904|261|4,3%|59|
|marine|48|COI|43.155|899|9.461|197|2,6%|46|
|fungi|82|ITS|78.111|953|33.321|406|9,1%|80|

**Fw** = retrieved reads based on only the forward index (demultiplex datasets)\
**Reads/spec Fw** = theoretical number of reads per dataset per specimen based on forward index\
**Fw Rv** = retrieved reads per dataset (Fw) for accompanying reverse indices (demultiplex amplicons)\
**Reads/spec Fw Rv** = theoretical nuber of reads per dataset per specimen based on both indices\
**Retrieved** = percentage of retrieved reads on total of reads\
**Assigned** = Specimens to which at least one read was assigned (will be much lower after length filter and NGSpeciesID)

Mind that the theoretical number of reads per specimen is based on averages. In practice the distributions range from\
0-1002, 0-836, 0-922 for insect, marine and fungal datasets, respectively.

![](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/images/Nanopore_boxplot.png)

*For the next steps we confined ourselves to the **insect dataset** because of unequivocal amplicon length combined with Sanger sequenced [reference data](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/metadata/insect_reference.fasta.txt)*

## trim reads prior to consensus calling
Filtering by length strongly reduces the number of clusters and improves [consensus calling with NGSpeciesID](#consensus-calling-with-ngspeciesid).\
Although the expected fragment length is ~658 nt, amplicon length should be ~800 nt (because of added index/adapter/primer length).\
For ease of use reads were trimmed in Galaxy with the Prinseq tool using paramters -min_len 750, -max_len 850.\
After trimming 42 of the 59 assigned reads were leftover.\
Note: retrieve_reads.sh will create a \*.fastq file for each index, regardless if reads were assigned to it.\
Remove empty fastq files (zero reads in [table](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/metadata/Retrieved_reads.md)) prior to using Prinseq.

## consensus calling with NGSpeciesID
From within the folder of trimmed reads [ngspid.sh](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/scripts/ngspid.sh) was used to run NGSpeciesID.sh with --ont (= --k 13 --w 20) and --medaka parameters on each fastq file. Subsequently [collect_fas.sh](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/scripts/collect_fas.sh) was used  to collect all output files (consensus fasta) and move them to a separate folder (out_sum).
This resulted in 38 consensus fasta files with 36 unique indices (ie. two instances of consensus sets with the same index).

## substitute index to taxon for fasta filename and consensus header
From within the /out_sum folder ([previous step](#consensus-calling-with-ngspeciesid)) run [index2header.sh](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/scripts/index2header.sh) and use [name_code_index.txt](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/index_files/name_code_index.txt) as positional argument (create new files for additional datasets; this one only codes for the insect dataset)

`./index2header.sh name_code_index.txt`

The consensus sequences can either be in forward or reverse complement orientation and still contain the sequencing primers, which represent a [cocktail of COI primers](https://docs.google.com/document/d/1ksfuHD4NOmXkHz1ZUdbrwhz9NWqLD_w_tctlplB7dHM/edit) in case of the insect dataset. Consensus sequences were correctly oriented by mapping against a correctly oriented (determined by location of the primers) sequence from within this dataset and the primersites were trimmed off using Geneious.\

The resulting [output file](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/metadata/insect_consensus.fas) has been added to the Arise [sequencing folder](https://drive.google.com/drive/u/0/folders/1b-3ZsvCA9DyMpFp9QCmAJBaPFgScnIY1).

## blast search consensus sequences
Blast searches were done against the insect.fas reference dataset using blastn in Galaxy. All sequences had 100% coverage and the average identity was 99,7%. A [summary of the blast results](https://github.com/naturalis/arise-sequencing-nanopore/blob/main/metadata/insect_blast.md) suggests something might have gone wrong with the indices in the wetlab. 

## remarks
By demultiplexing in a stepwise fashion (datasets -> amplicons), only the presence of index sequences is scored,
not the orientation of forward index in relation to reverse index. Some reads are much longer than expected, which suggests
the presence of chimeras. After correction, the number of retrieved reads is expected to be even lower than shown in
the table above. An improved version of the stepwise approach would be a single grep command, something like:

`egrep -B1 -A2 "fw_index .* rc_rev_index | rc_fw_index .* rev_index" Test_all.fastq` 

Due to the high error rate (which might be lowered by using an improved basecaller) demultiplexing by index/primer
sequence probably is not the best option (though other programms, e.g. ONTbarcoder, seem to use the same approach).
Another option might be to try to cluster the sequences a priori. This was tried using 'make OTU table' with minimum
abundance set to 3 reads (using DADA2 and Vsearch clustering methods on [Galaxy](https://galaxy.naturalis.nl/)), for 
Test_all.fastq as well as for insect.fastq, marine.fastq or fungi.fastq, to no avail.

