zcat /projects/b1049/Niccolo_NGS/genomes/SS4009030/SS4009030_ST-E00180_247_L7_1.fq.gz | head -10000000 > test_1.fq
gzip test_1.fq
zcat /projects/b1049/Niccolo_NGS/genomes/SS4009030/SS4009030_ST-E00180_247_L7_2.fq.gz | head -10000000 > test_2.fq
gzip test_2.fq


