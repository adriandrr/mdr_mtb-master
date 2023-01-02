# A script which randomly removes a certain number of lines from a samfile

import random

perc = 1 - (int(snakemake.params.red) / 100)
if perc == 1:
    with open(str(snakemake.input), "r") as insam, open(str(snakemake.output), "w") as outsam:
        lines = insam.readlines()
        for line in lines:
            outsam.write(line)
else:
    samdict = {}
    with open(str(snakemake.input), "r") as insam, open(str(snakemake.output), "w") as outsam:
        lines = insam.readlines()
        num_lines = len(lines)        
        keep = int(num_lines * perc)
        linidx = random.sample(range(6, num_lines - 1), keep)
        linidx.sort()
        for number, line in enumerate(lines):
            samdict[number] = line
            if number < 6:
                outsam.write(line)
        for ran in linidx:
            outsam.write(samdict[ran])
