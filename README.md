# Mdr_mtb-master (working title)

This snakemake-based pipeline is for predicting antibiotic resistance in Mycobacterium tuberculosis.

## Background
The tuberculosis disease caused by mycobacterium tuberculosis is still a global concern. 
To approach the emerging problem of upcoming resistant strains, various diagnostic methods are needed.
Here, we present a pipeline capable of predicting mycobacteria resistances in an OS-independent, reproducible way.

## Structure

![mdrmtbworkflow](https://user-images.githubusercontent.com/95088942/203801407-31fec80a-f628-45ef-a9aa-372e6e7f2256.png)

## Input
- FastQ files of mycobacterium tuberculosis
- The pointfinder database
- A table of gene loci to be investigated (names must be similar to the pointfinder DB)
- Several parameters in the config file
- A samples table, where the name of the sample and forward and reverse FastQ files are shown (see config/pep/samples.csv)

## Usage
After downloading the code, the FastQ files can be moved to a folder in the same file structure as the Snakefile called data. 
The names of the samples need to be written in samples.csv. If all reads should be considered, the config file parameter reducing under reduce_reads should be “False".

Start the workflow with the command "snakemake -cores all --use-conda" when you are in the same file structure as the Snakefile. 
To sum the essential results in a HTML file, use "snakemake --report" after the workflow is finished.

## Output
As an output, an interactive graphic shows all found resistance-causing mutations and coverage details on the mutation and the gene locus.

![visualization](https://user-images.githubusercontent.com/95088942/203805733-2e8247f8-a7bf-455d-aec0-4f084ecef91e.png)
