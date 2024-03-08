rule minimap2:
    input:
        ref="resources/genomes/mtb-genome.fna.gz",
        trimmed_fastq="results/fastp/{sample}_fp_trimmed.fastq"
    output:
        sam="results/mapped/{sample}.sam"
    log:
        "logs/minimap2/{sample}.log"
    params:
        quality=config['samtools_q_flag']  
    conda:
        "../../envs/analysis_env.yaml"
    shell:
        "minimap2 -ax map-ont {input.ref} {input.trimmed_fastq} | "
        "samtools view -F 4 -q {params.quality} -S -h -o {output.sam}"

rule samtools_samtobam:
    input:
        sam_file="results/mapped/{sample}.sam"
    output:
        "results/mapped/{sample}.sorted.bam"
    log:
        "logs/samtools_samtobam/{sample}.log"
    conda:
        "../../envs/analysis_env.yaml"
    shell:
        "samtools view -bS {input} | samtools sort -o {output}"
        
rule samtools_index_ont:
    input:
        bam_file="results/mapped/{sample}.sorted.bam"
    output:
        "results/mapped/{sample}.sorted.bam.bai"
    log:
        "logs/samtools_index/{sample}.log"
    conda:
        "../../envs/analysis_env.yaml"
    shell:
        "samtools index {input.bam_file}"

rule samtools_depth_ont:
    input:
        bam_file="results/mapped/{sample}.sorted.bam",
        bai="results/mapped/{sample}.sorted.bam.bai",
    output:
        "results/samtools_depth/{sample}/loci_depth/depth_{loci}.txt",
    log:
        "logs/qc/samtools/depth/{sample}_{loci}.log",
    conda:
        "../../envs/analysis_env.yaml"
    params:
        region=lambda wildcards: get_region(wildcards.loci),    
    shell:
        "samtools depth -a -d 0 -r {params.region} {input.bam_file} -o {output}"

rule samtools_coverage_ont:
    # Here, a summarising file is created with information about the coverage from a locus of a sample
    input:
        bam="results/mapped/{sample}.sorted.bam",
        bai="results/mapped/{sample}.sorted.bam.bai",
    output:
        temp("results/samtools_depth/{sample}/tmp/coverage_{loci}.txt"),
    conda:
        "../../envs/samtools.yaml"
    params:
        region=lambda wildcards: get_region(wildcards.loci),
    log:
        "logs/qc/samtools/coverage/{sample}_{loci}.log",
    threads: 32
    shell:
        "(samtools coverage -r {params.region} -o - {input.bam} | sed 's/AL123456.3/{wildcards.loci}/' > {output})"


rule samtools_summary_ont:
    # Here, a summarising file is created with information about the coverage from all loci of a sample
    input:
        expand(
            "results/samtools_depth/{{sample}}/tmp/coverage_{loci}.txt",
            loci=get_gene_loci(),
            sample=get_samples(),
        ),
    output:
        "results/samtools_depth/{sample}/{sample}_coverage_summary.txt",
    conda:
        "../../envs/samtools.yaml"
    params:
        locus=get_gene_loci(),
    log:
        "logs/qc/samtools/summary/{sample}.log",
    shell:
        "cat {input} >> {output} ; "
        "echo -ne '\n' >> {output} ; "
        "sed -i '1!{{/^#rname/d;}}' {output}"
