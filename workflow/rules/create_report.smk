if config["reduce_reads"]["reducing"] == False:

    # Pipeline path is only accessed when no reads shall be reduced
    rule report_no_reduce:
        # The concluding rule which is therefore be called in the rule_all creating the final report
        input:
            "results/qc/multiqc.html",
            "results/html/summed_resistances.html",
            expand(
                "results/html/{sample}_resistance-coverage.html", sample=get_samples(),
            ),
            expand(
                "results/html/{sample}_coverage_summary.html", sample=get_samples(),
            ),
        output:
            "results/report.html",
        conda:
            "../envs/snakemake.yaml",
        log:
            "logs/report/report.log",
        shell:
            "snakemake --nolock --report {output} --report-stylesheet resources/custom-stylesheet.css"


if config["reduce_reads"]["reducing"] == True:

    # Pipeline path is only accessed when reads shall be reduced
    rule report_reduce:
        # The concluding rule which is therefore be called in the rule_all creating the final report
        input:
            #"results/qc/multiqc.html",
            expand(
                "results/html/{sample}_resistance-coverage.svg", sample=get_samples(),
            ),
            expand(
                "results/html/{sample}_coverage_summary.html", sample=get_samples(),
            ),
        output:
            "results/report.html",
        conda:
            "../envs/snakemake.yaml"
        log:
            "logs/report/plot-to-report.log",
        shell:
            "snakemake --nolock --report {output}"
