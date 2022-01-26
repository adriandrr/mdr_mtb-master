rule trimmomatic:
    input:
        get_fastqs,
    output:
        r1="trimmed/{sample}.1.fastq.gz",sample=get_samples()),
        r2="trimmed/{sample}.2.fastq.gz",sample=get_samples()),
        # reads where trimming entirely removed the mate
        r1_unpaired="trimmed/{sample}.1.unpaired.fastq.gz",
        r2_unpaired="trimmed/{sample}.2.unpaired.fastq.gz"
    log:
        "logs/trimmomatic/{sample}.log"
    params:
        # list of trimmers (see manual)
        trimmer=["TRAILING:3"],
        # optional parameters
        extra="",
        #compression_level="-9"
    threads:
        32
    # optional specification of memory usage of the JVM that snakemake will respect with global
    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
    resources:
        mem_mb=1024
    wrapper:
        "v0.86.0/bio/trimmomatic/pe"