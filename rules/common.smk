from snakemake.utils import validate
import pandas as pd
from datetime import datetime
from os import path, getcwd, listdir

configfile: "config/config.yaml"

def get_samples():
    #print("get_samples:",list(pep.sample_table["sample_name"].values))
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

def get_recal_input(wildcards):
    if is_amplicon_data(wildcards.sample):
        # do not mark duplicates
        return "results/mapped/{sample}.bam"
    # use BAM with marked duplicates
    return "results/dedup/{sample}.bam"

def get_depth_input(wildcards):
    if is_amplicon_data(wildcards.sample):
        # use clipped reads
        return "results/{date}/clipped-reads/{sample}.primerclipped.bam"
    # use trimmed reads
    amplicon_reference = config["adapters"]["amplicon-reference"]
    return "results/{{date}}/mapped/ref~{ref}/{{sample}}.bam".format(
        ref=amplicon_reference
    )

def get_adapters(wildcards):
    return "-a CTGTCTCTTATACACATCT -g AGATGTGTATAAGAGACAG"

def get_trimmed_reads(wildcards):
    """Returns paths of files of the trimmed reads for parsing by kraken."""
    return get_list_of_expanded_patters_by_technology(
        wildcards,
        illumina_pattern=expand(
            "results/trimmed/{{sample}}.{read}.fastq.gz",
            read=[1, 2],
        ),
    )

def get_kraken_output(wildcards):
    """Returns the output of kraken on the raw reads, depend on sequencing technology."""
    return get_list_of_expanded_patters_by_technology(
        wildcards,
        illumina_pattern="results/species-diversity/{{sample}}/{{sample}}.uncleaned.kreport2".format(
            **wildcards
        ),
    )

def get_kraken_output_after_filtering(wildcards):
    """Returns the output of kraken on the filtered reads, depend on sequencing technology."""
    return get_list_of_expanded_patters_by_technology(
        wildcards,
        illumina_pattern="results/species-diversity-nonhuman/{{sample}}/{{sample}}.cleaned.kreport2".format(
            **wildcards
        ),
    )

def get_pattern_by_technology(
    wildcards,
    illumina_pattern=None,
    ont_pattern=None,
    ion_torrent_pattern=None,
    sample=None,
):
    """Returns the given pattern, depending on the sequencing technology used for the sample."""
    if sample is None:
        if is_illumina(wildcards):
            return illumina_pattern
        elif is_ont(wildcards):
            return ont_pattern
        elif is_ion_torrent(wildcards):
            return ion_torrent_pattern

    if is_illumina(None, sample):
        return illumina_pattern
    elif is_ont(None, sample):
        return ont_pattern
    elif is_ion_torrent(None, sample):
        return ion_torrent_pattern

    raise NotImplementedError(
        f'The technolgy listed for sample "{wildcards.sample}" is not supported.'
    )