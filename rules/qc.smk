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

rule samtools_flagstat:
    input:
        "results/recal/ref~main/{names}.bam",
    output:
        "results/qc/samtools_flagstat/{names}.bam.flagstat",
    log:
        "logs/samtools/{names}_flagstat.log",
    wrapper:
        "0.70.0/bio/samtools/flagstat"

"""
rule samtools_depth:
    input:
        get_depth_input,
    output:
        "results/qc/samtools_depth/{names}.txt",
    log:
        "logs/samtools/{names}_depth.txt",
    conda:
        "../envs/samtools.yaml"
    params:
        ref=config["preprocessing"]["amplicon-reference"],
    shell:
        "(samtools depth -aH -o {output} {input} && "
        " sed -i 's/{params.ref}.3/{wildcards.sample}/' {output})"
        " 2> {log}"
"""

# analysis of species diversity present BEFORE removing human contamination
rule species_diversity_before:
    input:
        db="resources/minikraken-8GB",
        reads=expand("results/trimmed/{{names}}.{read}.fastq.gz", read=[1, 2]),
    output:
        classified_reads=temp(
            expand(
                "results/species-diversity/{{names}}/{{names}}_{read}.classified.fasta",
                read=[1, 2],
            )
        ),
        unclassified_reads=temp(
            expand(
                "results/species-diversity/{{names}}/{{names}}_{read}.unclassified.fasta",
                read=[1, 2],
            )
        ),
        kraken_output=temp("results/species-diversity/{names}/{names}.kraken"),
        report="results/species-diversity/{names}/{names}.uncleaned.kreport2",
    log:
        "logs/kraken/{names}.log",
    params:
        classified=lambda w, output: "#".join(
            output.classified_reads[0].rsplit("_1", 1)
        ),
        unclassified=lambda w, output: "#".join(
            output.unclassified_reads[0].rsplit("_1", 1)
        ),
    threads: 8
    conda:
        "../envs/kraken.yaml"
    shell:
        "(kraken2 --db {input.db} --threads {threads} --unclassified-out {params.unclassified} "
        "--classified-out {params.classified} --report {output.report} --gzip-compressed "
        "--paired {input.reads} > {output.kraken_output}) 2> {log}"


# plot Korna charts BEFORE removing human contamination
rule create_krona_chart:
    input:
        kraken_output=(
            "results/species-diversity/{names}/{names}.uncleaned.kreport2"
        ),
        taxonomy_database="resources/krona/",
    output:
        "results/species-diversity/{names}/{names}.html",
    log:
        "logs/krona/{names}.log",
    conda:
        "../envs/kraken.yaml"
    shell:
        "ktImportTaxonomy -m 3 -t 5 -tax {input.taxonomy_database} -o {output} {input} 2> {log}"


rule combine_references:
    input:
        "resources/genomes/main.fasta",
        "resources/genomes/human-genome.fna.gz",
    output:
        "resources/genomes/main-and-human-genome.fna.gz",
    log:
        "logs/combine-reference-genomes.log",
    conda:
        "../envs/unix.yaml"
    shell:
        "zcat -f {input} > {output}"


# filter out human contamination
rule extract_reads_of_interest:
    input:
        "results/mapped/ref~main+human/{names}.bam",
    output:
        temp("results/mapped/ref~main+human/nonhuman/{names}.bam"),
    log:
        "logs/extract_reads_of_interest/{names}.log",
    params:
        reference_genome=config["bacterium-reference-genome"],
    conda:
        "../envs/python.yaml"
    script:
        "../scripts/extract-reads-of-interest.py"


rule order_nonhuman_reads:
    input:
        "results/mapped/ref~main+human/nonhuman/{names}.bam",
    output:
        fq1=temp("results/nonhuman-reads/{names}.1.fastq.gz"),
        fq2=temp("results/nonhuman-reads/{names}.2.fastq.gz"),
        bam_sorted=temp("results/nonhuman-reads/{names}.sorted.bam"),
    log:
        "logs/order_nonhuman_reads/{names}.log",
    conda:
        "../envs/samtools.yaml"
    threads: 8
    shell:
        "(samtools sort  -@ {threads} -n {input} -o {output.bam_sorted}; "
        " samtools fastq -@ {threads} {output.bam_sorted} -1 {output.fq1} -2 {output.fq2})"
        " > {log} 2>&1"


# analysis of species diversity present AFTER removing human contamination
rule species_diversity_after:
    input:
        db="resources/minikraken-8GB",
        reads=expand(
            "results/nonhuman-reads/{{names}}.{read}.fastq.gz", read=[1, 2]
        ),
    output:
        kraken_output=temp(
            "results/species-diversity-nonhuman/{names}/{names}.kraken"
        ),
        report="results/species-diversity-nonhuman/{names}/{names}.cleaned.kreport2",
    log:
        "logs/kraken/{names}_nonhuman.log",
    conda:
        "../envs/kraken.yaml"
    threads: 8
    shell:
        "(kraken2 --db {input.db} --threads {threads} --report {output.report} --gzip-compressed "
        "--paired {input.reads} > {output.kraken_output}) 2> {log}"


# plotting Krona charts AFTER removing human contamination
rule create_krona_chart_after:
    input:
        kraken_output="results/species-diversity-nonhuman/{names}/{names}.cleaned.kreport2",
        taxonomy_database="resources/krona/",
    output:
        "results/species-diversity-nonhuman/{names}/{names}.html",
    log:
        "logs/krona/{names}_nonhuman.log",
    conda:
        "../envs/kraken.yaml"
    shell:
        "ktImportTaxonomy -m 3 -t 5 -tax {input.taxonomy_database} -o {output} {input} 2> {log}"
