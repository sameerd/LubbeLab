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
# NOTE: There are three extra headers in otherinfo before the 
# the real otherinfo starts
extra_headers = ["zygosity_status", "genotype_quality", "read_depth"]
all_headers = annovar_headers[:-1] + extra_headers +  otherinfo_headers

#        ['Chr', 'Start', 'End', 'Ref', 'Alt', 'wgEncodeRegTfbsClusteredV3', 'tfbsConsSites', 'wgEncodeRegDnaseClusteredV3', 'RegulomeDB_dbSNP141', 'Func.refGene', 'Gene.refGene', 'GeneDetail.refGene', 'ExonicFunc.refGene', 'AAChange.refGene', 'genomicSuperDups', 'esp6500siv2_all', 'gnomAD_exome_ALL', 'gnomAD_exome_AFR', 'gnomAD_exome_AMR', 'gnomAD_exome_ASJ', 'gnomAD_exome_EAS', 'gnomAD_exome_FIN', 'gnomAD_exome_NFE', 'gnomAD_exome_OTH', 'gnomAD_exome_SAS', 'gnomAD_genome_ALL', 'gnomAD_genome_AFR', 'gnomAD_genome_AMR', 'gnomAD_genome_ASJ', 'gnomAD_genome_EAS', 'gnomAD_genome_FIN', 'gnomAD_genome_NFE', 'gnomAD_genome_OTH', 'SIFT_score', 'SIFT_converted_rankscore', 'SIFT_pred', 'Polyphen2_HDIV_score', 'Polyphen2_HDIV_rankscore', 'Polyphen2_HDIV_pred', 'Polyphen2_HVAR_score', 'Polyphen2_HVAR_rankscore', 'Polyphen2_HVAR_pred', 'LRT_score', 'LRT_converted_rankscore', 'LRT_pred', 'MutationTaster_score', 'MutationTaster_converted_rankscore', 'MutationTaster_pred', 'MutationAssessor_score', 'MutationAssessor_score_rankscore', 'MutationAssessor_pred', 'FATHMM_score', 'FATHMM_converted_rankscore', 'FATHMM_pred', 'PROVEAN_score', 'PROVEAN_converted_rankscore', 'PROVEAN_pred', 'VEST3_score', 'VEST3_rankscore', 'MetaSVM_score', 'MetaSVM_rankscore', 'MetaSVM_pred', 'MetaLR_score', 'MetaLR_rankscore', 'MetaLR_pred', 'M-CAP_score', 'M-CAP_rankscore', 'M-CAP_pred', 'CADD_raw', 'CADD_raw_rankscore', 'CADD_phred', 'DANN_score', 'DANN_rankscore', 'fathmm-MKL_coding_score', 'fathmm-MKL_coding_rankscore', 'fathmm-MKL_coding_pred', 'Eigen_coding_or_noncoding', 'Eigen-raw', 'Eigen-PC-raw', 'GenoCanyon_score', 'GenoCanyon_score_rankscore', 'integrated_fitCons_score', 'integrated_fitCons_score_rankscore', 'integrated_confidence_value', 'GERP++_RS', 'GERP++_RS_rankscore', 'phyloP100way_vertebrate', 'phyloP100way_vertebrate_rankscore', 'phyloP20way_mammalian', 'phyloP20way_mammalian_rankscore', 'phastCons100way_vertebrate', 'phastCons100way_vertebrate_rankscore', 'phastCons20way_mammalian', 'phastCons20way_mammalian_rankscore', 'SiPhy_29way_logOdds', 'SiPhy_29way_logOdds_rankscore', 'Interpro_domain', 'GTEx_V6_gene', 'GTEx_V6_tissue', 'cg69', 'ExAC_ALL', 'ExAC_AFR', 'ExAC_AMR', 'ExAC_EAS', 'ExAC_FIN', 'ExAC_NFE', 'ExAC_OTH', 'ExAC_SAS', '1000g2015aug_all', 'CLINSIG', 'CLNDBN', 'CLNACC', 'CLNDSDB', 'CLNDSDBID', 'avsnp150', 'CADD13_RawScore', 'CADD13_PHRED', 'random1', 'random2', 'random3', '#CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'INFO', 'FORMAT', 'SS4009013', 'SS4009014', 'SS4009015', 'SS4009016', 'SS4009017', 'SS4009018', 'SS4009019', 'SS4009020', 'SS4009021', 'SS4009023', 'SS4009030']


