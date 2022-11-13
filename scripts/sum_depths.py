import pandas as pd

#incsv = pd.read_csv(str(snakemake.input), header = 0, sep = '\t').drop(["#CHROM"])
path = "/homes/adrian/mdr_mtb-master/backup/results(-0)/qc/samtools_depth/10_S4/loci_depth/depth_"
alr = pd.read_csv(path + "alr.txt", header = 0, sep = '\t').drop(["#CHROM"], axis = 1)
alr = alr.rename(columns={"POS":"alr_POS","results/mapped/10_S4.sorted.bam":"alr_depth"})
drrA = pd.read_csv(path + "drrA.txt", header = 0, sep = '\t').drop(["#CHROM"], axis = 1)
drrA = drrA.rename(columns={"POS":"drrA_POS","results/mapped/10_S4.sorted.bam":"drrA_depth"})
gyrA = pd.read_csv(path + "gyrA.txt", header = 0, sep = '\t').drop(["#CHROM"], axis = 1)
gyrA = gyrA.rename(columns={"POS":"gyrA_POS","results/mapped/10_S4.sorted.bam":"gyrA_depth"})

files = [alr, drrA, gyrA]
res = []

for file in files:
    csv_as_string = file.to_string(header=True)
    outcsv.write(csv_as_string)