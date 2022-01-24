#from snakemake.utils import min_version

#min_version("6.3.0")

configfile: "config/config.yaml"

pepfile: config["pepfile"]

rule all:
    input:
        "results/qc/multiqc.html"


include: "rules/common.smk"
include: "rules/qc.smk"