import altair as alt
import pandas as pd
import warnings

warnings.simplefilter(action="ignore", category=FutureWarning)
alt.data_transformers.disable_max_rows()

abresprofile = snakemake.input.res
depthprofile = snakemake.input.depth
output = snakemake.output[0]

lis = []
for abres,depth in zip(abresprofile,depthprofile):
    df = pd.read_csv(depth, header = 0, sep = ',')
    df2 = pd.read_csv(abres, header = 0, sep = ',')    
    
    df["Gene"]=df["Gene"].str.split('_').str[0]
    df2["Mut_gene"]=df2["Mut_gene"].str.split('_').str[0]
    lsmut = []
    lslocmut = []
    for i in range(df2.shape[0]):
        lsmut.append(df2.loc[i]["Ref_Codon"]+str(df2.loc[i]["Codon_num"])+df2.loc[i]["Alt_Codon"])
        lslocmut.append(df2.loc[i]["Mut_gene"]+"_"+df2.loc[i]["Ref_Codon"]+str(df2.loc[i]["Codon_num"])+df2.loc[i]["Alt_Codon"])
    df2["Mutation"]=lsmut
    df2["LocMutation"]=lslocmut
    barchart = alt.Chart(df).mark_bar(color = "#1f77b4").encode(
        x=alt.X("Gene:O", title = None,axis=alt.Axis(labelAngle=-45)),
        y=alt.Y("mean(Depth)",scale=alt.Scale(type="log")),
        tooltip = alt.Tooltip(["mean(Depth)"],format='.2f')
    ).properties(title="Mean Depth per locus",width = 780, height = 200)

    base2 = alt.Chart(df2).transform_calculate(
        color = 'datum.Resistance !== "-" ? "red" : "blue"',
    ).encode(
        x=alt.X("Resistance",sort=["Resistance"],axis=alt.Axis(orient="top",labelAngle=35,labelFontSize=10,tickWidth=0,domain=False)),
    ).properties(width=360,height=100)

    res = (base2.mark_circle(size=1800).encode(color = alt.Color("color:N", scale = None)) +
           base2.mark_text(size=12).encode(text="Mut_gene") +
           base2.mark_text(dy=28,size=7).encode(text="Mutation"))

    qual = alt.Chart(df2).mark_bar(color="#1f77b4").encode(
        x=alt.X("LocMutation",sort=["Resistance"],axis=alt.Axis(orient="top",labelAngle=35,title="Mutation specifics",tickWidth=0)),
        y=alt.Y("Read_depth",scale=alt.Scale(type="log"),axis=alt.Axis(title= "Read depth")),
        tooltip = ["Var_Qual","Read_depth"]
    ).properties(width=360,height=100)
    lis.append(alt.vconcat((res | qual), barchart,title=alt.TitleParams(
        text=str(snakemake.params)+" resistance plot -"+abres.split("/")[1]+"%",anchor="middle",fontWeight="bold",fontSize=20)))
a=alt.vconcat(*lis)
a.save(snakemake.output[0])