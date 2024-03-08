rule call_region_variant:
    # The package freebayes is used to call mutations in the previously selected regions
    input:
        fna="resources/genomes/mtb-genome.fna",
        fai="resources/genomes/mtb-genome.fna.fai",
        bam="results/mapped/{sample}.sorted.bam",
        bai="results/mapped/{sample}.sorted.bam.bai",
    output:
        temp("results/variants/{sample}/{sample}_{loci}.vcf"),
    params:
        region=lambda wildcards: get_region(wildcards.loci),
        filter='"QUAL > 50"',
    conda:
        "../envs/freebayes.yaml"
    log:
        "logs/freebayes/{sample}_{loci}.log",
    threads: 32
    shell:
        "freebayes -f {input.fna} --region {params.region} {input.bam} |"
        " vcffilter -f {params.filter} | vcfallelicprimitives -kg > {output}"


rule create_variant_profile:
    # This rule sums all variants of a sample and adds further information from different sources
    input:
        expand(
            "results/variants/{{sample}}/{{sample}}_{loci}.vcf",
            loci=get_gene_loci(),
            sample=get_samples(),
        ),
    output:
        "results/variants/{sample}/varprofile_{sample}.csv",
    conda:
        "../envs/vcf.yaml"
    log:
        "logs/varprofile/{sample}.log",
    script:
        "../scripts/sum_vars.py"
