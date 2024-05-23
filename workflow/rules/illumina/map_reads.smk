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


rule samtools_sort:
    # This rule sorts the already mapped bam files
    input:
        "results/mapped/{sample}.bam",
    output:
        temp("results/mapped/{sample}.sorted.bam"),
    log:
        "logs/samtools/{sample}.log",
    params:
        extra="-m 4G",
    threads: 8
    wrapper:
        "v1.14.1/bio/samtools/sort"


rule samtools_index:
    # This rule creates an index to the already mapped and sorted bam files
    input:
        "results/mapped/{sample}.sorted.bam",
    output:
        temp("results/mapped/{sample}.sorted.bam.bai"),
    log:
        "logs/samtools/sort/{sample}.index.log",
    params:
        extra="",
    threads: 4
    wrapper:
        "v1.17.2/bio/samtools/index"

rule samtools_depth:
    # This rule creates a file with all base depth value on every locus
    input:
        bam="results/mapped/{sample}.sorted.bam",
        bai="results/mapped/{sample}.sorted.bam.bai",
    output:
        temp("results/samtools_depth/{sample}/loci_depth/depth_{loci}.txt"),
    conda:
        "../envs/samtools.yaml"
    params:
        region=lambda wildcards: get_region(wildcards.loci),
    log:
        "logs/qc/samtools/depth/{sample}_{loci}.log",
    threads: 32
    shell:
        "samtools depth -H -d 1000000 -r {params.region} -o {output} {input.bam}"


rule samtools_coverage:
    # Here, a summarising file is created with information about the coverage from a locus of a sample
    input:
        bam="results/mapped/{sample}.sorted.bam",
        bai="results/mapped/{sample}.sorted.bam.bai",
    output:
        temp("results/samtools_depth/{sample}/tmp/coverage_{loci}.txt"),
    conda:
        "../envs/samtools.yaml"
    params:
        region=lambda wildcards: get_region(wildcards.loci),
    log:
        "logs/qc/samtools/coverage/{sample}_{loci}.log",
    threads: 32
    shell:
        "(samtools coverage -r {params.region} -o {output} {input.bam} &&"
        " sed -i 's/AL123456.3/{wildcards.loci}/' {output})"


rule samtools_summary:
    # Here, a summarising file is created with information about the coverage from all loci of a sample
    input:
        expand(
            "results/samtools_depth/{{sample}}/tmp/coverage_{loci}.txt",
            loci=get_gene_loci(),
            sample=get_samples(),
        ),
    output:
        "results/samtools_depth/{sample}/{sample}_coverage_summary.txt",
    conda:
        "../envs/samtools.yaml"
    params:
        locus=get_gene_loci(),
    log:
        "logs/qc/samtools/summary/{sample}.log",
    shell:
        "cat {input} >> {output} ; "
        "echo -ne '\n' >> {output} ; "
        "sed -i '1!{{/^#rname/d;}}' {output}"
