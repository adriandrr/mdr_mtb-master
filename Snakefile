#from snakemake.utils import min_version
#min_version("6.3.0")

configfile: "config/config.yaml"

pepfile: config["pepfile"]

include: "rules/common.smk"
include: "rules/qc.smk"
#include: "rules/test.smk"
include: "rules/trimm.smk"
include: "rules/map_reads.smk"
include: "rules/call_variants.smk"

rule all:
    input:
        "results/qc/multiqc/multiqc.html",
        "results/qc/trimmed/multiqc/multiqc.html",
        expand(
            "results/variants/{sample}/loci_{loci}.vcf",
            sample = get_samples(),
            loci = get_gene_loci(),
        )