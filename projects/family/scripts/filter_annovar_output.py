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


# Everything after the FORMAT column is a sample
sample_headers = all_headers[(all_headers.index("FORMAT")+1):]

# list output headers and set their default filter function to identity
output_headers = ['#CHROM', 'POS', 'ID', 'REF', 'ALT',
        'wgEncodeRegTfbsClusteredV3', 'tfbsConsSites',
        'wgEncodeRegDnaseClusteredV3', 'RegulomeDB_dbSNP141_Score',
        'gerp++gt2', 'Func.refGene', 'Gene.refGene', 'GeneDetail.refGene',
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

def maf_filter_functor(column_name, maf_cutoff):
  idx = all_headers.index(column_name)
  def maf_filter(line):
    val = line[idx]
    return (val == ".") or (float(val) <= maf_cutoff)
  return maf_filter

def cadd_filter_functor(cutoff):
  idx = all_headers.index("CADD13_PHRED")
  def cadd_filter(line):
    val = line[idx]
    return (val == ".") or (float(val) >= cutoff)
  return cadd_filter

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
  gerp_idx = all_headers.index('gerp++gt2')
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
      gerp_val = line[gerp_idx] 
      # We keep the line if there is something in tbfs_clustered or tbfs_cons
      # and dnase_clustered is non empty
      return (((tbfs_clustered != "." or tbfs_cons != ".") and (dnase_clustered != "."))
              and (gerp_val != ".") and (float(gerp_val) > 2.0))
  return (exonic_and_regulatory_filter)


# put all the filters into a list
# not all the filters are guaranteed to run. As soon as one of them returns
# false we stop looking at the next filters and move onto the next line
# We should put the filters that eliminate the most lines first
all_filters = [ 
    maf_filter_functor("gnomAD_genome_ALL", 0.05),
    maf_filter_functor("gnomAD_exome_ALL", 0.05),
    cadd_filter_functor(12.37),
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

