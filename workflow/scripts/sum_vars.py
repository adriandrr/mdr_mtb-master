import vcf
import codpos_genidx as cg
import retrieve_codon as rc

# The Script is meant to be called from the snakemake-rule "create_variant_profile"
# Input are vcf files which are created for every sample
# The Script parses the vcf file and iterates over all variants called
# Two external scripts are called with the variant position
# 1. genomeidx_to_gene gives Codon-infos and gene name
# 2. rescinfo_to_codon gives the whole reference Codon in reading frame
# These information together with various information from the vcf file are gathered
# over all vcf files per sample and safed in a csv-file

with open(str(snakemake.output), "w") as outcsv, open(
    str(snakemake.output).replace(".csv", "_complex.csv"), "w"
) as outcsv2:
    outcsv.writelines(
        "Gene_name,Genome_pos,Gene_pos,Codon_num,Codon_pos,Ref_Codon,Ref_aas,Alt_Codon,Alt_aas,Var_type,Read_depth,Alt_num,Var_Qual\n".replace(
            ",", "\t"
        )
    )
    outcsv2.writelines(
        "Gene_name,Genome_pos,Gene_pos,Codon_num,Codon_pos,Ref_Codon,Ref_aas,Alt_Codon,Alt_aas,Var_type,Read_depth,Alt_num,Var_Qual\n".replace(
            ",", "\t"
        )
    )
    for i in snakemake.input:
        v = vcf.Reader(filename=str(i))
        for recs in v:
            line = []
            res = ""
            cod = cg.genomeidx_to_gene(recs.POS)
            retcod = rc.refcodinfo_to_codon(recs.POS, cod[0][2], cod[1])
            retaac = rc.codon_to_as(retcod)
            varcod = rc.varcodinfo_to_codon(retcod, cod[0][2], recs.ALT, cod[1])
            varaac = rc.codon_to_as(varcod)
            line.extend(
                [
                    cod[1],
                    recs.POS,
                    cod[0][1],
                    cod[0][0],
                    cod[0][2],
                    retcod,
                    retaac,
                    varcod,
                    varaac,
                    recs.INFO["TYPE"],
                ]
            )
            for rec in recs:
                line.extend([rec["DP"], rec["AO"]])
            line.append(int(recs.QUAL))
            for elem in line:
                res += str(elem) + "\t"
            if len(recs.INFO["TYPE"]) == 1 and recs.INFO["TYPE"][0] == "snp":
                outcsv.write(res[:-1] + "\n")
            else:
                outcsv2.write(res[:-1] + "\n")
