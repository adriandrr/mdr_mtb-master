rule create_depth_profile:
    input:
        expand(
            "results/qc/samtools_depth/{{sample}}/loci_depth/depth_{loci}.txt",
            loci = get_gene_loci(),
            sample = get_samples(),
        )
    output:
        temp("results/qc/samtools_depth/{sample}/DepthProfile_{sample}.csv"),
    conda:
        "../envs/pandas.yaml"
    params:
        lambda wildcards: get_gene_loci(),
    log:
        "logs/depthprofile/{sample}.log"        
    script:
        "../scripts/sum_depths.py"

rule integrate_resistances:
    input:
        "results/ABres/{sample}/ABres_{sample}.csv",
        "results/qc/samtools_depth/{sample}/DepthProfile_{sample}.csv",
    output:
        "results/ABres/{sample}/DepthProfile_{sample}.csv",
    conda:
        "../envs/pandas.yaml"
    log:
        "logs/depthprofile_with_res/{sample}.log"        
    script:
        "../scripts/integr_res.py"