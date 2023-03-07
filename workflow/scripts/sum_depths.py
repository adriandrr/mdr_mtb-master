# A script summarising different locus depth information to one file

import pandas as pd

path_list = list(snakemake.input[0:])
genenames = list(snakemake.params)
outfile = str(snakemake.output)

with open(str(snakemake.output), "w+") as outcsv:
    if len(outcsv.readlines()) == 0:
        outcsv.write("Gene,Position,Depth,Mutation,Antibiotic\n")
    for path in path_list:
        locus_df = pd.read_csv(path, header=0, sep="\t")
        for name in genenames[0]:
            if name in path:
                locus_df.rename(
                    columns={
                        locus_df.columns[0]: "Gene",
                        locus_df.columns[1]: "Position",
                        locus_df.columns[2]: "Depth",
                    },
                    inplace=True,
                )
                locus_df = locus_df.replace("AL123456.3", name, regex=True)
                locus_df["Mutation"] = "-"
                locus_df["Antibiotic"] = "-"
                break
        locus_df.to_csv(outcsv, mode="a", index=False, header=False)
