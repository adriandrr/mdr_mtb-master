# This script gathers information from result files and plots it in an interactive altair plot

import pandas as pd
import altair as alt
import warnings
from altair.expr import datum, if_

alt.data_transformers.disable_max_rows()
warnings.simplefilter(action='ignore', category=FutureWarning)
warnings.simplefilter(action='ignore', category=UserWarning)

abresprofile = snakemake.input.res
depthprofile = snakemake.input.depth

lis = []
for abres,depth in zip(abresprofile,depthprofile):
    ab_df = pd.read_csv(abres, header = 0, sep = ',')
    dp_df = pd.read_csv(depth, header = 0, sep = ',')    
    
    dp_df["Gene"]=dp_df["Gene"].str.split('_').str[0]
    ab_df["Mut_gene"]=ab_df["Mut_gene"].str.split('_').str[0]
    lsmut = []
    lslocmut = []
    for i in range(ab_df.shape[0]):
        lsmut.append(ab_df.loc[i]["Ref_Codon"]+str(ab_df.loc[i]["Codon_num"])+ab_df.loc[i]["Alt_Codon"])
        lslocmut.append(ab_df.loc[i]["Mut_gene"]+"_"+ab_df.loc[i]["Ref_Codon"]+str(ab_df.loc[i]["Codon_num"])+ab_df.loc[i]["Alt_Codon"])
    ab_df["Mutation"]=lsmut
    ab_df["LocMutation"]=lslocmut

    barchart = alt.Chart(dp_df).mark_bar(color = "#1f77b4").encode(
        x=alt.X("Gene:O", title = None,axis=alt.Axis(labelAngle=-45)),
        y=alt.Y("mean(Depth)",scale=alt.Scale(type="log")),
    ).properties(title="Mean Depth per locus",width = 800, height = 200)

    base2 = alt.Chart(ab_df).transform_calculate(
        color = 'datum.Var_Qual >= 1 ? "red" : "orange"',
    ).encode(
        x=alt.X("Resistance",sort=["Resistance"],axis=alt.Axis(orient="top",labelAngle=35,labelFontSize=10,tickWidth=0,domain=False)),
    ).properties(width=360,height=100)

    res = (base2.mark_circle(size=1800).encode(color = alt.Color("color:N", scale = None)) +
           base2.mark_text(size=12).encode(text="Mut_gene") +
           base2.mark_text(dy=28,size=7).encode(text="Mutation")).transform_filter(datum.Mut_status == "res_mut")

    qual = alt.Chart(ab_df).mark_bar(color="#1f77b4").encode(
        x=alt.X("LocMutation",sort=["Resistance"],axis=alt.Axis(orient="top",labelAngle=35,title="Mutation specifics",tickWidth=0)),
        y=alt.Y("Read_depth",scale=alt.Scale(type="log"),axis=alt.Axis(title= "Read depth")),
        tooltip = ["Var_Qual","Read_depth"]
    ).properties(width=360,height=100).transform_filter(datum.Mut_status == "res_mut")

    lis.append(alt.vconcat((res | qual), barchart,title=alt.TitleParams(
        text=str(snakemake.params)+" resistance plot -"+abres.split("/")[1]+"%",anchor="middle",fontWeight="bold",fontSize=20)))
a=alt.vconcat(*lis)
a.save(snakemake.output[0])