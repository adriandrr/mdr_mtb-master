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
        "../envs/altair.yaml"
    params:
        "{sample}"
    log:
        "logs/altair/{sample}.log"        
    script:
        "../scripts/altair_plot.py"

rule coverage_sum_to_report:
    input:
        "results/qc/samtools_depth/{sample}/{sample}_coverage_summary.txt"
    output:
        report("results/qc/samtools_depth/{sample}/{sample}_coverage_summary.html",
            caption="../report/coverage.rst",
            category="Loci coverage details",
        )
    conda:
        "../envs/pandas.yaml",
    params:
        "{sample}"    
    script:
        "../scripts/covsum_to_html.py"