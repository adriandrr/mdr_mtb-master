# MYCRes

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
### Step 1: Obtain a copy of this workflow
Create a new github repository using this workflow [as a template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).
Clone the newly created repository to your local system, into the place where you want to perform the data analysis.

### Step 2: Setup database

For mutation database, the pointfinder_db database was used (Johnsen et al. 2019 - https://bitbucket.org/genomicepidemiology/pointfinder_db/src/master/).
To use this database, some changes were made. The changed database files are stored in a folder called database. Rename this folder to 'resources' to match the path configuration of the pipeline.
Also, here a file called 'gene_loci.csv' can be found. This file specifies the loci which shall be investigated by the pipeline. If some changes to investigated loci are to be made, the name of the new locus must be present in the resistens-overview.txt database file from pointfinder.

### Step 3: Setup data

After downloading the code, the FastQ files to be investigated can be moved to a folder in the same file structure as the Snakefile called data. 
The names of the samples as well as single single read names need to be written in samples.csv (/config/pep/samples.csv). If all reads should be considered, the config file (/config/config.yaml) parameter 'reducing' under reduce_reads should be “False".

### Step 4: Install snakemake

MYCRes is a snakemake-based workflow. Therefore, the installation of this package is necessary to start it. We used snakemake version 7.18.2 in a conda environment. For that we used:
```
conda create --name sm
conda activate sm
conda install -c bioconda snakemake
```

### Step 5: Install snakemake

Start the workflow with the command "snakemake --cores all --use-conda" when you are in the same file structure as the Snakefile. 
A snakemake report.html file is created automatically in the results folder.

## Output
As an output, an interactive graphic shows all found resistance-causing mutations and coverage details on the mutation and the gene locus.

![visualization](https://user-images.githubusercontent.com/95088942/203805733-2e8247f8-a7bf-455d-aec0-4f084ecef91e.png)
