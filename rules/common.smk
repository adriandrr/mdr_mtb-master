# Copyright 2021 Thomas Battenfeld, Alexander Thomas, Johannes Köster.
# Licensed under the BSD 2-Clause License (https://opensource.org/licenses/BSD-2-Clause)
# This file may not be copied, modified, or distributed
# except according to those terms.

configfile: "config/config.yaml"

def get_samples():
    print("get_samples:",list(pep.sample_table["sample_name"].values))
    return list(pep.sample_table["sample_name"].values)

def get_fastqs(wildcards):
    r=pep.sample_table.loc[wildcards.sample]["fq1"],pep.sample_table.loc[wildcards.sample]["fq2"],
    print("r1",r[0])
    print("r2",r[1])
    print("data/{sample}_R1_001.fastq.gz")
    return pep.sample_table.loc[wildcards.sample][["fq1", "fq2"]]

def sep_fastqs(wildcards):  
    print(pep.sample_table.loc[wildcards.sample]["fq1","fq2"])
    return pep.sample_table.loc[wildcards.sample]["fq1","fq2"]