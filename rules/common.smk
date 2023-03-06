import pandas as pd
from os import path
import csv
sys.path.append("scripts/")
import codpos_genidx as cg

configfile: "config/config.yaml"
#orgdf = pd.read_csv("resources/validorgs.csv")


def get_samples():
    return list(pep.sample_table["sample_name"].values)

def get_fastqs(wildcards):
    return pep.sample_table.loc[wildcards.sample][["fq1","fq2"]]

def get_reads(wildcards):  
    return "results/trimmed/{sample}.fastq"

def get_genome_name():
    return config["preprocessing"]["amplicon-ref-ver"]

def get_gene_loci():
    gene_pos = pd.read_csv("resources/gene_loci.csv" , header = 0)
    return gene_pos["gene"].tolist()

def get_gene_coordinates():
    gene_coordinate_dict = {}
    gene_loci_list = get_gene_loci()
    for i in gene_loci_list:
        gene_coordinate_dict[i] = [cg.find_gene_coords(i)[0],cg.find_gene_coords(i)[1]]
    return gene_coordinate_dict

def get_region(locus):
    genedict = get_gene_coordinates()
    return get_genome_name()+":"+str(genedict[locus][0])+"-"+str(genedict[locus][1])

def get_bwa_index_prefix(index_paths):
    return os.path.splitext(index_paths[0])[0]

def get_read_reduction():
    if config["reduce_reads"]["reducing"] == True:
        return config["reduce_reads"]["parameters"]
    if config["reduce_reads"]["reducing"] == False:
        return ["summary"]

wildcard_constraints:
    sample="[^/.]+"