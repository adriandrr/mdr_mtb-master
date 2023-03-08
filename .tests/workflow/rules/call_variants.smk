rule call_region_variant:
# The package freebayes is used to call mutations in the previously selected regions
    input:
        fna="resources/genomes/mtb-genome.fna",
        fai="resources/genomes/mtb-genome.fna.fai",
        bam="results/{reduce}/mapped/{sample}.sorted.bam",
        bai="results/{reduce}/mapped/{sample}.sorted.bam.bai",
    output: 
        temp("results/{reduce}/variants/{sample}/{sample}_{loci}.vcf"),
    params:
        region=lambda wildcards: get_region(wildcards.loci),
        filter="\"QUAL > 50\""
    conda:
        "../envs/freebayes.yaml",
    log:
        "logs/{reduce}/freebayes/{sample}_{loci}.log"
    shell:
        "freebayes -f {input.fna} --region {params.region} {input.bam} |"
        " vcffilter -f {params.filter} | vcfallelicprimitives -kg > {output}"

rule create_variant_profile:
# This rule sums all variants of a sample and adds further information from different sources
    input:
        expand(
            "results/{{reduce}}/variants/{{sample}}/{{sample}}_{loci}.vcf",
            loci = get_gene_loci(),
            sample = get_samples(),
            reduce = get_read_reduction(),
        )
    output:
        "results/{reduce}/variants/{sample}/varprofile_{sample}.csv",
    conda:
        "../envs/vcf.yaml"
    log:
        "logs/{reduce}/varprofile/{sample}.log"
    script:
        "../scripts/sum_vars.py"