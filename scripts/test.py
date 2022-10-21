def varcodinfo_to_codon(Codon, Codon_position, Variant):
    codon = Codon
    codpos = Codon_position
    variant = Variant
    if len(variant) == 1 and len(variant[0]) == 1:
        codon = list(codon)
        codon[codpos-1] = variant[0]
        codon = ''.join(codon)
        return codon
    else: 
        return "TODO"

print(varcodinfo_to_codon("CTA",3,['G']))