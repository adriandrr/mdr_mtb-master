from snakemake.utils import validate
import pandas as pd
from datetime import datetime
from os import path, getcwd, listdir
import csv

configfile: "config/config.yaml"
orgdf = pd.read_csv("resources/validorgs.csv")


def get_samples():
    return list(pep.sample_table["sample_name"].values)

def get_fastqs(wildcards):
    return pep.sample_table.loc[wildcards.sample][["fq1","fq2"]]

def get_reads(wildcards):  
    return "results/trimmed/{sample}.fastq"

def is_amplicon_data(sample):
    sample = pep.sample_table.loc[sample]
    try:
        return bool(int(sample["is_amplicon_data"]))
    except KeyError:
        return False

def get_adapters(wildcards):
    return "-a CTGTCTCTTATACACATCT -g AGATGTGTATAAGAGACAG"

def get_gene_loci():
    gene_loci_list = []
    for file in os.listdir("/homes/adrian/mdr_mtb-master/resources/pointfinder_db/mycobacterium_tuberculosis"):
        if file.endswith(".fsa"):
            gene_loci_list.append(os.path.splitext(file)[0])
    print(gene_loci_list)
    print(get_samples())
    return gene_loci_list

#def is_valid_organism():
#    for org in pep.sample_table["organism"].values:
#        if org in list(orgdf["alias"]):
#            print("{} found".format(org))
#        else:
#            print("Organism not found, see list {}".format(list(orgdf["alias"])))
#    return()

def get_bwa_index_prefix(index_paths):
    return os.path.splitext(index_paths[0])[0]
