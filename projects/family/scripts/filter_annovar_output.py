""" Read in the annovar file and the otherinfo headers and then filter based on columns """

import sys

annovar_output_file = sys.argv[1]
otherinfo_headers_file = sys.argv[2]

otherinfo_headers = []
# read in the otherinfo headers
with file(otherinfo_headers_file) as fh:
  otherinfo_headers = fh.readline().strip().split("\t")

fh = file(annovar_output_file)
annovar_headers = fh.readline().strip().split("\t")

# remove otherinfo (last element) from annovar_headers 
# and merge in the real otherheaders
# NOTE: There are three random headers in otherinfo before the 
# the real otherinfo starts
random_headers = ["random" + str(i) for i in [1,2,3]]
all_headers = annovar_headers[:-1] + random_headers +  otherinfo_headers

#        ['Chr', 'Start', 'End', 'Ref', 'Alt', 'wgEncodeRegTfbsClusteredV3', 'tfbsConsSites', 'wgEncodeRegDnaseClusteredV3', 'RegulomeDB_dbSNP141', 'Func.refGene', 'Gene.refGene', 'GeneDetail.refGene', 'ExonicFunc.refGene', 'AAChange.refGene', 'genomicSuperDups', 'esp6500siv2_all', 'gnomAD_exome_ALL', 'gnomAD_exome_AFR', 'gnomAD_exome_AMR', 'gnomAD_exome_ASJ', 'gnomAD_exome_EAS', 'gnomAD_exome_FIN', 'gnomAD_exome_NFE', 'gnomAD_exome_OTH', 'gnomAD_exome_SAS', 'gnomAD_genome_ALL', 'gnomAD_genome_AFR', 'gnomAD_genome_AMR', 'gnomAD_genome_ASJ', 'gnomAD_genome_EAS', 'gnomAD_genome_FIN', 'gnomAD_genome_NFE', 'gnomAD_genome_OTH', 'SIFT_score', 'SIFT_converted_rankscore', 'SIFT_pred', 'Polyphen2_HDIV_score', 'Polyphen2_HDIV_rankscore', 'Polyphen2_HDIV_pred', 'Polyphen2_HVAR_score', 'Polyphen2_HVAR_rankscore', 'Polyphen2_HVAR_pred', 'LRT_score', 'LRT_converted_rankscore', 'LRT_pred', 'MutationTaster_score', 'MutationTaster_converted_rankscore', 'MutationTaster_pred', 'MutationAssessor_score', 'MutationAssessor_score_rankscore', 'MutationAssessor_pred', 'FATHMM_score', 'FATHMM_converted_rankscore', 'FATHMM_pred', 'PROVEAN_score', 'PROVEAN_converted_rankscore', 'PROVEAN_pred', 'VEST3_score', 'VEST3_rankscore', 'MetaSVM_score', 'MetaSVM_rankscore', 'MetaSVM_pred', 'MetaLR_score', 'MetaLR_rankscore', 'MetaLR_pred', 'M-CAP_score', 'M-CAP_rankscore', 'M-CAP_pred', 'CADD_raw', 'CADD_raw_rankscore', 'CADD_phred', 'DANN_score', 'DANN_rankscore', 'fathmm-MKL_coding_score', 'fathmm-MKL_coding_rankscore', 'fathmm-MKL_coding_pred', 'Eigen_coding_or_noncoding', 'Eigen-raw', 'Eigen-PC-raw', 'GenoCanyon_score', 'GenoCanyon_score_rankscore', 'integrated_fitCons_score', 'integrated_fitCons_score_rankscore', 'integrated_confidence_value', 'GERP++_RS', 'GERP++_RS_rankscore', 'phyloP100way_vertebrate', 'phyloP100way_vertebrate_rankscore', 'phyloP20way_mammalian', 'phyloP20way_mammalian_rankscore', 'phastCons100way_vertebrate', 'phastCons100way_vertebrate_rankscore', 'phastCons20way_mammalian', 'phastCons20way_mammalian_rankscore', 'SiPhy_29way_logOdds', 'SiPhy_29way_logOdds_rankscore', 'Interpro_domain', 'GTEx_V6_gene', 'GTEx_V6_tissue', 'cg69', 'ExAC_ALL', 'ExAC_AFR', 'ExAC_AMR', 'ExAC_EAS', 'ExAC_FIN', 'ExAC_NFE', 'ExAC_OTH', 'ExAC_SAS', '1000g2015aug_all', 'CLINSIG', 'CLNDBN', 'CLNACC', 'CLNDSDB', 'CLNDSDBID', 'avsnp150', 'CADD13_RawScore', 'CADD13_PHRED', 'random1', 'random2', 'random3', '#CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'INFO', 'FORMAT', 'SS4009013', 'SS4009014', 'SS4009015', 'SS4009016', 'SS4009017', 'SS4009018', 'SS4009019', 'SS4009020', 'SS4009021', 'SS4009023', 'SS4009030']


# Everything after FORMAT is a sample
sample_headers = all_headers[(all_headers.index("FORMAT")+1):]


# list output headers and set their default filter function to identity
output_headers = ['#CHROM', 'POS', 'ID', 'REF', 'ALT',
        'wgEncodeRegTfbsClusteredV3', 'tfbsConsSites',
        'wgEncodeRegDnaseClusteredV3', 'RegulomeDB_dbSNP141', 'Func.refGene',
        'Gene.refGene', 'GeneDetail.refGene', 'ExonicFunc.refGene',
        'AAChange.refGene', 'genomicSuperDups', 'esp6500siv2_all',
        'gnomAD_exome_ALL', 'gnomAD_genome_ALL', 'SIFT_score',
        'Polyphen2_HDIV_score', 'CADD13_RawScore', 'CADD13_PHRED'] 
output_headers_formatters = [lambda x: x for o in output_headers]
output_headers_filters = [lambda x: True for o in output_headers]

# Add the sample headers and a function to extract the genotype
output_headers += sample_headers
output_headers_formatters += [lambda x : x.split(":")[0] for s in sample_headers]
output_headers_filters += [lambda x: True for o in sample_headers]

# find out all the indices
output_headers_indices = [all_headers.index(o) for o in output_headers]

# Add custom filters
def add_custom_headers(column_name, filter_func):
  output_headers_filters[output_headers.index(column_name)] = filter_func

add_custom_headers("gnomAD_genome_ALL", (lambda x: x == "." or float(x) < 0.05))


# This is a list of tuples (index, formatter, filters)
column_checkers = zip(output_headers_indices, output_headers_formatters, 
        output_headers_filters)


print("\t".join(output_headers))
for line in fh:
  line = line.strip().split("\t")
  output_line = []
  line_ok = True
  for idx, fmt_func, filter_func in column_checkers:
    res = fmt_func(line[idx])
    output_line.append(res)
    if filter_func(res) is False:
        line_ok = False
        break
  if line_ok is True: # print out
    print("\t".join(output_line))

fh.close()

