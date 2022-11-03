#from snakemake.utils import min_version
#min_version("6.3.0")

configfile: "config/config.yaml"

pepfile: config["pepfile"]

include: "rules/common.smk"
include: "rules/qc.smk"
include: "rules/trimm.smk"
include: "rules/map_reads.smk"
include: "rules/reduce_reads.smk"
include: "rules/call_variants.smk"
include: "rules/create_antibiogram.smk"

rule all:
    input:
        "results/qc/multiqc/multiqc.html",
        "results/qc/trimmed/multiqc/multiqc.html",
        expand(
            "results/ABres/{sample}/ABres_{sample}.csv",         
            sample = get_samples(),
        ),
        expand(
            "results/qc/samtools_depth/{sample}/{sample}_coverage_summary.txt",            
            sample = get_samples(),
        ),        
        expand(
            "results/qc/samtools_depth/{sample}/loci_depth/depth_{loci}.txt",
            loci = get_gene_loci(),
            sample = get_samples(),
        ),