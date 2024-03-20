import sys
import re
import argparse
import pandas as pd

gene_pos = pd.read_csv("resources/gene_loci.csv", header=0, index_col=0)

def main(pos):
    parser = argparse.ArgumentParser(
        description="Enter genome position and retrieve gene, codon number and codon position"
    )
    parser.add_argument("-p", "--position", type=int, required=True)
    pos = parser.parse_args(pos)
    genomeidx_to_gene(pos.position)

# genomeidx_to_gene iterates through genes and coordinates to find the gene containing 
# the given genome position. It returns the gene and associated codon information.

def genomeidx_to_gene(genomeidx):
    for gene, coords in gene_pos.iterrows():
        start, end = map(int, coords[0].replace("c", "").split("-"))
        if start <= genomeidx <= end or end <= genomeidx <= start:
            return [genomeidx_and_gene_to_codon(genomeidx, gene), gene]

# genomeidx_and_gene_to_codon converts genome position and gene into codon details:
# codon number, position in gene, and position in codon.

def genomeidx_and_gene_to_codon(genomeidx, gene):
    promdiff = 0
    if "promoter" in gene:
        promdiff = int(re.search(r"size_(.*?)bp", gene).group(1))
    start, end = find_gene_coords(gene)
    is_complement = is_gene_complement(gene)
    position = end - genomeidx - promdiff if is_complement else genomeidx - start - promdiff
    position -= 1 if position < 0 else 0
    codon_position = (position % 3) + 1
    codon_index = int((position - codon_position + 3) / 3) + 1
    codon_position = abs(codon_position - 4) if is_complement else codon_position
    return [codon_index, position + 1, codon_position]

# find_gene_coords returns the correct order of start and end coordinates for a given gene.

def find_gene_coords(gene):
    coords = gene_pos.loc[gene].values[0]
    start, end = map(int, coords.replace("c", "").split("-"))
    return [end, start] if "c" in coords else [start, end]

# is_gene_complement returns True if the gene is a complement gene, False otherwise.

def is_gene_complement(gene):
    return "c" in gene_pos.loc[gene].values[0]

if __name__ == "__main__":
    main(sys.argv[1:])