if config["reduce_reads"]["reducing"] == False:
# Pipeline path is only accessed when no reads shall be reduced
    rule plot_to_report:
    # This rule gathers information from the results file and creates a summarising plot
        input:
            res=expand("results/{reduce}/ABres/{{sample}}/ABres_{{sample}}.csv",
                reduce = get_read_reduction(),
            ),
            depth=expand("results/{reduce}/ABres/{{sample}}/DepthProfile_{{sample}}.csv",
                reduce = get_read_reduction(),
            )
        output:
            report(
                "results/html/{sample}_resistance-coverage.html",
                caption="../report/resistance.rst",
                category="Resistance plot",
            ),
        conda:
            "../envs/altair.yaml"
        params:
            "{sample}" 
        script:
            "../scripts/altair_plot_single.py"

elif config["reduce_reads"]["reducing"] == True:
# Pipeline path is only accessed when reads shall be reduced
    rule plot_to_report:
    # This rule gathers information from the results file and creates a summarising plot
        input:
            res=expand("results/{reduce}/ABres/{{sample}}/ABres_{{sample}}.csv",
                reduce = get_read_reduction(),
            ),
            depth=expand("results/{reduce}/ABres/{{sample}}/DepthProfile_{{sample}}.csv",
                reduce = get_read_reduction(),
            )
        output:
            report(
                "results/html/{sample}_resistance-coverage.svg",
                caption="../report/resistance.rst",
                category="Resistance plot",
            ),
        conda:
            "../envs/altair.yaml"
        params:
            "{sample}" 
        script:
            "../scripts/altair_plot_list.py"    

rule coverage_sum_to_report:
# This rule gathers information from the results file and creates a summarising plot
    input:
        expand(
            "results/{reduce}/samtools_depth/{{sample}}/{{sample}}_coverage_summary.txt",
            reduce = get_read_reduction(),
        )
    output:
        report(
            "results/html/{sample}_coverage_summary.html",
            caption="../report/coverage.rst",
            category="Loci coverage details",
        ),
    conda:
        "../envs/pandas.yaml",
    params:
        "{sample}"
    script:
        "../scripts/covsum_to_html.py"