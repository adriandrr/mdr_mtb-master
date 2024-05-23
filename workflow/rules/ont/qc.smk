rule fastp:
    input:
        fastq="resources/data/{sample}.fastq"
    output:
        trimmed_fastq="results/fastp/{sample}_fp_trimmed.fastq",
        html_report="results/fastp/{sample}_fastp.html",
        json_report="results/fastp/{sample}_fastp.json"
    params:
        quality = config['samtools_q_flag']
    log:
        "logs/fastp/{sample}.log"
    conda:
        "../../envs/analysis_env.yaml"
    shell:
        "fastp -i {input.fastq} -o {output.trimmed_fastq} -h {output.html_report} -j {output.json_report} -q {params.quality}"

rule fastqc_after_fastp:
    # This rule performs a fastqc analysis with the given fastq input files after trimming
    input:
        "results/fastp/{sample}_fp_trimmed.fastq",
    output:
        html="results/qc/trimmed/fastqc/{sample}.html",
        zip="results/qc/trimmed/fastqc/{sample}_fastqc.zip",
    log:
        "logs/qc/trimmed/fastqc/{sample}.log",
    wrapper:
        "v3.4.1/bio/fastqc"


rule multiqc_after_fastp:
    # This rule performs a multiqc analysis with the given fastq input files after trimming, summarising fastqc results
    input:
        expand(
            "results/qc/trimmed/fastqc/{sample}_fastqc.zip", sample=get_samples(),
        ),
    output:
        report(
            "results/qc/trimmed/multiqc/multiqc.html",
            caption="../../report/multiqc.rst",
            category="MultiQC",
            subcategory="After trimming",
        ),
    log:
        "logs/qc/trimmed/multiqc.log",
    wrapper:
        "v3.4.1/bio/multiqc"