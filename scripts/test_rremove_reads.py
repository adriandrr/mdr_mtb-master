import random

samfile = "backup/results/mapped/10_S4.sorted.sam"
perc = 1-(99.9 / 100)
samdict= {}
with open(samfile, "r") as samnum, open(samfile, "r") as insam, open("results/10_S4.rd20.sam", "w") as outsam:
    num_lines = sum(1 for x in samnum)
    lines = insam.readlines()
    take = int(num_lines * perc)
    linidx = random.sample(range(6,num_lines-1),take)
    linidx.sort()
    for number, line in enumerate(lines):
        samdict[number] = line
        if number < 6:
            print(line)
            outsam.write(line)
    for ran in linidx:
        outsam.write(samdict[ran])