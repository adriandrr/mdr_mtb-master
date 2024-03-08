import pandas as pd
from os import path
import pathlib
import csv

sys.path.append("workflow/scripts")
df_path = "config/pep/sample_info.txt"
samples_df = pd.read_csv(df_path)
import codpos_genidx as cg


configfile: "config/config.yaml"


def get_samples():
    if config["sequencing"] == "illumina":    
        return list(pep.sample_table["sample_name"].values)
    if config["sequencing"] == "ont":
        names = samples_df["names"]
        return names.tolist()

def get_illumina_fastqs(wildcards):
    return pep.sample_table.loc[wildcards.sample][["fq1", "fq2"]]


def get_reads(wildcards):
    return "results/trimmed/{sample}.fastq"


def get_genome_name():
    return config["preprocessing"]["amplicon-ref-ver"]


def get_gene_loci():
    gene_pos = pd.read_csv("resources/gene_loci.csv", header=0)
    return gene_pos["gene"].tolist()


def get_gene_coordinates():
    gene_coordinate_dict = {}
    gene_loci_list = get_gene_loci()
    for i in gene_loci_list:
        gene_coordinate_dict[i] = [cg.find_gene_coords(i)[0], cg.find_gene_coords(i)[1]]
    return gene_coordinate_dict


def get_region(locus):
    genedict = get_gene_coordinates()
    return (
        get_genome_name()
        + ":"
        + str(genedict[locus][0])
        + "-"
        + str(genedict[locus][1])
    )


def get_bwa_index_prefix(index_paths):
    return os.path.splitext(index_paths[0])[0]

wildcard_constraints:
    sample="[^/.]+",
