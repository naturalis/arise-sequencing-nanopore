#!/usr/bin/env bash

# this script maps names to fasta-headers and filenames
# of output files from NGSpeciesID (as obtained with ngspid.sh)
# and should be run from within the output folder of the latter
# script (/out_sum)

# usage: index2header.sh $1 
# where $1 is the "index to name" file which for now is:
# name_code_index.txt
# this should be a two column tab delimeted file
# e.g.
# CCTCCAACCGCTG Andrena_spinigera___RMNH.INS.1092535___CCTCCAACCGCTG
# (index [tab] replacement header)

# create associative array based on $1
declare -A index_array
while read index name
do
    index_array[$index]=$name
done < $1

# create replacement loop
for fasta in $(ls -1 | grep "fasta$")
do
    fasta_index=$(echo $fasta | awk -F"_" '{print $1}')
    fasta_extension=$(echo $fasta | awk -F"_" '{print "_"$2}')
    consensus_number=$(echo $fasta_extension | sed 's/\.fasta//g')
# replace the fasta consensus headers
    sed 's/^>consensus.*reads/>consensus_reads/g' "$fasta" |
    sed "s/consensus/${index_array[$fasta_index]}$consensus_number/g" > "$fasta".tmp && mv "$fasta".tmp "$fasta"
# replace the fasta filename
    mv $fasta ${index_array[$fasta_index]}$fasta_extension
done
