import pandas as pd
import csv

resdb = pd.read_csv(
    "resources/pointfinder_db/mycobacterium_tuberculosis/resistens-overview.txt",
    header=0,
    sep="\t",
)
comparevcf = pd.read_csv(
    "results/variants/1_S1/varprofile_1_S1.csv", header=0, sep="\t"
)
stopdb = pd.read_csv(
    "resources/pointfinder_db/mycobacterium_tuberculosis/stop-overview.txt",
    header=None,
    sep="\t",
)
stopcodonlist = ["TAG", "TAA", "TGA"]


def Average(lst):
    return sum(lst) / len(lst)


"""for i in range(comparevcf.shape[0]):
    lenlst = []
    res= ""
    gene_df = resdb.loc[resdb["#Gene_ID"] == comparevcf.loc[i][0]]
    for col in gene_df:
        lenlst.append(gene_df["Ref_nuc"].apply(len).mean())
    if Average(lenlst) == 1:
        index = comparevcf.loc[i][4] - 1
        complist = [comparevcf.loc[i][5][index],comparevcf.loc[i][7][index]]
        for j in gene_df["Codon_pos"].unique():
            if int(j) == int(comparevcf.loc[i][2]):
                hit_df = gene_df.loc[gene_df["Codon_pos"] == int(comparevcf.loc[i][2])]
                mutlist = list(hit_df.loc[:,"Ref_codon":"Res_codon"].values)[0]
                print(mutlist,complist)
                for elem in comparevcf.loc[i,].tolist():
                    res += str(elem)+"\t" 
                if mutlist[0] == complist[0] and mutlist[1] == complist[1] and complist[2] in list(mutlist[2]):
                    for elem in hit_df.loc[:,"Resistance":"PMID"].values[0]:
                        #print(list(hit_df.loc[:,"Resistance":"PMID"].values[0],type(hit_df.loc[:,"Resistance":"PMID"].values[0]))
                        res += str(elem)+"\t" 
                    print("res_mut\t{}".format(res))
                else:
                    print("no_res_mut\t{}".format(res))

    else:
        complist = list(comparevcf.loc[i,"Ref_Codon":"Alt_aas"].values)
        for j in gene_df["Codon_pos"].unique():
            if int(j) == int(comparevcf.loc[i][3]):
                hit_df = gene_df.loc[gene_df["Codon_pos"] == int(comparevcf.loc[i][3])]
                mutlist = list(hit_df.loc[:,"Ref_nuc":"Res_codon"].values)[0]
                del complist[2]
                for elem in comparevcf.loc[i,].tolist():
                    res += str(elem)+"\t" 
                if mutlist[0] == complist[0] and mutlist[1] == complist[1] and complist[2] in list(mutlist[2]):
                    for elem in hit_df.loc[:,"Resistance":"PMID"].values[0]:
                        #print(list(hit_df.loc[:,"Resistance":"PMID"].values[0],type(hit_df.loc[:,"Resistance":"PMID"].values[0]))
                        res += str(elem)+"\t" 
                    print("res_mut\t{}".format(res))
                else:
                    print("no_res_mut\t{}".format(res))"""

for i in range(stopdb.shape[0]):
    var_df = comparevcf.loc[comparevcf["Gene_name"] == stopdb.loc[i][0]]
    for j in var_df["Alt_Codon"].values:
        if j in stopcodonlist:
            res = var_df[
                (var_df["Gene_name"] == stopdb.loc[i][0]) & (var_df["Alt_Codon"] == j)
            ].to_string(header=False, index=False)
            print("res_mut\t{}".format(res.replace(" ", "\t")))
