import altair as alt
import pandas as pd
import warnings

warnings.simplefilter(action="ignore", category=FutureWarning)
alt.data_transformers.disable_max_rows()

abresprofile = str(snakemake.input[0])
depthprofile = str(snakemake.input[1])
output = snakemake.output[0]
plotcaption = "Resistance plot " + str(snakemake.params)

df = pd.read_csv(depthprofile, header=0, sep=",")
df["Gene"] = df["Gene"].str.split("_").str[0]

df2 = pd.read_csv(abresprofile, header=0, sep="\t")
df2["Mut_gene"] = df2["Mut_gene"].str.split("_").str[0]
lsmut = []
lslocmut = []
for i in range(df2.shape[0]):
    lsmut.append(
        df2.loc[i]["Ref_Codon"] + str(df2.loc[i]["Codon_num"]) + df2.loc[i]["Alt_Codon"]
    )
    lslocmut.append(
        df2.loc[i]["Mut_gene"]
        + "_"
        + df2.loc[i]["Ref_Codon"]
        + str(df2.loc[i]["Codon_num"])
        + df2.loc[i]["Alt_Codon"]
    )
df2["Mutation"] = lsmut
df2["LocMutation"] = lslocmut

selector = alt.selection_single(empty="all", fields=["Gene"])
intervall_selector = alt.selection_interval(empty="all", encodings=["x"])

base = alt.Chart(df).transform_calculate(
    color='datum.Antibiotic !== "-" ? "red" : "lightgrey"'
)

base_selector = base.add_selection(selector)

barchart = (
    base_selector.mark_bar()
    .encode(
        x=alt.X("Gene:O", title=None, axis=alt.Axis(labelAngle=-45)),
        y=alt.Y("mean(Depth)",scale=alt.Scale(type="log")),
        color=alt.condition(selector, alt.value("#1f77b4"), alt.value("lightgrey")),
        tooltip = alt.Tooltip(["mean(Depth)"],format='.2f')
    ).properties(title="Mean Depth per locus", width=780, height=200)
)

poschart = (
    base_selector.mark_bar()
    .encode(x="Position", y="Depth", color=alt.Color("color:N", scale=None),)
    .transform_filter(selector)
    .add_selection(intervall_selector)
    .properties(title="Locus specific depth", width=350, height=200)
)

zoom_chart = (
    base.mark_bar()
    .encode(
        x="Position",
        y="Depth",
        color=alt.Color("color:N", scale=None),
        tooltip=["Mutation:N", "Antibiotic:N","Depth"],
    ).transform_filter(intervall_selector)
    .properties(title="Zoomed locus specific depth", width=350, height=200)
)

base2 = alt.Chart(df2).transform_calculate(
    color = 'datum.Resistance !== "-" ? "red" : "blue"',
).encode(
    x=alt.X("Resistance",sort=["Resistance"],axis=alt.Axis(
        orient="top",labelAngle=35,labelFontSize=10,tickWidth=0,domain=False)
        ),
).properties(width=360,height=100)

res = (
    base2.mark_circle(size=1800).encode(color = alt.Color("color:N", scale = None))
    + base2.mark_text(size=12).encode(text="Mut_gene")
    + base2.mark_text(dy=28, size=7).encode(text="Mutation")
)

qual = (
    alt.Chart(df2)
    .mark_bar(color="#1f77b4")
    .encode(
        x=alt.X("LocMutation",sort=["Resistance"],axis=alt.Axis(
                orient="top", labelAngle=35, title="Mutation specifics", tickWidth=0
            ),
        ),
        y=alt.Y("Read_depth",scale=alt.Scale(type="log"),axis=alt.Axis(title= "Read depth")),
        tooltip=["Var_Qual", "Read_depth"],
    ).properties(width=360, height=100)
)


plot = alt.vconcat((res | qual), barchart, (poschart | zoom_chart),title=alt.TitleParams(
    text=plotcaption,anchor="middle",fontWeight="bold",fontSize=20))
plot.save(snakemake.output[0])
