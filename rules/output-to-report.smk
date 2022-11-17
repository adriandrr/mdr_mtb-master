rule plot_to_report:
    input:
        "results/ABres/{sample}/ABres_{sample}.csv",
        "results/ABres/{sample}/DepthProfile_{sample}.csv",
    output:
        report(
            "results/plots/resistance-coverage.png",
            caption="../report/Resistance-coverage.rst",
            category="3. Sequencing Details",
            subcategory="2. Coverage of Reference Genome",
        ),
    conda:
        "../envs/python.yaml"
    script:
        "../scripts/altair_plot.py"