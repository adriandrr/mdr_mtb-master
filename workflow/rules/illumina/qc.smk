rule fastqc:
    # The first applied rule, it performs a fastqc analysis with the given fastq input files
    input:
        get_illumina_fastqs,
    output:
        html="results/qc/fastqc/{sample}.html",
        zip="results/qc/fastqc/{sample}_fastqc.zip",
    log:
        "logs/qc/fastqc/{sample}.log",
    wrapper:
        "v1.14.1/bio/fastqc"


rule multiqc:
    # This rule performs a multiqc analysis with the given fastq input files, summarising fastqc results
    input:
        expand(
            "results/qc/fastqc/{sample}_fastqc.zip", sample=get_samples(),
        ),
    output:
        report(
            "results/qc/multiqc/multiqc.html",
            caption="../report/multiqc.rst",
            category="MultiQC",
            subcategory="Before trimming",
        ),
    log:
        "logs/qc/multiqc.log",
    wrapper:
        "v1.14.1/bio/multiqc"


rule fastqc_after_trim:
    # This rule performs a fastqc analysis with the given fastq input files after trimming
    input:
        "results/trimmed/{sample}_R1.fastq",
        "results/trimmed/{sample}_R2.fastq",
    output:
        html="results/qc/trimmed/fastqc/{sample}.html",
        zip="results/qc/trimmed/fastqc/{sample}_fastqc.zip",
    log:
        "logs/qc/trimmed/fastqc/{sample}.log",
    wrapper:
        "v3.4.1/bio/fastqc"


rule multiqc_after_trim:
    # This rule performs a multiqc analysis with the given fastq input files after trimming, summarising fastqc results
    input:
        expand(
            "results/qc/trimmed/fastqc/{sample}_fastqc.zip", sample=get_samples(),
        ),
    output:
        report(
            "results/qc/trimmed/multiqc/multiqc.html",
            caption="../report/multiqc.rst",
            category="MultiQC",
            subcategory="After trimming",
        ),
    log:
        "logs/qc/trimmed/multiqc.log",
    wrapper:
        "v3.4.1/bio/multiqc"