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

output_cols = [ "CHROM", "POS", "END" , "SVTYPE", "SVLEN", "QUAL", "SUPP_VEC"]
output_cols += samples
output_cols += [x + "_SUPP" for x in samples]
output_cols += ["NUM_ANN", "ANNOTATION", "GENE_NAME", "GENE_TYPE", "MDS_GENE" ]

# reading genecode bed file
# create a master dictionary of gene_id linked to gene_names etc
genecode_dict = {}
with open("/projects/b1049/genetics_refs/gencode.gene.bed") as fh:
    for line in fh:
        info = line.split("\t")[9].rstrip()
        info_dict = dict((x[0], x[1].replace('"', "")) for 
                x in map(str.split, info.split(";")) if len(x) != 0)
        genecode_dict[info_dict["gene_id"]] = info_dict

# read in MDS gene list
mds_set = None
with open("data/input/mds_genes.txt") as fh:
    mds_set = set(line.strip() for line in fh)

def print_line(l):
    print("\t".join(map(str, l))) 

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
        output_values += [c.data.PSV for c in calls]
        ta = None # total annotations
        if "total_Annotations" in record.INFO: 
            # We have multiple annotations so we need to create new records
            ta = record.INFO["total_Annotations"][0]
            if ta != '0':
                for annotation in record.INFO["overlapped_Annotations"]:
                    gd = genecode_dict[annotation]
                    print_line(output_values + [ta, annotation, gd["gene_name"], 
                        gd["gene_type"], gd["gene_name"] in mds_set]) 
        if ta is None or ta == '0': # print without annotations
            print_line(output_values + ["0", ".", ".", ".", "."])

