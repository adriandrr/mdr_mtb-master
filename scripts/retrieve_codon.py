from Bio import SeqIO
from Bio.Seq import Seq
import codpos_genidx as cg

# The refcodinfo_to_codon function takes the reference genome position
# together with the Codon-position of the mutation and utilizes SeqIo
# to retrieve the full Codon in the correct reading frame

genome = "resources/genomes/mtb-genome.fna"
record = SeqIO.read(genome, "fasta")

# This function distinguishes between complement and not complement variants
# The given codon will be complemented accordingly


def refcodinfo_to_codon(Genome_position, Codon_position, Gene):
    genpos = Genome_position
    codpos = Codon_position
    gene = Gene
    if cg.is_gene_complement(gene) == False:
        if codpos == 1:
            return record.seq[genpos - 1 : genpos + 2]
        if codpos == 2:
            return record.seq[genpos - 2 : genpos + 1]
        if codpos == 3:
            return record.seq[genpos - 3 : genpos]
    elif cg.is_gene_complement(gene) == True:
        if codpos == 1:
            return record.seq[genpos - 1 : genpos + 2].reverse_complement()
        if codpos == 2:
            return record.seq[genpos - 2 : genpos + 1].reverse_complement()
        if codpos == 3:
            return record.seq[genpos - 3 : genpos].reverse_complement()
    else:
        raise ValueError("gene could not be found")


# This function distinguishes between complement and not complement variants
# in the last case, the codon will be reversed, the variant will be set in
# and the codon will be reversed again


def varcodinfo_to_codon(Codon, Codon_position, Variant, Gene):
    codon = Codon
    codpos = Codon_position
    variant = Variant
    gene = Gene
    if cg.is_gene_complement(gene) == False:
        if len(variant) == 1 and len(variant[0]) == 1:
            codon = list(codon)
            codon[codpos - 1] = str(variant[0])
            codon = "".join(codon)
            return codon
        else:
            return variant  # TODO: write function to return
    elif cg.is_gene_complement(gene) == True:
        if len(variant) == 1 and len(variant[0]) == 1:
            codon = codon.reverse_complement()
            codon = list(codon)
            codon[codpos - 1] = str(variant[0])
            codon = "".join(codon)
            codon = Seq(codon)
            return codon.reverse_complement()
        else:
            return variant
    else:
        raise ValueError("gene could not be found")
