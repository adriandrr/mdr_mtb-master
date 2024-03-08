rule get_genome:
    # This rule downloads the reference genome defined in the config file
    output:
        temp("resources/genomes/mtb-genome.fna.gz"),
    params:
        mtb_genome=config["mtb-genome-download-path"],
    log:
        "logs/get_genome/get-human-genome.log",
    conda:
        "../envs/unix.yaml"
    shell:
        "curl -SL -o {output} {params.mtb_genome} 2> {log}"


rule unzip_genome:
    input:
        "resources/genomes/mtb-genome.fna.gz",
    output:
        "resources/genomes/mtb-genome.fna",
    log:
        "logs/get_genome/unzip.log",
    conda:
        "../envs/unix.yaml"
    shell:
        "gzip -dkf {input} > {output}"


rule index_genome:
    input:
        "resources/genomes/mtb-genome.fna",
    output:
        "resources/genomes/mtb-genome.fna.fai",
    log:
        "logs/index_genome/index.log",
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools faidx {input} > {output}"


rule bwa_index:
    # A rule necessary to index the reference genome
    input:
        "resources/genomes/mtb-genome.fna.gz",
    output:
        idx=temp(
            multiext(
                "results/genomes/mtb-genome.fna", ".amb", ".ann", ".bwt", ".pac", ".sa",
            )
        ),
    params:
        prefix=lambda w, output: get_bwa_index_prefix(output),
    log:
        "logs/bwa-index/mtb-genome.log",
    wrapper:
        "v1.14.1/bio/bwa/index"