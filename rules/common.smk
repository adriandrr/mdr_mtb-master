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

def sep_fastqs(wildcards):  
    return pep.sample_table.loc[wildcards.sample]["fq1","fq2"]

def is_amplicon_data(sample):
    sample = pep.sample_table.loc[sample]
    try:
        return bool(int(sample["is_amplicon_data"]))
    except KeyError:
        return False

def get_adapters(wildcards):
    return "-a CTGTCTCTTATACACATCT -g AGATGTGTATAAGAGACAG"

def is_valid_organism():
    for org in pep.sample_table["organism"].values:
        if org in list(orgdf["alias"]):
            print("{} found".format(org))
        else:
            print("Organism not found, see list {}".format(list(orgdf["alias"])))
    return()

def get_depth_input(wildcards):
    if is_amplicon_data(wildcards.sample):
        # use clipped reads
        return "results/{date}/clipped-reads/{sample}.primerclipped.bam"
    # use trimmed reads
    amplicon_reference = config["adapters"]["amplicon-reference"]
    return "results/{{date}}/mapped/ref~{ref}/{{sample}}.bam".format(
        ref=amplicon_reference
    )

def get_bwa_index(wildcards):
    if wildcards.reference == "human" or wildcards.reference == "main+human":
        return rules.bwa_large_index.output
    else:
        return rules.bwa_index.output


def get_reads(wildcards):
    # alignment against the human reference genome is done with trimmed reads,
    # since this alignment is used to generate the ordered, non human reads
    if (
        wildcards.reference == "human"
        or wildcards.reference == "main+human"
        or wildcards.reference.startswith("polished-")
        or wildcards.reference.startswith("consensus-")
    ):

        illumina_pattern = expand(
            "results/{date}/trimmed/fastp-pe/{sample}.{read}.fastq.gz",
            read=[1, 2],
            **wildcards,
        )

    # theses reads are used to generate the bam file for the BAMclipper and the coverage plot of the main reference
    elif wildcards.reference == config["preprocessing"]["amplicon-reference"]:
        return get_non_human_reads(wildcards)

    # aligments to the references main reference genome,
    # are done with reads, which have undergone the quality control process
    else:
        return get_reads_after_qc(wildcards)