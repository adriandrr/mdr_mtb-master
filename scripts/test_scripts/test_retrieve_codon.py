import csv
import pandas as pd

from Bio import SeqIO
from Bio.Seq import Seq

# The refcodinfo_to_codon function takes the reference genome position
# together with the Codon-position of the mutation and utilizes SeqIo
# to retrieve the full Codon in the correct reading frame

genome = "resources/genomes/mtb-genome.fna"
record = SeqIO.read(genome, "fasta")
gene_pos = pd.read_csv("resources/gene_loci.csv", header=0, index_col=0)


def refcodinfo_to_codon(Genome_position, Codon_position, Gene):
    genpos = Genome_position
    codpos = Codon_position
    gene = Gene
    if is_gene_complement(gene) == False:
        if codpos == 1:
            return record.seq[genpos - 1 : genpos + 2]
        if codpos == 2:
            return record.seq[genpos - 2 : genpos + 1]
        if codpos == 3:
            return record.seq[genpos - 3 : genpos]
    elif is_gene_complement(gene) == True:
        if codpos == 1:
            return record.seq[genpos - 1 : genpos + 2].reverse_complement()
        if codpos == 2:
            return record.seq[genpos - 2 : genpos + 1].reverse_complement()
        if codpos == 3:
            return record.seq[genpos - 3 : genpos].reverse_complement()
    else:
        raise ValueError("gene could not be found")


def codon_to_as(Codon):
    codon = Seq(str(Codon))
    try:
        return codon.translate()
    except:
        return ""


def is_gene_complement(gene):
    if "c" in gene_pos.loc[gene].values[0]:
        return True
    else:
        return False


def varcodinfo_to_codon(Codon, Codon_position, Variant, Gene):
    codon = Codon
    codpos = Codon_position
    variant = Variant
    gene = Gene
    if is_gene_complement(gene) == False:
        if len(variant) == 1 and len(variant[0]) == 1:
            codon = list(codon)
            codon[codpos - 1] = str(variant[0])
            codon = "".join(codon)
            return codon
        else:
            return variant  # TODO: write function to return
    elif is_gene_complement(gene) == True:
        if len(variant) == 1 and len(variant[0]) == 1:
            print("1 " + str(codon))
            codon = codon.reverse_complement()
            print("2 " + str(codon))
            codon = list(codon)
            codon[codpos - 1] = str(variant[0])
            codon = "".join(codon)
            print("3 " + str(codon))
            codon = Seq(codon)
            print("4 " + str(codon.reverse_complement()))
            return codon.reverse_complement()
        else:
            return variant
    else:
        raise ValueError("gene could not be found")


def print_stuff(Genome_position, Codon_position, Variant, Gene):
    print(Gene, Genome_position, Codon_position, Variant)
    retcod = refcodinfo_to_codon(Genome_position, Codon_position, Gene)
    print("ref codon: " + str(retcod))
    revretaac = codon_to_as(retcod)
    print("ref aas: " + str(revretaac))
    var = varcodinfo_to_codon(retcod, Codon_position, Variant, Gene)
    print("var codon: " + str(var))
    revretaas = codon_to_as(var)
    print("var aas: " + str(revretaas) + "\n")


"""print_stuff(7362,1,"C","gyrA")
print_stuff(4407588,3,"C","gidB")
print("recordshosch")
print(record.seq[4407585:4407588])"""

print_stuff(2726192, 2, "T", "ahpC-promoter-size-180bp")
