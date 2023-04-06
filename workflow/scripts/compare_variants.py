import pandas as pd
import csv

RES_DB_PATH = "resources/pointfinder_db/mycobacterium_tuberculosis/resistens-overview.txt"
STOP_DB_PATH = "resources/pointfinder_db/mycobacterium_tuberculosis/stop-overview.txt"

def Average(lst):
    return sum(lst) / len(lst)

def read_resistance_db(path):
    if "resistens-overview.txt" in path:
        db = pd.read_csv(path,header=0,sep="\t",)
        db["PMID"] = db["PMID"].str.replace(",", ";")
        db["Resistance"] = db["Resistance"].str.replace(",", ";")
        return db
    elif "stop-overview.txt" in path:
        stopcodonlist = ["TAG", "TAA", "TGA"]
        db = pd.read_csv(path,header=0,sep="\t",)
        return db,stopcodonlist
    else:
        return "ERROR: Wrong database called"

def Average(lst):
    return sum(lst) / len(lst)

def comparison_method(gene_or_codon):
    if gene_or_codon == "gene":
        pd_col = 2
    elif gene_or_codon == "codon":
        pd_col = 3
    return pd_col

def create_compare_lists(comp, sumvar, gene_df):
    index = sumvar.loc[i][4] - 1
    hit_df = gene_df.loc[gene_df["Codon_pos"] == int(sumvar.loc[i][comp])] if isinstance(comp, int) else None
    if comp == 2:
        complist, mutlist = [sumvar.loc[i][5][index],sumvar.loc[i][7][index]], list(hit_df.loc[:,"Ref_codon":"Res_codon"].values)[0]
    elif comp == 3:
        complist, mutlist = list(sumvar.loc[i,"Ref_Codon":"Alt_aas"].values), list(hit_df.loc[:,"Ref_nuc":"Res_codon"].values)[0]
        del complist[2]
    elif comp == "negative":
        ref_cod, alt_cod = list(sumvar.loc[i][5]), list(sumvar.loc[i][7])
        ref_cod.reverse()
        alt_cod.reverse()
        hit_df = gene_df.loc[gene_df["Codon_pos"] == int(sumvar.loc[i][2])]
        complist, mutlist = [ref_cod[index],alt_cod[index]], list(hit_df.loc[:,"Ref_codon":"Res_codon"].values)[0]
    return complist, mutlist, hit_df

def prepare_output(i,sumvar):
    res = ""
    for elem in sumvar.loc[i,].tolist():
        res += str(elem)+","
    return res

def process_res_mut(rtype, hit_df, res):
    if rtype == "res":
        for elem in hit_df.loc[:,"Resistance":"PMID"].values[0]:
            res += str(elem)+","
        outcsv.write("res_mut,{}\n".format(res.rstrip(",")))
    elif rtype == "no_res":
        outcsv.write("no_res_mut,{},-,-\n".format(res.rstrip(",")))

resdb = read_resistance_db(RES_DB_PATH)
stopdb,stopcodonlist = read_resistance_db(STOP_DB_PATH)
sumvar = pd.read_csv(str(snakemake.input), header=0, sep="\t")


with open(str(snakemake.output), "w") as outcsv:
    outcsv.writelines(
        "Mut_status,Mut_gene,Genome_pos,Gene_pos,Codon_num,Codon_pos,Ref_Codon,Ref_aas,Alt_Codon,Alt_aas,Var_type,Read_depth,Alt_num,Var_Qual,Resistance,PMID\n"
    )
    for i in range(sumvar.shape[0]):
        lenlst = []
        gene_df = resdb.loc[resdb["#Gene_ID"] == sumvar.loc[i][0]]
        for col in gene_df:
            lenlst.append(gene_df["Ref_nuc"].apply(len).mean())
        if Average(lenlst) == 1:
            comp = comparison_method("gene")
            for j in gene_df["Codon_pos"].unique():
                if int(j) == int(sumvar.loc[i][comp]):
                    complist,mutlist,hit_df = create_compare_lists(comp, sumvar, gene_df)
                    res = prepare_output(i,sumvar)
                    if mutlist[0] == complist[0] and complist[1] in list(mutlist[1]):
                        process_res_mut("res", hit_df, res)
                    else:
                        process_res_mut("no_res", hit_df, res)
        else:
            comp = comparison_method("codon")
            for j in gene_df["Codon_pos"].unique():
                if int(j) == int(sumvar.loc[i][comp]):
                    complist,mutlist,hit_df = create_compare_lists(comp, sumvar, gene_df)
                    res = prepare_output(i,sumvar)
                    if mutlist[0] == complist[0] and mutlist[1] == complist[1] and complist[2] in list(mutlist[2]):
                        process_res_mut("res", hit_df, res)
                    else:
                        process_res_mut("no_res", hit_df, res)       
            if not gene_df[gene_df["Codon_pos"] < 0].empty:
                comp = comparison_method("gene")
                gene_df = gene_df[gene_df["Codon_pos"] < 0]            
                for j in gene_df["Codon_pos"].unique():
                    if int(j) == int(sumvar.loc[i][comp]):
                        complist,mutlist,hit_df = create_compare_lists("negative", sumvar, gene_df)
                        res = prepare_output(i,sumvar)
                        if mutlist[0] == complist[0] and complist[1] in list(mutlist[1]):
                            process_res_mut("res", hit_df, res)
                        else:
                            process_res_mut("no_res", hit_df, res)

    for i in range(stopdb.shape[0]):
        var_df = sumvar.loc[sumvar["Gene_name"] == stopdb.loc[i][0]]
        for j in var_df["Alt_Codon"].values:
            if j in stopcodonlist:
                res = var_df[
                    (var_df["Gene_name"] == stopdb.loc[i][0]) & (var_df["Alt_Codon"] == j)
                ].to_string(header=False, index=False)
                outcsv.write("res_mut\t{}".format(res.replace(" ", ",")))