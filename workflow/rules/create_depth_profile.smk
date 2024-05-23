rule create_depth_profile:
    # Here, a depth profile is created with every position in every locus with the corresponding base coverage
    input:
        expand(
            "results/samtools_depth/{{sample}}/loci_depth/depth_{loci}.txt",
            loci=get_gene_loci(),
            sample=get_samples(),
        ),
    output:
        temp("results/samtools_depth/{sample}/DepthProfile_{sample}.csv"),
    conda:
        "../envs/pandas.yaml"
    params:
        lambda wildcards: get_gene_loci(),
    log:
        "logs/depthprofile/{sample}.log",
    script:
        "../scripts/sum_depths.py"


rule integrate_resistances:
    # This rule connects certain information explicitly in the input files to both output files
    input:
        resin="results/ABres/{sample}/tmp/ABres_{sample}.csv",
        depthin="results/samtools_depth/{sample}/DepthProfile_{sample}.csv",
    output:
        resout="results/ABres/{sample}/ABres_{sample}.csv",
        depthout="results/ABres/{sample}/DepthProfile_{sample}.csv",
    conda:
        "../envs/pandas.yaml"
    log:
        "logs/depthprofile_with_res/{sample}.log",
    script:
        "../scripts/integr_res.py"

rule sum_resistances:
    input:
        expand(
            "results/ABres/{sample}/ABres_{sample}.csv",
            sample = get_samples()
        )
    output:
        "results/resistances_causing_mutations.csv"
    conda:
        "../envs/pandas.yaml"
    log:
        "logs/summary/summing_resistances/sum.log"
    script:
        "../scripts/sum_res.py"