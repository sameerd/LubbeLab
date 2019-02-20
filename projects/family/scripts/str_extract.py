import sys
import os
import os.path

filename = sys.argv[1]

#parallel "python scripts/str_extract.py {} > data/working/gangstr/{/}" :::  data/input/gangstr/*.vcf


with open(filename) as fh:
  print("CHROM\tPOS\tEND\tRU\tREF\t" + os.path.basename(filename))
  for line in fh:
    if line.startswith("#"):
      pass
    else:
      line_sp = line.split("\t")
      chrom = line_sp[0]
      pos = line_sp[1]
      info = line_sp[7]
      info_dict = dict([i.split("=") for i in info.split(";")])
      sample = line_sp[9]
      counts = sample.split(":")[2]
      print(chrom + "\t" + pos + "\t" + info_dict["END"] + "\t" 
              + info_dict["RU"] + "\t" + info_dict["REF"] + "\t" +
              counts)

