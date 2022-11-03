import random

samfile = str(snakemake.input)

perc = 1-( int(snakemake.params[0]) / 100)
samdict= {}

with open(samfile, "r") as samnum, open(samfile, "r") as insam, open(str(snakemake.output), "w") as outsam:
    num_lines = sum(1 for x in samnum)
    lines = insam.readlines()
    keep = int(num_lines * perc)
    linidx = random.sample(range(6,num_lines-1),keep)
    linidx.sort()
    for number, line in enumerate(lines):
        samdict[number] = line
        if number < 6:
            outsam.write(line)
    for ran in linidx:
        outsam.write(samdict[ran])