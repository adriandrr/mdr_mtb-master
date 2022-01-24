rule trimmomatic:
    input:
        expand("results/qc/fastqc/{sample}_fastqc.zip",sample=get_samples()),
    output:
        "results/qc/multiqc.html"
    params:
        ""  # Optional: extra parameters for multiqc.
    log:
        "logs/multiqc.log"
    wrapper:
        "v0.86.0/bio/multiqc"