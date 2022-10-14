import pandas as pd

gene_pos = pd.read_csv("resources/gene_loci.csv" , header = 0, index_col = 0)

def genomeidx_to_codon(genomeidx):
    notfound = 0
    i = 0
    while notfound == 0:
        gene = gene_pos.index[i]
        print(gene)
        if int(find_gene_coords(gene)[0]) <= genomeidx <= int(find_gene_coords(gene)[1]):
            notfound = 1
            print(gene + " found")
            break
        else:
            i = i+1
            continue

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
    return coordlist

print(genomeidx_to_codon(5500))