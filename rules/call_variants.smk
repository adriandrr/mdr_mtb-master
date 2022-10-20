rule map_to_region:
    input:
        "resources/genomes/mtb-genome.fna",
        "results/mapped/{sample}.sorted.bam",
        "results/mapped/{sample}.sorted.bam.bai",
    output: 
        "results/variants/{sample}/loci_{loci}.vcf",
    params:
        region=lambda wildcards: get_region(wildcards.loci)
    shell:
        "echo {params.region}; "
        "freebayes -f {input[0]} --region {params.region} {input[1]} > {output}"