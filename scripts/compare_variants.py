import pandas as pd
import csv

resdb = pd.read_csv(
    "resources/pointfinder_db/mycobacterium_tuberculosis/resistens-overview.txt",
    header=0,
    sep="\t",
)
resdb["PMID"]=resdb["PMID"].str.replace(",",";")
resdb["Resistance"]=resdb["Resistance"].str.replace(",",";")
sumvar = pd.read_csv(str(snakemake.input), header=0, sep="\t")
stopdb = pd.read_csv(
    "resources/pointfinder_db/mycobacterium_tuberculosis/stop-overview.txt",
    header=None,
    sep="\t",
)
stopcodonlist = ["TAG", "TAA", "TGA"]

# Both varprofile and mutationdb are parsed in a pandas dataframe. For every mutation found in varprofile
# a dataframe of all similar named genes in the mutationdb is created. It is checked if the corresponding
# Codonnumber is found in both dataframes. If so, it is additionally checked if the same Alt aminoacid
# is created. If so, the mutation is added as res_mut, if not it is added as no_res_mut


def Average(lst):
    return sum(lst) / len(lst)


with open(str(snakemake.output), "w") as outcsv:
    outcsv.writelines(
        "Mut_status,Mut_gene,Genome_pos,Gene_pos,Codon_num,Codon_pos,Ref_Codon,Ref_aas,Alt_Codon,Alt_aas,Var_type,Read_depth,Alt_num,Var_Qual,Resistance,PMID\n")
    for i in range(sumvar.shape[0]):
        lenlst = []
        res = ""
        gene_df = resdb.loc[resdb["#Gene_ID"] == sumvar.loc[i][0]]
        for col in gene_df:
            lenlst.append(gene_df["Ref_nuc"].apply(len).mean())
        if Average(lenlst) == 1:
            index = sumvar.loc[i][4] - 1
            complist = [sumvar.loc[i][5][index], sumvar.loc[i][7][index]]
            for j in gene_df["Codon_pos"].unique():
                if int(j) == int(sumvar.loc[i][2]):
                    hit_df = gene_df.loc[gene_df["Codon_pos"] == int(sumvar.loc[i][2])]
                    mutlist = list(hit_df.loc[:, "Ref_codon":"Res_codon"].values)[0]
                    for elem in sumvar.loc[i,].tolist():
                        res += str(elem) + ","
                    if mutlist[0] == complist[0] and complist[1] in list(mutlist[1]):
                        for elem in hit_df.loc[:, "Resistance":"PMID"].values[0]:
                            res += str(elem) + ","
                        outcsv.write("res_mut,{}\n".format(res.rstrip(",")))
                    else:
                        outcsv.write("no_res_mut,{},-,-\n".format(res.rstrip(",")))
        else:
            complist = list(sumvar.loc[i, "Ref_Codon":"Alt_aas"].values)
            for j in gene_df["Codon_pos"].unique():
                if int(j) == int(sumvar.loc[i][3]):
                    hit_df = gene_df.loc[gene_df["Codon_pos"] == int(sumvar.loc[i][3])]
                    mutlist = list(hit_df.loc[:, "Ref_nuc":"Res_codon"].values)[0]
                    del complist[2]
                    for elem in sumvar.loc[i,].tolist():
                        res += str(elem) + ","
                    if (
                        mutlist[0] == complist[0]
                        and mutlist[1] == complist[1]
                        and complist[2] in list(mutlist[2])
                    ):
                        for elem in hit_df.loc[:, "Resistance":"PMID"].values[0]:
                            res += str(elem) + ","
                        outcsv.write("res_mut,{}\n".format(res[:-1].rstrip(",")))
                    else:
                        outcsv.write("no_res_mut,{},-,-\n".format(res[:-1].rstrip(",")))
                else:
                    continue

    for i in range(stopdb.shape[0]):
        var_df = sumvar.loc[sumvar["Gene_name"] == stopdb.loc[i][0]]
        for j in var_df["Alt_Codon"].values:
            if j in stopcodonlist:
                res = var_df[
                    (var_df["Gene_name"] == stopdb.loc[i][0]) & (var_df["Alt_Codon"] == j)
                ].to_string(header=False, index=False)
                outcsv.write("res_mut,{}".format(res))
