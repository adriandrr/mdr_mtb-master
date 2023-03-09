import pandas as pd
import csv

df_res = pd.read_csv("output.csv",header=0,sep=",")

row1 = df_res.loc[0,:].values.tolist()
row2 = df_res.loc[1,:].values.tolist()

# Verify the contents of the CSV file
assert len(res) == 2  # Verify the number of rows
assert "rpoB" in row1
assert "res_mut" in row1
assert "RIFAMPICIN" in row1

assert "eis_promoter_size_119bp" in row2
assert "res_mut" in row2
assert "KANAMYCIN" in row2