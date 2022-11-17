import pandas as pd
import numpy as np

abres1 = "/homes/adrian/mdr_mtb-master/results/ABres/10_S4/ABres_10_S4.csv"
abres2 = "/homes/adrian/mdr_mtb-master/results/ABres/1_S1/ABres_1_S1.csv"
abres3 = "/homes/adrian/mdr_mtb-master/results/ABres/3_S3/ABres_3_S3.csv"
abres4 = "/homes/adrian/mdr_mtb-master/results/ABres/IC_S48/ABres_IC_S48.csv"
abres5 = "/homes/adrian/mdr_mtb-master/results/ABres/WGS_131P_S4/ABres_WGS_131P_S4.csv"
abres6 = "/homes/adrian/mdr_mtb-master/results/ABres/negK_S46/ABres_negK_S46.csv"
abres7 = "/homes/adrian/mdr_mtb-master/results/ABres/posK_S47/ABres_posK_S47.csv"

abdepth1 = "/homes/adrian/mdr_mtb-master/results/ABres/10_S4/DepthProfile_10_S4.csv"

df = pd.read_csv(abres1, header = 0, sep = '\t')
df2 = pd.read_csv(abdepth1, header = 0, sep = ',')
new = df.index[df['Genome_pos'] == 761155]

for i in range(df.shape[0]):
    pos = df.loc[i]['Genome_pos']
    df2pos = df2.index[df2['Position'] == pos].tolist()[0]
    print(df2.iloc[[df2pos]])
    df2.at[df2pos, 'Mutation'] = (
        df.loc[i]['Ref_Codon'] +
        str(df.loc[i]['Codon_num']) +
        df.loc[i]['Alt_Codon']
    )
    print(df2.iloc[[df2pos]])
    #df.loc[i]['Ref_Codon'].to_string()+df.loc[i]['Codon_num'].to_string()+df.loc[i]['Ref_Codon'].to_string()