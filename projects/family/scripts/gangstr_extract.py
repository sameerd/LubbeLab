import sys
import os
import os.path

filename = sys.argv[1]

#parallel "python scripts/str_extract.py {} > data/working/gangstr/{/.}.txt" :::  data/input/gangstr/*.vcf


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
      print("\t".join([chrom, pos, info_dict["END"], info_dict["RU"],
                       info_dict["REF"], sample_dict["GB"], sample_dict["GT"], 
                       sample_dict["CI"], sample_dict["RC"]]))

