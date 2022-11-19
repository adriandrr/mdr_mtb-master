rule create_antibiogram:
    input:
        "results/variants/{sample}/varprofile_{sample}.csv",
    output:
        report(
            "results/ABres/{sample}/ABres_{sample}.csv",
            caption="../report/resistance.rst",
            category="Resistance text",
            )
    conda:
        "../envs/pandas.yaml",
    log:
        "logs/antibiogram/{sample}.log"        
    script:
        "../scripts/compare_variants.py"