import pandas as pd

depthsum = snakemake.input
tabtitle = str(snakemake.params) + " coverage summary"

def color_zero_red(val):
    color = 'red' if val == 0 else 'black'
    return 'color: %s' % color

tablestyle = [
    dict(selector="tr:hover",
                props=[("background", "#f4f4f4")]),
    dict(selector="th", props=[("color", "black"),
                               ("border", "1px solid #eee"),
                               ("padding", "13px 25px"),
                               ("border-collapse", "collapse"),
                               ("background", "lightgrey"),
                               ("font-size", "15px")
                               ]),
    dict(selector="td", props=[("border", "1px solid #eee"),
                               ("background", "white"),
                               ("font-size", "15px"),
                               ("border-collapse", "collapse"),
                               ]),
    dict(selector="caption", props=[("padding", "8px"),
                                    ("font-size", "18px"),
                                    ("background", "lightgrey"),
                                     ("caption-side", "top")])
]

frames = []
for sum in depthsum:
    df = pd.read_csv(sum, header=0, sep="\t")
    df["#rname"] = df["#rname"].str.split("_").str[0]
    df.insert(1,"locusrange",df["startpos"].astype(str) + "-" + df["endpos"].astype(str))
    df["startpos"] = df["endpos"] - df["startpos"] + 1
    df = df.drop(["endpos"], axis=1)
    df = df.rename(columns={"#rname": "locusname", "startpos": "#positions","numreads": "#reads","covbases": "coveredbases"})
    #df.insert(1, "read_reduction", str(sum).split("/")[1])
    frames.append(df)

dfall = pd.concat(frames).sort_values(["locusname"]).set_index("locusname")

dfall=dfall.style.applymap(color_zero_red) \
.set_properties(**{'text-align':'right'}) \
.format(precision=2) \
.set_caption(tabtitle) \
.set_table_styles(tablestyle)

with open(str(snakemake.output), "w") as outhtml:
    dfall.to_html(buf=outhtml)
