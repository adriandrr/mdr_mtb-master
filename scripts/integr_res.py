import pandas as pd
import numpy as np
import ast

ab_df = pd.read_csv(str(snakemake.input[0]), header=0, sep="\t")
dp_df = pd.read_csv(str(snakemake.input[1]), header=0, sep=",")

# drops all mutation with a positional read depth below 8
ab_df = ab_df.drop(ab_df[ab_df.Read_depth < 8].index)

# converts columns which have int and lists as values
def convert_lists(value):
    try:
        value = int(value)
    except:
        value = sum(ast.literal_eval(value))
    return value

# integrate resistance in depth profile
for i in range(ab_df.shape[0]):
    pos = ab_df.loc[i]["Genome_pos"]
    locidx = dp_df.index[dp_df["Position"] == pos].tolist()[0]
    dp_df.at[locidx, "Mutation"] = (
        ab_df.loc[i]["Ref_Codon"]
        + str(ab_df.loc[i]["Codon_num"])
        + ab_df.loc[i]["Alt_Codon"]
    )
    dp_df.at[locidx, "Antibiotic"] = ab_df.loc[i]["Resistance"]
dp_df.to_csv(str(snakemake.output.depthout), mode="a", index=False, header=True)

# integrate locus average in abresprofile
ls = []
gene_loci = dp_df["Gene"].drop_duplicates().to_list()
for gene in gene_loci:
    gene_df = dp_df.loc[dp_df["Gene"] == gene]
    ls.append([gene,round(gene_df["Depth"].mean())])
dp_df = pd.DataFrame(ls)
dp_df = dp_df.rename(columns={0:"Mut_gene",1:"AvLocus_Depth"})
res = ab_df.merge(dp_df, on='Mut_gene')
locdepth = res.pop("AvLocus_Depth")
res.insert(11, "AvLocus_Depth", locdepth)
res['Alt_num'] = res['Alt_num'].apply(convert_lists)
res["Var_Qual"]= round(np.square(res["Alt_num"]/res["Read_depth"])*np.log10(res["Alt_num"]),2)
res.to_csv(str(snakemake.output.resout), mode="a", index=False, header=True)