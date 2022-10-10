rule test:
    input:
        is_valid_organism(),


"""
def get_depth_input(wildcards):
    if is_amplicon_data(wildcards.sample):
        # use clipped reads
        return "results/{date}/clipped-reads/{sample}.primerclipped.bam"
    # use trimmed reads
    amplicon_reference = config["adapters"]["amplicon-reference"]
    return "results/{{date}}/mapped/ref~{ref}/{{sample}}.bam".format(
        ref=amplicon_reference
    )

def get_bwa_index(wildcards):
    if wildcards.reference == "human" or wildcards.reference == "main+human":
        return rules.bwa_large_index.output
    else:
        return rules.bwa_index.output


def get_reads(wildcards):
    # alignment against the human reference genome is done with trimmed reads,
    # since this alignment is used to generate the ordered, non human reads
    if (
        wildcards.reference == "human"
        or wildcards.reference == "main+human"
        or wildcards.reference.startswith("polished-")
        or wildcards.reference.startswith("consensus-")
    ):

        illumina_pattern = expand(
            "results/{date}/trimmed/fastp-pe/{sample}.{read}.fastq.gz",
            read=[1, 2],
            **wildcards,
        )

    # theses reads are used to generate the bam file for the BAMclipper and the coverage plot of the main reference
    elif wildcards.reference == config["preprocessing"]["amplicon-reference"]:
        return get_non_human_reads(wildcards)

    # aligments to the references main reference genome,
    # are done with reads, which have undergone the quality control process
    else:
        return get_reads_after_qc(wildcards)
    """