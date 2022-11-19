rule plot_to_report:
    input:
        "results/ABres/{sample}/ABres_{sample}.csv",
        "results/ABres/{sample}/DepthProfile_{sample}.csv",

    output:
        report(
            "results/plots/{sample}/resistance-coverage.html",
            caption="../report/resistance.rst",
            category="Resistance plot",
        ),
    conda:
        "../envs/python.yaml"
    script:
        "../scripts/altair_plot.py"