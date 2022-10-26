import pandas as pd
import csv

resdb = pd.read_csv("resources/pointfinder_db/mycobacterium_tuberculosis/resistens-overview.txt", header = 0, sep = '\t')
sumvar = pd.read_csv(str(snakemake.input), header = 0, sep = '\t')

with open(str(snakemake.output), "w") as outcsv:
    outcsv.writelines("Mut_status,Mut_gene,Genome_pos,Codon_num,Codon_pos,Ref_Codon,Ref_aas,Alt_Codon,Alt_aas,Var_type,Read_depth,Alt_num,Var_Qual,Resistance,PMID\n".replace(",","\t"))
    for i in range(sumvar.shape[0]):
        res = ""
        gene_df = resdb.loc[resdb["#Gene_ID"] == sumvar.loc[i][0]]
        if str(sumvar.loc[i][2]) in gene_df["Codon_pos"].unique():
            hit_df = gene_df.loc[gene_df["Codon_pos"] == str(sumvar.loc[i][2])]
            mutlist = list(hit_df.loc[:,"Ref_nuc":"Res_codon"].values)[0]
            complist = list(sumvar.loc[i,"Ref_Codon":"Alt_aas"].values)
            del complist[2]
            for elem in sumvar.loc[i,].tolist():
                res += str(elem)+"\t"            
            if set(mutlist) == set(complist):
                for elem in hit_df.loc[:,"Resistance":"PMID"].values[0]:
                    res += str(elem)+"\t" 
                outcsv.write("res_mut\t{}\n".format(res[:-1]))
            else:
                outcsv.write("no_res_mut\t{}\t-\t-\n".format(res[:-1]))
        else:
            continue