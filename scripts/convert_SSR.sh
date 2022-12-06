#!/bin/bash

file=$1
filename=$(basename $file .fastq.gz)
R1=$(basename $file .fastq.gz)_R1.fastq
R2=$(basename $file .fastq.gz)_R2.fastq
echo "decompressing $filename"
gzip -dk $file
echo "separation of reads"
reformat.sh in=$(basename $file .fastq.gz).fastq  out1=$R1 out2=$R2
rm ${filename}.fastq
echo "configure header"
sed -i "s/${filename}\./${filename}:/g" $R1; sed -i "s/\..//g" $R1
sed -i "s/${filename}\./${filename}:/g" $R2; sed -i "s/\..//g" $R2
echo "compressing separated reads"
gzip $R1
gzip $R2