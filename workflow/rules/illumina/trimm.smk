rule cutadapt:
    # This rule is used to cut of residual adapters from the sequencing
    input:
        get_illumina_fastqs,
    output:
        fastq1=temp("results/trimmed/{sample}_R1.fastq"),
        fastq2=temp("results/trimmed/{sample}_R2.fastq"),
        qc=temp("results/qc/trimmed/cutadapt/{sample}.qc.txt"),
    params:
        adapters=config["illumina_adapters"],
        extra="--minimum-length 1 -q 15",
    log:
        "logs/cutadapt/{sample}.log",
    threads: 4
    wrapper:
        "v1.14.1/bio/cutadapt/pe"
