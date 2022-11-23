import pandas as pd

depthsum = snakemake.input
tabtitle = str(snakemake.params) +" coverage summery"

frames=[]
for sum in depthsum:
    df = pd.read_csv(sum, header= 0, sep = '\t')
    df["#rname"]=df["#rname"].str.split('_').str[0]
    df["startpos"]=df["endpos"]-df["startpos"]+1
    df=df.drop(["endpos"],axis=1)
    df=df.rename(columns={"#rname":"locus","startpos":"numpos"})
    df.insert(1, 'read_reduction', str(sum).split("/")[1])
    frames.append(df)

dfall = pd.concat(frames).sort_values(['locus','read_reduction'])


with open(str(snakemake.output), "w") as outhtml:
    outhtml.write(tabtitle)
    dfall.to_html(buf=outhtml,header=True,index=False,justify="center")