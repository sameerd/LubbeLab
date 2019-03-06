import sys
import os
import os.path

filename = sys.argv[1]

#parallel "python scripts/gangstr_extract.py {} > data/working/gangstr/{/.}.txt" :::  data/input/gangstr/*.vcf


with open(filename) as fh:
  print("\t".join(["CHROM", "POS", "END", "RU", "REF", 
                   os.path.basename(filename), "GT", "CI", "RC"]))
  for line in fh:
    if line.startswith("#"):
      pass
    else:
      line_sp = line.split("\t")
      chrom = line_sp[0]
      pos = line_sp[1]
      info = line_sp[7]
      info_dict = dict([i.split("=") for i in info.split(";")])
      sample_dict = dict(zip(line_sp[8].split(":"), line_sp[9].split(":")))
      try:
        print("\t".join([chrom, pos, info_dict["END"], info_dict["RU"],
                       info_dict["REF"], sample_dict["REPCN"], sample_dict["GT"], 
                       sample_dict["REPCI"], sample_dict["RC"]]))
      except KeyError as e:
        # Sometimes we don't find things like REPCI or REPCN in the sample_dict
        # Let's print an error message and skip that line
        cause = e.args[0]
        sys.stderr.write("KeyError at location " + str(chrom) + ":" + 
                str(pos) + " : " + str(cause) + " not found. Skipping...\n" )
