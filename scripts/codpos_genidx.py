import sys
import argparse
import pandas as pd

gene_pos = pd.read_csv("resources/gene_loci.csv" , header = 0, index_col = 0)

def main(pos):
    parser = argparse.ArgumentParser(description="Enter genome position and retrieve gene, codon number and codon position")
    parser.add_argument("-p", "--position", type=int, required=True)
    pos = parser.parse_args(pos)
    genomeidx_to_gene(pos.position)
    
# genomeidx_to_gene takes genome position as argument and iterates through pandas list
# of genes and respective coordinates (not really effective). When a range of coordinates where
# the given argument is in between is found, the gene is returned together with the output
# of another function which gives [Codonnumber, Position in gene, Position in Codon] a output.

def genomeidx_to_gene(genomeidx):
    notfound = 0
    i = 0
    while notfound == 0:
        gene = gene_pos.index[i]
        if int(find_gene_coords(gene)[0]) <= genomeidx <= int(find_gene_coords(gene)[1]):
            notfound = 1
            print([genomeidx_and_gene_to_codon(genomeidx, gene),gene])
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
        if POSITION % 3 == 0:
            return [int((POSITION / 3)) + 1, POSITION + 1, 3]
        elif POSITION % 3 == 1:
            return [int(((POSITION - 1) / 3)) + 1, POSITION + 1, 2]
        elif POSITION % 3 == 2:
            return [int(((POSITION - 2) / 3)) + 1, POSITION + 1, 1]
    elif is_gene_complement(gene) == False:
        START = find_gene_coords(gene)[0]
        POSITION = genomeidx - START
        if POSITION % 3 == 0:
            return [int((POSITION / 3)) + 1, POSITION + 1, 1]
        elif POSITION % 3 == 1:
            return [int(((POSITION - 1) / 3)) + 1, POSITION + 1, 2]
        elif POSITION % 3 == 2:
            return [int(((POSITION - 2) / 3)) + 1, POSITION + 1, 3]

if __name__ == "__main__":
    main(sys.argv[1:])