import pandas as pd
from Bio import SeqIO
import vcf

gene_pos = pd.read_csv("resources/gene_loci.csv" , header = 0, index_col = 0)
genome = "resources/genomes/mtb-genome.fna"
record = SeqIO.read(genome, "fasta")

def varcodinfo_to_codon(Codon, Codon_position, Variant):
    codon = Codon
    codpos = Codon_position
    variant = Variant
    print("infunction: {}".format(variant))
    print(len(variant))
    print(len(variant[0]))
    if len(variant) == 1 and len(variant[0]) == 1:
        codon = list(codon)
        codon[codpos-1] = variant[0]
        codon = ''.join(codon)
        return codon
    else: 
        return variant

def refcodinfo_to_codon(Genome_position, Codon_position):
    genpos = Genome_position
    codpos = Codon_position
    if codpos == 1:
        return record.seq[genpos-1:genpos+2]
    if codpos == 2:
        return record.seq[genpos-2:genpos+1]
    if codpos == 3:
        return record.seq[genpos-3:genpos]

def genomeidx_to_gene(genomeidx):
    notfound = 0
    i = 0
    while notfound == 0:
        gene = gene_pos.index[i]
        if int(find_gene_coords(gene)[0]) <= genomeidx <= int(find_gene_coords(gene)[1]):
            notfound = 1
            #print([genomeidx_and_gene_to_codon(genomeidx, gene),gene])
            return [genomeidx_and_gene_to_codon(genomeidx, gene),gene]
            break
        else:
            i = i+1
            continue
# find_gene_coords takes the gene name as input and returns 
# the correct order of start and end coordinate
# The entry in the genedatabase has to be configured like this:
# eis,c2715332-2714124
# the "c" defines if it is a complement (e.g. "reverse") gene 

def find_gene_coords(gene):
    coordlist = []
    coords = gene_pos.loc[gene].values[0]
    if "c" in coords:
        coords = coords.replace('c','')
        coordlist.append(coords.split("-")[1])
        coordlist.append(coords.split("-")[0])
    else:
        coordlist.append(coords.split("-")[0])
        coordlist.append(coords.split("-")[1])
    coordlist = [ int(x) for x in coordlist]
    return coordlist

# is_gene_complement takes the gene name as input and returns True for a complement gene
# and false if not so

def is_gene_complement(gene):
    if "c" in gene_pos.loc[gene].values[0]:
        return True
    else:
        return False

# genomeidx_and_gene_to_codon takes the initial given genome position and the retrieved gene
# as input and converts this information to the codon number in the gene together with the 
# actual position in the gene and in the codon

def genomeidx_and_gene_to_codon(genomeidx, gene):
    if is_gene_complement(gene) == True:
        START = find_gene_coords(gene)[1]
        POSITION = START - genomeidx    
    elif is_gene_complement(gene) == False:
        START = find_gene_coords(gene)[0]
        POSITION = genomeidx - START
    if POSITION % 3 == 0:
        return [int((POSITION / 3)) + 1, POSITION + 1, 1]
    elif POSITION % 3 == 1:
        return [int(((POSITION - 1) / 3)) + 1, POSITION + 1, 2]
    elif POSITION % 3 == 2:
        return [int(((POSITION - 2) / 3)) + 1, POSITION + 1, 3]

cod = genomeidx_to_gene(2289068)
retcod = refcodinfo_to_codon(2289068,cod[0][2])
print(retcod)

v = vcf.Reader(filename="results/variants/AD_4/AD_4_pncA.vcf")
for recs in v:
    print(recs.INFO["TYPE"])
    #print(varcodinfo_to_codon(retcod, cod[0][2], recs.ALT))
v2 = vcf.Reader(filename="results/variants/AD_4/AD_4_katG.vcf")
for recs in v2:
    print(recs.INFO["TYPE"])
    if len(recs.INFO["TYPE"]) == 1 and recs.INFO["TYPE"][0] == 'snp':
        print("yey")
    else:
        print("ney") 