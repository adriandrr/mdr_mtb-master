# This script gathers information from result files and plots it in an interactive altair plot

import altair as alt
import pandas as pd
import warnings

warnings.simplefilter(action="ignore", category=FutureWarning)
alt.data_transformers.disable_max_rows()

abresprofile = str(snakemake.input[0])
depthprofile = str(snakemake.input[1])

ab_df = pd.read_csv(abresprofile, header = 0, sep = ',')
dp_df = pd.read_csv(depthprofile, header = 0, sep = ',')

dp_df["Gene"]=dp_df["Gene"].str.split('_').str[0]
ab_df["Mut_gene"]=ab_df["Mut_gene"].str.split('_').str[0]
lsmut = []
lslocmut = []
for i in range(ab_df.shape[0]):
    lsmut.append(ab_df.loc[i]["Ref_Codon"]+str(ab_df.loc[i]["Codon_num"])+ab_df.loc[i]["Alt_Codon"])
    lslocmut.append(ab_df.loc[i]["Mut_gene"]+"_"+ab_df.loc[i]["Ref_Codon"]+str(ab_df.loc[i]["Codon_num"])+ab_df.loc[i]["Alt_Codon"])
ab_df["Mutation"]=lsmut
ab_df["LocMutation"]=lslocmut
ab_df = ab_df[ab_df["Mut_status"] == "res_mut"]

selector = alt.selection_single(empty="all", fields=["Gene"])
intervall_selector = alt.selection_interval(empty="all", encodings=['x'])

base = alt.Chart(dp_df).transform_calculate(
    color = 'datum.Antibiotic !== "-" ? "red" : "lightgrey"',
)

base_selector = base.add_selection(selector)

barchart = base_selector.mark_bar().encode(
    x=alt.X("Gene:O", title = None,axis=alt.Axis(labelAngle=-45)),
    y=alt.Y("mean(Depth):Q",scale=alt.Scale(type="log")),
    tooltip = alt.Tooltip(["mean(Depth)"],format='.2f'),
    color=alt.condition(selector, alt.value("#1f77b4"), alt.value("lightgrey")),
).properties(title="Mean Depth per locus",width = 800, height = 200)

poschart = base_selector.mark_bar().encode(
    x="Position",
    y="Depth",
    color = alt.Color("color:N", scale = None),
).transform_filter(selector).add_selection(intervall_selector).properties(title="Locus specific depth",width = 360, height = 200)

zoom_chart = base.mark_bar().encode(
    x="Position",
    y="Depth",
    color = alt.Color("color:N", scale = None),
    tooltip=["Mutation:N", "Antibiotic:N", "Depth"]
).transform_filter(intervall_selector).properties(title="Zoomed locus specific depth",width = 360, height = 200)


base2 = alt.Chart(ab_df).transform_calculate(
    color = 'datum.Var_Qual >= 1 ? "red" : "orange"',
).encode(
    x=alt.X("Resistance",sort=["Resistance"],axis=alt.Axis(orient="top",labelAngle=35,labelFontSize=10,tickWidth=0,domain=False)),
    tooltip=["AvLocus_Depth", "Read_depth", "Alt_num", "Var_Qual"]
).properties(width=360,height=100)

res = (base2.mark_circle(size=1800).encode(color = alt.Color("color:N", scale = None)) +
       base2.mark_text(size=12).encode(text="Mut_gene") +
       base2.mark_text(dy=28,size=7).encode(text="Mutation"))

qual = alt.Chart(ab_df).mark_bar(color="#1f77b4").encode(
    x=alt.X("LocMutation",sort=["Resistance"],axis=alt.Axis(orient="top",labelAngle=35,title="Mutation specifics",tickWidth=0)),
    y=alt.Y("Read_depth",scale=alt.Scale(type="log"),axis=alt.Axis(title= "Read depth")),
    tooltip = ["Var_Qual","Read_depth"]
).properties(width=360,height=100)

plot = alt.vconcat((res | qual), barchart, (poschart | zoom_chart),title=alt.TitleParams(
    text=str(snakemake.params)+" resistance plot",anchor="middle",fontWeight="bold",fontSize=20))
plot.save(snakemake.output[0], embed_options={'renderer':'svg'})