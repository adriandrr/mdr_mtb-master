if config["reduce_reads"]["reducing"] == False:
    rule report_no_reduce:
        input:
            "results/qc/multiqc/multiqc.html",
            "results/qc/trimmed/multiqc/multiqc.html",
            expand(
                "results/html/{sample}_resistance-coverage.html",        
                sample = get_samples(),
            ),
            expand(
                "results/html/{sample}_coverage_summary.html",            
                sample = get_samples(),
            )
        output:
            "results/report.html"
        shell:
            "snakemake --nolock --report {output}"

if config["reduce_reads"]["reducing"] == True:
    rule report_reduce:
        input:
            "results/qc/multiqc/multiqc.html",
            "results/qc/trimmed/multiqc/multiqc.html",
            expand(
                "results/html/{sample}_resistance-coverage.svg",        
                sample = get_samples(),
            ),
            expand(
                "results/html/{sample}_coverage_summary.html",            
                sample = get_samples(),
            )
        output:
            "results/report.html"
        shell:
            "snakemake --nolock --report {output}"        