import pandas as pd

abresprofile = str(snakemake.input.abres)
depthprofile = str(snakemake.input.depth)

df1 = pd.read_csv(abresprofile, header = 0, sep = '\t')
df2 = pd.read_csv(depthprofile, header = 0, sep = ',')

# integrate the average locus depth
ls = []
gene_loci = df2["Gene"].drop_duplicates().to_list()
for gene in gene_loci:
    gene_df = df2.loc[df["Gene"] == gene]
    ls.append([gene,round(gene_df["Depth"].mean())])
df2 = pd.DataFrame(ls)
df2 = df2.rename(columns={0:"Mut_gene",1:"AvLocus_Depth"})
res = df.merge(df2, on='Mut_gene')
locdepth = res.pop("AvLocus_Depth")
res.insert(11, "AvLocus_Depth", locdepth)

res.to_csv(str(snakemake.output))