rule get_genome:
    output:
        "resources/genomes/mtb-genome.fna.gz",
    params:
        mtb_genome=config["mtb-genome-download-path"],
    log:
        "logs/get_genome/get-human-genome.log",
    conda:
        "../envs/unix.yaml"
    shell:
        "curl -SL -o {output} {params.mtb_genome} 2> {log}"

rule bwa_index:
    input:
        "resources/genomes/mtb-genome.fna.gz",
    output:
        idx=multiext(
            "results/bwa/index/mtb-genome.fasta",
            ".amb",
            ".ann",
            ".bwt",
            ".pac",
            ".sa",
        ),
    params:
        prefix=lambda w, output: get_bwa_index_prefix(output),
    log:
        "logs/bwa-index/mtb-genome.log",
    wrapper:
        "v1.14.1/bio/bwa/index"

rule map_reads:
    input:
        reads=["results/trimmed/{sample}_R1.fastq", "results/trimmed/{sample}_R2.fastq"],
        idx=multiext(
            "results/bwa/index/mtb-genome.fasta",
            ".amb",
            ".ann",
            ".bwt",
            ".pac",
            ".sa",
        )
    output:
        temp("results/mapped/{sample}.bam")
    log:
        "logs/bwa_mem/{sample}"
    params:
        index=lambda w, input: get_bwa_index_prefix(input.idx),
        extra="",        
        sort="samtools",
        sort_order="coordinate",
    threads: 8
    wrapper:
        "v1.14.1/bio/bwa/mem"

rule samtools_sort:
    input:
        "results/mapped/{sample}.bam",
    output:
        "results/mapped/{sample}.sorted.bam",
    log:
        "logs/samtools/{sample}.log",
    params:
        extra="-m 4G",
    threads: 8
    wrapper:
        "v1.14.1/bio/samtools/sort"

rule samtools_index:
    input:
        "results/mapped/{sample}.sorted.bam",
    output:
        "results/mapped/{sample}.sorted.bam.bai",
    log:
        "logs/samtools/sort/{sample}.index.log",
    params:
        extra="",  # optional params string
    threads: 4  
    wrapper:
        "v1.17.2/bio/samtools/index"