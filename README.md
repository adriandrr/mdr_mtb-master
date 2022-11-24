# Mdr_mtb-master (working title)

This snakemake based pipeline is for predicting antibiotic resistances in mycobacterium tuberculosis.

## Background
The tuberculosis disease caused by mycobacterium tuberculosis is still a global concern. 
To approach the emerging problem of upcoming resistant strains, a variety of diagnostic methods is needed.
Here, we present a pipeline capable of predicting mycobacteria resistances in a OS independent, reproducable way.

## Structure

![mdrmtbworkflow](https://user-images.githubusercontent.com/95088942/203801407-31fec80a-f628-45ef-a9aa-372e6e7f2256.png)

## Input
- FastQ files of mycobacterium tuberculosis
- The pointfinder database
- A table of gene loci to be investigated (names must be similar as in the pointfinder db)
- 