# Everything after the FORMAT column is a sample
sample_headers = all_headers[(all_headers.index("FORMAT")+1):]

# list output headers and set their default filter function to identity
output_headers = ['#CHROM', 'POS', 'ID', 'REF', 'ALT',
        'wgEncodeRegTfbsClusteredV3', 'tfbsConsSites',
        'wgEncodeRegDnaseClusteredV3', 'RegulomeDB_dbSNP141_Score',
        'Func.refGene', 'Gene.refGene', 'GeneDetail.refGene',
        'ExonicFunc.refGene', 'AAChange.refGene', 'genomicSuperDups',
        'esp6500siv2_all', 'gnomAD_exome_ALL', 'gnomAD_genome_ALL',
        'SIFT_score', 'Polyphen2_HDIV_score', 'CADD13_RawScore',
        'CADD13_PHRED'] 
output_headers_formatters = [lambda x: x for o in output_headers]

# Add the sample headers and a function to extract the genotype
output_headers += sample_headers
output_headers_formatters += [lambda x : x.split(":")[0] for s in sample_headers]

# find out all the indices
output_headers_indices = [all_headers.index(o) for o in output_headers]

# Filter functions should return True if a line is to be kept
# and false if a line is to be rejected
# line is a list of strings in an annotated line

def maf_filter_functor(maf_cutoff):
  idx = all_headers.index("gnomAD_exome_ALL")
  def maf_filter(line):
    val = line[idx]
    return (val == ".") or (float(val) <= maf_cutoff)
  return maf_filter

def regulomedb_filter_functor():
  idx = all_headers.index("RegulomeDB_dbSNP141_Score")
  def regulomedb_filter(line):
    val = line[idx] # value of regulomedb score
    # We want to eliminate 6's or 7's
    return (val == ".") or (val != "6") or (val != "7")
  return (regulomedb_filter)

def superdups_filter_functor():
  idx = all_headers.index("genomicSuperDups")
  def superdups_filter(line):
    val = line[idx]
    return val == "."
  return (superdups_filter)

def exonic_and_regulatory_filter_functor():
  func_refgene_idx = all_headers.index("Func.refGene")
  exonicfunc_refgene_idx = all_headers.index("ExonicFunc.refGene")
  tbfs_clustered_idx = all_headers.index('wgEncodeRegTfbsClusteredV3')
  tbfs_cons_idx = all_headers.index('tfbsConsSites') 
  dnase_clustered_idx = all_headers.index('wgEncodeRegDnaseClusteredV3')  
  def exonic_and_regulatory_filter(line):
    func_refgene = line[func_refgene_idx]
    exonicfunc_refgene = line[exonicfunc_refgene_idx]
    # if "Func.refGene" is in exonic or splicing region
    if func_refgene in ["exonic", "exonic;splicing", "splicing"]:
      # We don't want synonymous variants except in the 
      # exonic;splicing region
      if exonicfunc_refgene != "synonymous SNV":
        return True # 
      else: # This is a synonymous SNV so lets keep it only
        # when we are in the exonic;splicing region
        return func_refgene == "exonic;splicing"
    else: # now we are probably in a region where we need to filter on 
      # the regulatory elements
      tbfs_clustered = line[tbfs_clustered_idx]
      tbfs_cons = line[tbfs_cons_idx]
      dnase_clustered = line[dnase_clustered_idx]
      # We keep the line if there is something in tbfs_clustered or tbfs_cons
      # and dnase_clustered is non empty
      return ((tbfs_clustered != "." or tbfs_cons != ".") and (dnase_clustered != "."))
  return (exonic_and_regulatory_filter)


# put all the filters into a list
# not all the filters are guaranteed to run. As soon as one of them returns
# false we stop looking at the next filters and move onto the next line
# We should put the filters that eliminate the most lines first
all_filters = [ 
    maf_filter_functor(0.05),
    superdups_filter_functor(),
    regulomedb_filter_functor(),
    exonic_and_regulatory_filter_functor()
  ]

# Print out the header of the output file
print("\t".join(output_headers))

for line in fh:
  line = line.strip().split("\t")
  output_line = []
  # Pass line in the fi
  line_ok = all(filter_func(line) for filter_func in all_filters)
  if line_ok is True: # print out
    # Build an output_line
    output_line = [fmt_func(line[idx]) for idx, fmt_func in
                    zip(output_headers_indices, output_headers_formatters)]
    # and print it out
    print("\t".join(output_line))

fh.close()

