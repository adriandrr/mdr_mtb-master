from Bio import SeqIO
from Bio.Seq import Seq
import pandas as pd

genome = "resources/genomes/mtb-genome.fna"
gene_pos = pd.read_csv("resources/gene_loci.csv", header=0, index_col=0)
record = SeqIO.read(genome, "fasta")

# Retrieves the full codon at the given genome position and mutation codon position.
# Handles complement and non-complement variants accordingly.

def refcodinfo_to_codon(genome_position, codon_position, gene):
    genpos = genome_position
    codpos = codon_position
    is_complement = is_gene_complement(gene)
    if is_complement == False:
            return record.seq[genpos - codpos : genpos + 3 - codpos]
    elif is_complement == True:
        return record.seq[genpos - 1 : genpos + 2].reverse_complement()
    else:
        raise ValueError("gene could not be found")

# Converts a codon considering the mutation position.
# Handles complement and non-complement variants accordingly.

def varcodinfo_to_codon(codon, codon_position, variant, gene):
    if is_gene_complement(gene):
        codon = codon.reverse_complement()
    codon = list(codon)
    codon[codon_position - 1] = str(variant[0]) if len(variant) == 1 and len(variant[0]) == 1 else variant
    if all(isinstance(x, str) for x in codon):
        codon = "".join(codon)
        return codon if not is_gene_complement(gene) else Seq(codon).reverse_complement()
    else:
        return codon

# Translates a base codon to an amino acid.

def codon_to_as(Codon):
    codon = Seq(str(Codon))
    try:
        return codon.translate()
    except:
        return ""

# Checks if a gene is complement or not.

def is_gene_complement(gene):
    return "c" in gene_pos.loc[gene].values[0]