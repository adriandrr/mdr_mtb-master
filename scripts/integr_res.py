import pandas as pd

ab_df = pd.read_csv(str(snakemake.input[0]), header = 0, sep = '\t')
dp_df = pd.read_csv(str(snakemake.input[1]), header = 0, sep = ',')

with open(str(snakemake.output), "w") as outcsv:
    for i in range(ab_df.shape[0]):
        pos = ab_df.loc[i]['Genome_pos']
        locidx = dp_df.index[dp_df['Position'] == pos].tolist()[0]
        dp_df.at[locidx, 'Mutation'] = (
            ab_df.loc[i]['Ref_Codon'] +
            str(ab_df.loc[i]['Codon_num']) +
            ab_df.loc[i]['Alt_Codon'])
        dp_df.at[locidx, 'Antibiotic'] = ab_df.loc[i]['Resistance']
    dp_df.to_csv(outcsv, mode='a', index=False, header=True)