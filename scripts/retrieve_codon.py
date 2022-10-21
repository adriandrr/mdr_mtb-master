from Bio import SeqIO

# The refcodinfo_to_codon function takes the reference genome position
# together with the Codon-position of the mutation and utilizes SeqIo
# to retrieve the full Codon in the correct reading frame

genome = "resources/genomes/mtb-genome.fna"
record = SeqIO.read(genome, "fasta")

def refcodinfo_to_codon(Genome_position, Codon_position):
    genpos = Genome_position
    codpos = Codon_position
    if codpos == 1:
        return record.seq[genpos-1:genpos+2]
    if codpos == 2:
        return record.seq[genpos-2:genpos+1]
    if codpos == 3:
        return record.seq[genpos-3:genpos]

def varcodinfo_to_codon(Codon, Codon_position, Variant):
    codon = Codon
    codpos = Codon_position
    variant = Variant
    if len(variant) == 1 and len(variant[0]) == 1:
        codon = list(codon)
        codon[codpos-1] = str(variant[0])
        codon = "".join(codon)
        return codon
    else: 
        return "TODO"
#TODO: write function to return 