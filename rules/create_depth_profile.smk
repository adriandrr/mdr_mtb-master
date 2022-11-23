rule create_depth_profile:
    input:
        expand(
            "results/{{reduce}}/qc/samtools_depth/{{sample}}/loci_depth/depth_{loci}.txt",
            loci = get_gene_loci(),
            sample = get_samples(),
            reduce = get_read_reduction(),
        )
    output:
        temp("results/{reduce}/qc/samtools_depth/{sample}/DepthProfile_{sample}.csv"),
    conda:
        "../envs/pandas.yaml"
    params:
        lambda wildcards: get_gene_loci(),
    log:
        "logs/{reduce}/depthprofile/{sample}.log"        
    script:
        "../scripts/sum_depths.py"

rule integrate_resistances:
    input:
        "results/{reduce}/ABres/{sample}/ABres_{sample}.csv",
        "results/{reduce}/qc/samtools_depth/{sample}/DepthProfile_{sample}.csv",
    output:
        "results/{reduce}/ABres/{sample}/DepthProfile_{sample}.csv",
    conda:
        "../envs/pandas.yaml"
    log:
        "logs/{reduce}/depthprofile_with_res/{sample}.log"        
    script:
        "../scripts/integr_res.py"