import sys
import os
import os.path

filename = sys.argv[1]

#parallel "python scripts/gangstr_extract.py {} > data/working/gangstr/{/.}.txt" :::  data/input/gangstr/*.vcf

line_columns = ["CHROM", "POS","ID", "REF", "ALT",
                "QUAL", "FILTER", "INFO", "FORMAT", "SAMPLE"]
line_dict = dict((a,i) for i, a in enumerate(line_columns))

with open(filename) as fh:
  print("\t".join(["CHROM", "POS", "END", "RU", "REF", 
                   os.path.basename(filename), "GT", "DP", "FILTER", "CI", "RC"]))
  for line in fh:
    if line.startswith("#"):
      pass
    else:
      line_sp = line.strip().split("\t")
      chrom = line_sp[line_dict['CHROM']]
      pos = line_sp[line_dict['POS']]
      filter_flag = line_sp[line_dict['FILTER']]
      info = line_sp[line_dict['INFO']]
      info_dict = dict([i.split("=") for i in info.split(";")])
      sample_dict = dict(zip(line_sp[line_dict['FORMAT']].split(":"), 
                             line_sp[line_dict['SAMPLE']].split(":")))
      # set the filter output to be the filter flag
      filter_output = filter_flag
      # if it is a pass then lets search in the sample_dict for any other filters 
      if filter_output == 'PASS':
        if 'FILTER' in sample_dict:
          sample_filter = sample_dict['FILTER']
          if sample_filter != 'PASS':
            filter_output = sample_filter
      try:
        print("\t".join([chrom, pos, info_dict["END"], info_dict["RU"],
                       info_dict["REF"], sample_dict["REPCN"], sample_dict["GT"], 
                       sample_dict["DP"], filter_output,
                       sample_dict["REPCI"], sample_dict["RC"]]))
      except KeyError as e:
        # Sometimes we don't find things like REPCI or REPCN in the sample_dict
        # Let's print an error message and skip that line
        cause = e.args[0]
        sys.stderr.write("KeyError at location " + str(chrom) + ":" + 
                str(pos) + " : " + str(cause) + " not found. Skipping...\n" )
