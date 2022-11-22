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
include: "rules/create_depth_profile.smk"
include: "rules/create_html.smk"

rule all:
    input:
        "results/qc/multiqc/multiqc.html",
        "results/qc/trimmed/multiqc/multiqc.html",
        expand(
            "results/plots/{sample}/resistance-coverage.html",        
            sample = get_samples(),
        ),
        expand(
            "results/qc/samtools_depth/{sample}/{sample}_coverage_summary.html",            
            sample = get_samples(),
        )