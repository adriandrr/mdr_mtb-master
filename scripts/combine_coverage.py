import os

with open(str(snakemake.input), "r") as incsv, open(str(snakemake.output), "w") as outcsv:
    if os.stat("outcsv").st_size == 0:
        outcsv.write("\#rname\tstartpos\tendpos\tnumreads\tcovbases\tcoverage\tmeandepth\tmeanbaseq\tmeanmapq")
    outcsv.write(incsv.readlines()[1])