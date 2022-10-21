rule map_to_region:
    input:
        "resources/genomes/mtb-genome.fna",
        "results/mapped/{sample}.sorted.bam",
        "results/mapped/{sample}.sorted.bam.bai",
    output: 
        "results/variants/{sample}/{sample}_{loci}.vcf",
    params:
        region=lambda wildcards: get_region(wildcards.loci),
        filter="\"QUAL > 100\""
    conda:
        "../envs/freebayes.yaml",
    shell:
        "freebayes -f {input[0]} --region {params.region} {input[1]} |"
        " vcffilter -f {params.filter} > {output}"

rule create_variant_profile:
    input:
        expand(
            "results/variants/{{sample}}/{{sample}}_{loci}.vcf",
            loci = get_gene_loci(),
            sample = get_samples(),
        )
    output:
        "results/variants/{sample}/varprofile_{sample}.csv",
    conda:
        "../envs/vcf.yaml"
    script:
        "../scripts/sum_vars.py"