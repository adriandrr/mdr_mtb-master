rule get_genome:
    # This rule downloads the reference genome defined in the config file
    output:
        temp("resources/genomes/mtb-genome.fna.gz"),
    params:
        mtb_genome=config["mtb-genome-download-path"],
    log:
        "logs/get_genome/get-human-genome.log",
    conda:
        "../envs/unix.yaml"
    shell:
        "curl -SL -o {output} {params.mtb_genome} 2> {log}"


rule unzip_genome:
    input:
        "resources/genomes/mtb-genome.fna.gz",
    output:
        "resources/genomes/mtb-genome.fna",
    log:
        "logs/get_genome/unzip.log",
    conda:
        "../envs/unix.yaml"
    shell:
        "gzip -dkf {input} > {output}"


rule index_genome:
    input:
        "resources/genomes/mtb-genome.fna",
    output:
        "resources/genomes/mtb-genome.fna.fai",
    log:
        "logs/index_genome/index.log",
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools faidx {input} > {output}"


rule bwa_index:
    # A rule necessary to index the reference genome
    input:
        "resources/genomes/mtb-genome.fna.gz",
    output:
        idx=temp(
            multiext(
                "results/genomes/mtb-genome.fna", ".amb", ".ann", ".bwt", ".pac", ".sa",
            )
        ),
    params:
        prefix=lambda w, output: get_bwa_index_prefix(output),
    log:
        "logs/bwa-index/mtb-genome.log",
    wrapper:
        "v1.14.1/bio/bwa/index"


rule map_reads:
    # Here, the trimmed reads are mapped against the reference genome with bwa
    input:
        reads=[
            "results/trimmed/{sample}_R1.fastq",
            "results/trimmed/{sample}_R2.fastq",
        ],
        idx=multiext(
            "results/genomes/mtb-genome.fna", ".amb", ".ann", ".bwt", ".pac", ".sa",
        ),
    output:
        temp("results/mapped/{sample}.bam"),
    log:
        "logs/bwa_mem/{sample}.log",
    params:
        index=lambda w, input: get_bwa_index_prefix(input.idx),
        extra="",
        sort="samtools",
        sort_order="coordinate",
    threads: 8
    wrapper:
        "v1.14.1/bio/bwa/mem"


if not config["reduce_reads"]["reducing"]:

    # Pipeline path is only accessed when no reads shall be reduced
    rule samtools_sort:
        # This rule sorts the already mapped bam files
        input:
            "results/mapped/{sample}.bam",
        output:
            temp("results/{reduce}/mapped/{sample}.sorted.bam"),
        log:
            "logs/{reduce}/samtools/{sample}.log",
        params:
            extra="-m 4G",
        threads: 8
        wrapper:
            "v1.14.1/bio/samtools/sort"


rule samtools_index:
    # This rule creates an index to the already mapped and sorted bam files
    input:
        "results/{reduce}/mapped/{sample}.sorted.bam",
    output:
        temp("results/{reduce}/mapped/{sample}.sorted.bam.bai"),
    log:
        "logs/{reduce}/samtools/sort/{sample}.index.log",
    params:
        extra="",
    threads: 4
    wrapper:
        "v1.17.2/bio/samtools/index"
