#from snakemake.utils import min_version
#min_version("6.3.0")

configfile: "config/config.yaml"

pepfile: config["pepfile"]

include: "rules/common.smk"
include: "rules/qc.smk"
#include: "rules/test.smk"
include: "rules/trimm.smk"

#expand("results/trimmed/{sample}_R1_001.fastq.gz","results/trimmed/{sample}_R2_001.fastq.gz" , sample = get_samples())

rule all:
    input:
            "results/qc/multiqc/multiqc.html",
            "results/qc/trimmed/multiqc/multiqc.html"
