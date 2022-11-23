rule create_antibiogram:
    input:
        "results/{reduce}/variants/{sample}/varprofile_{sample}.csv",
    output:
        "results/{reduce}/ABres/{sample}/ABres_{sample}.csv",
    conda:
        "../envs/pandas.yaml",
    log:
        "logs/{reduce}/antibiogram/{sample}.log"        
    script:
        "../scripts/compare_variants.py"