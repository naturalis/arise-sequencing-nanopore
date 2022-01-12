#!/usr/bin/env bash

# this script will collect the fasta output files of NGSpeciesID
# so it has to be invoked after ngspid.sh in the same location.

[ -d out_sum ] && { printf "out_sum EXISTS !!! \nplease remove to continue\n"; exit 1; }
mkdir -p out_sum

# to do: reduce tmp files by piping output of find e.g.
# find . -type f -name "*.fasta" -print |  egrep -v "medaka" | cut -c 3-15
# use "tee" to save temp output, so the pipe doesn't end

# tmp_01.txt = list of paths to all fasta files
find . -type f -name "*.fasta" > out_sum/tmp_01.txt

# tmp_02.txt = list of paths to correct fasta files
cat out_sum/tmp_01.txt | egrep -v "medaka" > out_sum/tmp_02.txt

# tmp_03.txt = barcodes
cat out_sum/tmp_02.txt | cut -c 3-15 > out_sum/tmp_03.txt

# tmp_04.txt = extensions
cat out_sum/tmp_02.txt | awk -F"_" '{print "_"$3}' > out_sum/tmp_04.txt

# tmp_05.txt = new names
paste -d "" out_sum/tmp_03.txt out_sum/tmp_04.txt > out_sum/tmp_05.txt

# tmp_06.txt = add out location
awk '{print "out_sum/"$0}' out_sum/tmp_05.txt > out_sum/tmp_06.txt

# tmp_07.txt = location destination
paste -d " " out_sum/tmp_02.txt out_sum/tmp_06.txt > out_sum/tmp_07.txt

# tmp_08.txt = copy statement
awk '{print "cp "$0}' out_sum/tmp_07.txt > out_sum/tmp_08.txt

# copy files to out
cat out_sum/tmp_08.txt | while read -r i
do
    $i
done

# remove the tmp files
rm out_sum/*.txt

# remove the output files from ngspid.sh
# note: turned off by default, because ngspid.sh takes computation time
# and this script collects only part of the output

# rm *.out
