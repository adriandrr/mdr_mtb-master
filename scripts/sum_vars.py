import sys
import vcf
import Codpos_genidx as cg
import retrieve_codon as rc

# The Script is meant to be called from the snakemake-rule "create_variant_profile"
# Input are vcf files which are created for every sample
# The Script parses the vcf file anditerates over all variants called
# Two external scripts are called with the variant position
    # 1. genomeidx_to_gene gives Codon-infos and gene name
    # 2. rescinfo_to_codon gives the whole reference Codon in reading frame
# These information together with various information from the vcf file are gathered
# over all vcf files per sample and safed in a csv-file

with open(str(snakemake.output), "w") as outcsv:
    outcsv.writelines("Gene_name,Gene_pos,Codon_num,Codon_pos,Genome_pos,Ref_Codon,Ref_nuc,Alt_codon,Var_type,Read_depth,Alt_num,Ref:Alt,Var_Qual\n")
    for i in snakemake.input:
        v = vcf.Reader(filename=str(i))
        for recs in v:
            line = []
            res = ""
            cod = cg.genomeidx_to_gene(recs.POS)
            retcod = rc.refcodinfo_to_codon(recs.POS,cod[0][2])
            varcod = rc.varcodinfo_to_codon(retcod, cod[0][2], recs.ALT)
            line.extend(
                [cod[1], cod[0][1], cod[0][0], cod[0][2], 
                recs.POS, retcod, recs.REF, recs.ALT, varcod, recs.INFO["TYPE"]]
                )
            for rec in recs:
                line.extend([rec["DP"],rec["AO"],rec["AD"]])
            line.append(int(recs.QUAL))
            for elem in line:
                res += str(elem)+","
            outcsv.write(res[:-1]+"\n")