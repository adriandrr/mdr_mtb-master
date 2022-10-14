rule get_genes:
    output:
        "resources/genes/mycobacterium_tuberculosis/{genelist}/{genelist}.fsa"
    shell:    
        "cp resources/pointfinder_db/mycobacterium_tuberculosis/{wildcards.genelist}.fsa "
        " resources/genes/mycobacterium_tuberculosis/{wildcards.genelist}"

rule index_gene_loci:
    input:
        "resources/genes/mycobacterium_tuberculosis/{genelist}/{genelist}.fsa",
    output:
        idx=multiext(
            "resources/genes/mycobacterium_tuberculosis/{genelist}/{genelist}.fasta",
            ".amb",
            ".ann",
            ".bwt",
            ".pac",
            ".sa",  
        ),
    params:
        prefix=lambda w, output: get_bwa_index_prefix(output),
    log:
        "logs/bwa-index/genes/{genelist}.log",
    wrapper:
        "v1.14.1/bio/bwa/index"

rule map_reads:
    input:
        reads=["results/trimmed/{sample}_R1.fastq", "results/trimmed/{sample}_R2.fastq"],
        idx=multiext(
            "resources/genes/mycobacterium_tuberculosis/{genelist}/{genelist}.fasta",
            ".amb",
            ".ann",
            ".bwt",
            ".pac",
            ".sa",
        )
    output:
        "results/mapped/{genelist}/{sample}.bam"
    #log:
    #    "logs/bwa_mem/{genelist}/{sample}"
    params:
        index=lambda w, input: get_bwa_index_prefix(input.idx),
        extra="",
        sort="samtools",
        sort_order="coordinate",
    threads: 8
    wrapper:
        "v1.14.1/bio/bwa/mem"

"""
rule samtools_sort:
    input:
        "results/mapped/{genelist}/{sample}.bam"
    output:
        "results/mapped/sorted/{genelist}/{sample}.sorted.bam"
    #log:
    #    "logs/samtools/sorted/{genelist}/{sample}.log",
    params:
        extra="-m 4G",
    threads: 8
    wrapper:
        "v1.14.1/bio/samtools/sort"

rule samtools_index:
    input:
        "results/mapped/sorted/{genelist}/{sample}.sorted.bam",
    output:
        "results/mapped/sorted/{genelist}/{sample}.sorted.bam.bai",
    log:
        "logs/samtools/sort/{genelist}/{sample}.index.log",
    params:
        extra="",  # optional params string
    threads: 8  
    wrapper:
        "v1.14.1/bio/samtools/index"
"""