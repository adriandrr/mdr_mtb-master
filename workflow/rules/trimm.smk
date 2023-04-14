rule fastp_pe:
    # This rule is used to cut of residual adapters from the sequencing
    input:
        sample=get_fastqs
    output:
        trimmed=temp(["results/trimmed/{sample}_R1.fastq","results/trimmed/{sample}_R2.fastq"]),
        html="results/trimmed/{sample}.html",
        json="results/trimmed/{sample}.fastp.json",
    params:
        adapters=config["illumina_adapters"],
        extra="--qualified_quality_phred {} ".format(
            config["minimum-quality"]["min-PHRED"]
        )
        + "--length_required {}".format(
            config["minimum-quality"]["min-Length"]
        ),
    log:
        "logs/fastp/{sample}.log",
    threads: 2
    wrapper:
        "v1.25.0/bio/fastp"
