if config["reduce_reads"]["reducing"] == False:

    # Pipeline path is only accessed when no reads shall be reduced
    rule plot_to_report:
        # This rule gathers information from the results file and creates a summarising plot
        input:
            res=expand(
                "results/{reduce}/ABres/{{sample}}/ABres_{{sample}}.csv",
                reduce=get_read_reduction(),
            ),
            depth=expand(
                "results/{reduce}/ABres/{{sample}}/DepthProfile_{{sample}}.csv",
                reduce=get_read_reduction(),
            ),
        output:
            report(
                "results/html/{sample}_resistance-coverage.html",
                caption="../report/resistance.rst",
                category="Resistance plot",
                subcategory="{sample}",
                labels={"sample":"{sample}"+" resistances"}
            ),
        conda:
            "../envs/altair.yaml"
        log:
            "logs/report/{sample}_report.log",
        params:
            "{sample}",
        script:
            "../scripts/altair_plot_single.py"


elif config["reduce_reads"]["reducing"] == True:

    # Pipeline path is only accessed when reads shall be reduced
    rule plot_to_report:
        # This rule gathers information from the results file and creates a summarising plot
        input:
            res=expand(
                "results/{reduce}/ABres/{{sample}}/ABres_{{sample}}.csv",
                reduce=get_read_reduction(),
            ),
            depth=expand(
                "results/{reduce}/ABres/{{sample}}/DepthProfile_{{sample}}.csv",
                reduce=get_read_reduction(),
            ),
        output:
            report(
                "results/html/{sample}_resistance-coverage.svg",
                caption="../report/resistance.rst",
                category="Resistance plot",
                subcategory="{sample}",
                labels={"sample":"{sample}"+" resistances"}
            ),
        conda:
            "../envs/altair.yaml"
        log:
            "logs/{reduce}/report/{sample}_plot-to-report.log",
        params:
            "{sample}",
        script:
            "../scripts/altair_plot_list.py"
"""
rule gene_loci_to_report:
    input:
       incsv="resources/gene_loci.csv"
    output:
        outcsv=report("results/html/gene_loci.html",
        caption="../report/resistance.rst",
        category="gene_loci"
        )
    conda:
        "../envs/rbt.yaml"
    shell:
        "csvtotable {input.incsv} {output.outcsv}"
"""
rule summed_resistances_to_report:
    input:
        expand("results/{reduce}/summed_resistances.csv",
        reduce=get_read_reduction(),
        )
    output:
        report("results/html/summed_resistances.html",
        caption="../report/resistance.rst",
        category="Summed resistances",
        labels={"sample":"summed resistances"}
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
            "results/{reduce}/samtools_depth/{{sample}}/{{sample}}_coverage_summary.txt",
            reduce=get_read_reduction(),
        ),
    output:
        report(
            "results/html/{sample}_coverage_summary.html",
            caption="../report/coverage.rst",
            category="Loci coverage details",
            subcategory="{sample}",
            labels={"sample":"{sample}"+" coverage"}
        ),
    conda:
        "../envs/pandas.yaml"
    log:
        "logs/report/{sample}_covsum-to-report.log",
    params:
        "{sample}",
    script:
        "../scripts/covsum_to_html.py"
