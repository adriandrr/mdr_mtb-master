rule create_antibiogram:
    input:
        "results/variants/{sample}/varprofile_{sample}.csv",
    output:
        "results/ABres/{sample}/ABres_{sample}.csv",
    conda:
        "../envs/pandas.yaml"
    script:
        "../scripts/compare_variants.py"