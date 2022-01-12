#!/usr/bin/env bash

# requirement: NGSpeciesID and accompanying conda env
# https://github.com/ksahlin/NGSpeciesID

# eval statement prevents conda activate from erroring out
eval "$(conda shell.bash hook)"
conda activate NGSpeciesID

for i in *.fastq
do
    NGSpeciesID --ont --fastq $i --outfolder "$i".out --consensus --medaka
done

conda deactivate
