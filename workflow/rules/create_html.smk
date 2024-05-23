rule plot_to_report:
    # This rule gathers information from the results file and creates a summarising plot
    input:
        res=expand(
            "results/ABres/{{sample}}/ABres_{{sample}}.csv",
        ),
        depth=expand(
            "results/ABres/{{sample}}/DepthProfile_{{sample}}.csv",
        ),
    output:
        report(
            "results/html/{sample}_resistance-coverage.html",
            caption="../report/resistance.rst",
            category="Resistance plot",
        ),
    conda:
        "../envs/altair.yaml"
    log:
        "logs/report/{sample}_report.log",
    params:
        "{sample}",
    script:
        "../scripts/altair_plot_single.py"

rule resistances_causing_mutations_to_report:
    input:
        expand("results/resistances_causing_mutations.csv",
        )
    output:
        report("results/html/resistances_causing_mutations.html",
        caption="../report/resistance.rst",
        category="summed plot"
        )
    conda:
        "../envs/altair.yaml"
    log:
        "logs/report/summed-resistance.log"
    script:
        "../scripts/altair_summary.py"

rule coverage_sum_to_report:
    # This rule gathers information from the results file and creates a summarising plot
    input:
        expand(
            "results/samtools_depth/{{sample}}/{{sample}}_coverage_summary.txt",
        ),
    output:
        report(
            "results/html/{sample}_coverage_summary.html",
            caption="../report/coverage.rst",
            category="Loci coverage details",
        ),
    conda:
        "../envs/pandas.yaml"
    log:
        "logs/report/{sample}_covsum-to-report.log",
    params:
        "{sample}",
    script:
        "../scripts/covsum_to_html.py"