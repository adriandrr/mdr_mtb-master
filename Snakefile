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

if config["reduce_reads"]["reducing"] == False:
    rule all:
        input:
            "results/qc/multiqc/multiqc.html",
            "results/qc/trimmed/multiqc/multiqc.html",
            expand(
                "results/html/{sample}_resistance-coverage.html",        
                sample = get_samples(),
            ),
            expand(
                "results/html/{sample}_coverage_summary.html",            
                sample = get_samples(),
            )

if config["reduce_reads"]["reducing"] == True:
    rule all:
        input:
            "results/qc/multiqc/multiqc.html",
            "results/qc/trimmed/multiqc/multiqc.html",
            expand(
                "results/html/{sample}_resistance-coverage.svg",        
                sample = get_samples(),
            ),
            expand(
                "results/html/{sample}_coverage_summary.html",            
                sample = get_samples(),
            )