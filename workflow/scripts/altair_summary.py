# This script gathers information from result files and plots it in an interactive altair plot

import pandas as pd
import altair as alt
import warnings

warnings.simplefilter(action="ignore", category=FutureWarning)
alt.data_transformers.disable_max_rows()

dfres = pd.read_csv(str(snakemake.input), header=0, sep=",")
dfres["Sample"] = dfres["Sample"].str.split("_").str[0]
dfres["resistance"] = dfres["resistance"].replace(
    {
        "RIFAMPICIN": "RIF",
        "ISONIAZID": "INH",
        "KANAMYCIN": "KAN",
        "PYRAZINAMIDE": "PZA",
        "ETHAMBUTOL": "EMB",
        "ETHIONAMIDE": "ETH",
        "STREPTOMYCIN": "SM",
        "FLUOROQUINOLONE": "FQ",
    }
)
sorting = [
    "RIF",
    "INH",
    "PZA",
    "EMB",
    "SM",
    "FQ",
    "KAN",
    "AMI",
    "CAP",
    "ETH",
    "LIN",
    "BDQ",
    "CFZ",
]

plot = (
    alt.Chart(dfres)
    .mark_rect(stroke="black", strokeWidth=0.1)
    .encode(
        y=alt.Y("Sample:O", sort=dfres["Sample"].to_list()),
        x=alt.X(
            "resistance:O",
            axis=alt.Axis(orient="top", title="Resistotype", tickWidth=0),
            sort=sorting,
        ),
        color=alt.Color(
            "quality",
            scale=alt.Scale(
                domain=[0, 1, 2, 3],
                range=["lightgrey", "yellow", "orange", "red"],
                interpolate="rgb",
            ),
            title="Variant quality",
        ),
        tooltip=["locus", "mutation", "quality"],
    )
    .properties(title="Resistances MYCRes")
)

plot.save(snakemake.output[0], embed_options={"renderer": "svg"})
