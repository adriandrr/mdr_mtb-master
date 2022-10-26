import pandas as pd
import csv

resdb = pd.read_csv("resources/pointfinder_db/mycobacterium_tuberculosis/resistens-overview.txt", header = 0, sep = '\t')

a = set(resdb.loc[:,"#Gene_ID"].values)
b = {p for p in a if '#' not in str(p)}

#resdb = resdb.astype({"Codon_pos":"int"})
#resdb = resdb.sort_values('Codon_pos')
#print(resdb)
#df = resdb.loc[resdb["#Gene_ID"] == "ethA_promoter_size_74bp"]
#df = df.astype({"Codon_pos":"int"})
#df = df.sort_values('Codon_pos')
#print(df)
for i in b:
    df = resdb.loc[resdb["#Gene_ID"] == str(i)]
    df = df.astype({"Codon_pos":"int"})
    df = df.sort_values('Codon_pos')
    dflist = df.iloc[[0, -1]].values
    for j in dflist:
        print(j[0],j[2])