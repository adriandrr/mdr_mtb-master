import pandas as pd
import csv

resdb = pd.read_csv("resources/pointfinder_db/mycobacterium_tuberculosis/resistens-overview.txt", header = 0, sep = '\t')
comparevcf = pd.read_csv("results/variants/AD_4/varprofile_AD_4.csv", header = 0, sep = '\t')

for i in range(comparevcf.shape[0]):
    res= ""
    gene_df = resdb.loc[resdb["#Gene_ID"] == comparevcf.loc[i][0]]
    if str(comparevcf.loc[i][2]) in gene_df["Codon_pos"].unique():
        hit_df = gene_df.loc[gene_df["Codon_pos"] == str(comparevcf.loc[i][2])]
        mutlist = list(hit_df.loc[:,"Ref_nuc":"Res_codon"].values)[0]
        complist = list(comparevcf.loc[i,"Ref_Codon":"Alt_aas"].values)
        del complist[2]
        for elem in comparevcf.loc[i,].tolist():
            res += str(elem)+"\t" 
        if set(mutlist) != set(complist):
            for elem in hit_df.loc[:,"Resistance":"PMID"].values[0]:
                print(hit_df.loc[:,"Resistance":"PMID"].values[0],type(hit_df.loc[:,"Resistance":"PMID"].values[0]))
                res += str(elem)+"\t" 
            print("res_mut\t{}".format(res))
        else:
            print("no_res_mut\t{}".format(res))