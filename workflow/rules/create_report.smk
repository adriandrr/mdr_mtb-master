rule create_report:
        # The concluding rule which is therefore be called in the rule_all creating the final report
        input:
            "results/qc/trimmed/multiqc/multiqc.html",
            expand(
                "results/html/{sample}_resistance-coverage.html", sample=get_samples(),
            ),
            expand(
                "results/html/{sample}_coverage_summary.html", sample=get_samples(),
            ),
            "results/html/summed_resistances.html"
        output:
            "results/report.html",
        conda:
            "../envs/snakemake.yaml"
        log:
            "logs/report/report.log",
        shell:
            "snakemake --nolock --report {output}"