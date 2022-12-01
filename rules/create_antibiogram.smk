rule create_antibiogram:
    input:
        "results/{reduce}/variants/{sample}/varprofile_{sample}.csv",
    output:
        temp("results/{reduce}/ABres/{sample}/tmp/ABres_{sample}.csv"),
    conda:
        "../envs/pandas.yaml",
    log:
        "logs/{reduce}/create_antibiogram/{sample}.log"        
    script:
        "../scripts/compare_variants.py"
