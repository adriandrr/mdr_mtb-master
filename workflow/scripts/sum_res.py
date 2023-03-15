import pandas as pd

with open(str(snakemake.output), "w+") as outcsv:

    sum_df = pd.DataFrame(columns = ["Sample","locus","mutation","resistance","quality"])
    for i in list(snakemake.input):
        temp_df = pd.read_csv(i, header=0, sep=',')
        temp_df = temp_df.loc[temp_df["Mut_status"] == "res_mut"]
        temp_df.insert(0,"Sample", i.split('/')[3])
        temp_df = temp_df.drop(columns=["Mut_status"]).rename(columns={"Mut_gene":"locus"})
        temp_df.insert(2,"mutation",temp_df["Ref_Codon"] + temp_df["Codon_num"].astype(str) + temp_df["Alt_Codon"])
        temp_df.insert(3, "resistance", temp_df["Resistance"])
        temp_df.insert(4, "quality", temp_df["Var_Qual"])
        temp_df.drop(temp_df.columns[range(5,20)], axis = 1, inplace=True)
        sum_df = pd.concat([sum_df, temp_df])
    sum_df['resistance'] = sum_df.resistance.apply(lambda x: x[0:].split(';'))
    sum_df = sum_df.explode("resistance")
    sum_df.to_csv(outcsv, mode="a", index=False, header=True)