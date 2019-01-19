clean:
	rm -f breakdancer* chr.?.* chr.??.* contigs delly* lumpy_exclude.bed *.svp \
			output.cnv* output.root* cnvnator.* survivor* lumpy.?.vcf lumpy.??.vcf \
			msub.sh.o* *.delly.deletion.vcf lumpy.vcf lumpy.gff \
			diploidSV.vcf breakseq.vcf
	rm -rf breakseq2 manta

deepclean: clean
	rm -rf output/*



run:
	LANG= singularity exec \
		-B `pwd`/input:/home/dnanexus/in:rw \
		-B `pwd`/output:/home/dnanexus/out:rw \
		parliament2_0.1.9.sif   \
		python parliament2.py \
			--bam SS4009013_sorted_unique.bam \
			--bai SS4009013_sorted_unique.bam.bai \
			-r human_g1k_v37.fasta \
			--fai human_g1k_v37.fasta.fai 

#run:
#	singularity exec \
#		-B `pwd`/input:/home/dnanexus/in:rw \
#		-B `pwd`/output:/home/dnanexus/out:rw \
#		parliament2_0.1.9.sif   \
#		python parliament2.py \
#			--bam SS4009013_sorted_unique.bam \
#			--bai SS4009013_sorted_unique.bam.bai \
#			-r human_g1k_v37.fasta \
#			--fai human_g1k_v37.fasta.fai \
#			--breakdancer --cnvnator --manta \
#			--breakseq --lumpy \
#			--delly_deletion --delly_insertion \
#			--delly_inversion --delly_duplication \
#			--genotype 
