import pandas as pd

depthsum = str(snakemake.input)
tabtitle = "Coverage summery " + str(snakemake.params)

df = pd.read_csv(depthsum, header= 0, sep = '\t')
df["#rname"]=df["#rname"].str.split('_').str[0]
df["startpos"]=df["endpos"]-df["startpos"]+1
df=df.drop(["endpos"],axis=1)
df=df.rename(columns={"#rname":"locus","startpos":"numpos"})

with open(str(snakemake.output), "w") as outhtml:
    outhtml.write(tabtitle)
    df.to_html(buf=outhtml,header=True,index=False,justify="center")