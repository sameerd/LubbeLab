#!/usr/bin/env python

# Extract useful information from survivor merged and annotated file

# To run this under quest first start with 
# module load python 

import sys
import vcf
import six

input_file = sys.argv[1]
match_pattern = sys.argv[2]

vcf_reader = vcf.Reader(filename=input_file)

samples = vcf_reader.samples
num_samples = len(samples)

# create gnomAD dictionary
gnomAD_dict = {}
with open("/projects/b1049/genetics_refs/gnomad_v2_sv.sites.bed") as fh:
    header = fh.next().strip().split("\t")

    protein_coding_cols = ["PROTEIN_CODING__LOF", "PROTEIN_CODING__DUP_LOF",
            "PROTEIN_CODING__COPY_GAIN", "PROTEIN_CODING__DUP_PARTIAL",
            "PROTEIN_CODING__MSV_EXON_OVR", "PROTEIN_CODING__INTRONIC",
            "PROTEIN_CODING__INV_SPAN", "PROTEIN_CODING__UTR",
            "PROTEIN_CODING__NEAREST_TSS", "PROTEIN_CODING__INTERGENIC",
            "PROTEIN_CODING__PROMOTER"]

    extract_cols = ["NAME", "SVTYPE", "FREQ_HOMREF", "FREQ_HET", 
            "FREQ_HOMALT"] + protein_coding_cols
    extract_idx = [header.index(e) for e in extract_cols]
    for line in fh:
        linesp = line.strip().split("\t")
        line_dict = dict(zip(extract_cols, (linesp[i] for i in extract_idx)))
        gnomAD_dict[line_dict["NAME"]] = line_dict

# reading genecode bed file
# create a master dictionary of gene_id linked to gene_names etc
#genecode_dict = {}
#with open("/projects/b1049/genetics_refs/gencode.gene.bed") as fh:
#    for line in fh:
#        info = line.split("\t")[9].rstrip()
#        info_dict = dict((x[0], x[1].replace('"', "")) for 
#                x in map(str.split, info.split(";")) if len(x) != 0)
#        genecode_dict[info_dict["gene_id"]] = info_dict

# read in MDS gene list
mds_set = None
with open("data/input/mds_genes.txt") as fh:
    mds_set = set(line.strip() for line in fh)

def print_line(l):
    print("\t".join(map(str, l))) 

output_cols = [ "CHROM", "POS", "END" , "SURV_TYPE", "SVLEN", "QUAL", "SUPP_VEC"]
output_cols += samples
output_cols += [x + "_SUPP" for x in samples]
output_cols += ["NUM_ANN", "MDSGENE"]
output_cols += extract_cols

print_line(output_cols)

for record in vcf_reader:
    supp_vec = record.INFO["SUPP_VEC"]
    if len(supp_vec) != num_samples:
        raise ValueError, "Length of support vector is not the length of the samples"
    if supp_vec == match_pattern: # match the disease pattern
        output_values = [record.CHROM, record.POS, record.INFO["END"], 
                record.INFO["SVTYPE"], record.INFO["SVLEN"], record.QUAL, 
                record.INFO["SUPP_VEC"] ]
        calls = [record.genotype(s) for s in samples]
        output_values += [c.data.GT for c in calls]
        # put a string "v" in front of the PSV data so that 
        # spreadsheet programs do not truncate the leading zeros
        output_values += ["v" + c.data.PSV for c in calls] 
        ta = None # total annotations
        if "total_Annotations" in record.INFO: 
            # We have multiple annotations so we need to create new records
            ta = record.INFO["total_Annotations"][0]
            if ta != '0':
                # duplicate line for each overlapped_Annotations
                for annotation in record.INFO["overlapped_Annotations"]:
                    gd = gnomAD_dict[annotation]
                    print_line(output_values + 
                       [ta, gd["PROTEIN_CODING__NEAREST_TSS"] in mds_set] +
                       list(gd[e] for e in extract_cols) ) 
        if ta is None or ta == '0': # print without annotations
            print_line(output_values + ["0", "NA"] + ["NA"]*len(extract_cols) )

