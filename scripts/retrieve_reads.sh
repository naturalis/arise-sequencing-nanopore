#!/bin/bash

# usage: ./retrieve_reads.sh $1 $2

# requirements: rc.pl (perl script to reverse complement the input sequence)
# $1 = index file (text format, one line per index sequence)
# $2 = fastq file in which the reads containing the indices should be found

[ -f out/out."$1" ] && { printf "out/out.$1 EXISTS !!! \nplease remove to continue\n"; exit 1; }
mkdir -p out/demultiplexed

for i in $(cat $1)
do
    first=$(echo $i)
    second=$(rc.pl $i)
    hits=$(egrep -c "$first|$second" $2)
    printf "$i\t$hits\n" >> out/out."$1"
    egrep -B1 -A2 "$first|$second" $2 | sed '/^--$/d' > out/demultiplexed/"$first".fastq
done
