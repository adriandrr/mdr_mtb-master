# Copyright 2021 Thomas Battenfeld, Alexander Thomas, Johannes Köster.
# Licensed under the BSD 2-Clause License (https://opensource.org/licenses/BSD-2-Clause)
# This file may not be copied, modified, or distributed
# except according to those terms.


rule fastqc:
    input:
        get_fastqs,
    output:
        html="results/qc/fastqc/{sample}.html",
        zip="results/qc/fastqc/{sample}_fastqc.zip",
    log:
        "logs/qc/fastqc/{sample}.log",
    wrapper:
        "v1.14.1/bio/fastqc"


rule multiqc:
    input:
        expand(
            "results/qc/fastqc/{sample}_fastqc.zip",
            sample = get_samples(),
        ),
    output:
        "results/qc/multiqc/multiqc.html"
    log:
        "logs/qc/multiqc.log",
    wrapper:
        "v1.14.1/bio/multiqc"

rule fastqc_after_trim:
    input:
            "results/trimmed/{sample}_R1.fastq",
            "results/trimmed/{sample}_R2.fastq",
    output:
            html="results/qc/trimmed/fastqc/{sample}.html",
            zip="results/qc/trimmed/fastqc/{sample}_fastqc.zip",
    log:
        "logs/qc/trimmed/fastqc/{sample}.log",
    wrapper:
        "v1.14.1/bio/fastqc"


rule multiqc_after_trim:
    input:
        expand(
            "results/qc/trimmed/fastqc/{sample}_fastqc.zip",
            sample = get_samples(),
        ),
    output:
        "results/qc/trimmed/multiqc/multiqc.html"
    log:
        "logs/qc/trimmed/multiqc.log",
    wrapper:
        "v1.14.1/bio/multiqc"

rule samtools_depth:
    input:
        "results/mapped/{sample}.sorted.bam",
        "results/mapped/{sample}.sorted.bam.bai",
    output:
        "results/qc/samtools_depth/{sample}/loci_depth/depth_{loci}.txt",
    conda:
        "../envs/samtools.yaml",
    params:
        region=lambda wildcards: get_region(wildcards.loci),
    shell:
        "samtools depth -aH -r {params.region} -o {output} {input[0]}"

rule samtools_coverage:
    input:
        "results/mapped/{sample}.sorted.bam",
        "results/mapped/{sample}.sorted.bam.bai",
    output:
        temp("results/qc/samtools_depth/{sample}/tmp/coverage_{loci}.txt"),
    conda:
        "../envs/samtools.yaml",
    params:
        region=lambda wildcards: get_region(wildcards.loci),
    shell:
        "(samtools coverage -r {params.region} -o {output} {input[0]} &&"
        " sed -i 's/AL123456.3/{wildcards.loci}/' {output})"

rule samtools_summary:
    input:
        expand(
            "results/qc/samtools_depth/{{sample}}/tmp/coverage_{loci}.txt",
            loci = get_gene_loci(),
            sample = get_samples(),
        )
    output:
        "results/qc/samtools_depth/{sample}/{sample}_coverage_summary.txt",
    conda:
        "../envs/samtools.yaml",
    params:
        locus=get_gene_loci()
    shell:
        "cat {input} >> {output} ; "
        "echo -ne '\n' >> {output} ; "
        "sed -i '1!{{/^#rname/d;}}' {output}"
