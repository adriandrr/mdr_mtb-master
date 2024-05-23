rule create_antibiogram:
    # This key rule is used to compare found mutations with the resistance mutation database
    input:
        "results/variants/{sample}/varprofile_{sample}.csv",
    output:
        temp("results/ABres/{sample}/tmp/ABres_{sample}.csv"),
    conda:
        "../envs/pandas.yaml"
    log:
        "logs/create_antibiogram/{sample}.log",
    script:
        "../scripts/compare_variants.py"