# Copyright 2021 Thomas Battenfeld, Alexander Thomas, Johannes Köster.
# Licensed under the BSD 2-Clause License (https://opensource.org/licenses/BSD-2-Clause)
# This file may not be copied, modified, or distributed
# except according to those terms.


rule fastqc:
    input:
        get_fastqs,
    output:
        html="results/qc/fastqc/{sample}.html",
        zip="results/qc/fastqc/{sample}_fastqc.zip",
    log:
        "logs/fastqc/{sample}.log",
    wrapper:
        "v0.86.0/bio/fastqc"

# TODO: Change multiqc rules back to MultiQC wrapper once v1.11 is released
from os import path


rule multiqc:
    input:
        expand("results/qc/fastqc/{sample}_fastqc.zip",sample=get_samples()),
    output:
        "results/qc/multiqc.html"
    params:
        ""  # Optional: extra parameters for multiqc.
    log:
        "logs/multiqc.log"
    wrapper:
        "v0.86.0/bio/multiqc"
