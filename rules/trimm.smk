# kljlk

rule cutadapt:
    input:
        sample=get_fastqs,
    output:
        fastq1="results/trimmed/{sample}_R1.fastq",
        fastq2="results/trimmed/{sample}_R2.fastq",
        qc="results/qc/trimmed/cutadapt/{sample}.qc.txt",
    params:
        # https://cutadapt.readthedocs.io/en/stable/guide.html#adapter-types
        adapters=get_adapters,
        # https://cutadapt.readthedocs.io/en/stable/guide.html#
        extra="--minimum-length 1 -q 15",
        # Extra options, here a sequence with a lenght smaller than 0 and a quality less than Q15 is discarded
    log:
        "logs/cutadapt/{sample}.log",
    threads: 4  # set desired number of threads here
    wrapper:
        "v1.14.1/bio/cutadapt/pe"
