clean:
	rm -f breakdancer* chr.?.* chr.??.* contigs delly* lumpy_exclude.bed *.svp \
			output.cnv* output.root* cnvnator.* survivor* lumpy.?.vcf lumpy.??.vcf \
			submit_job.sh.o* *.delly.deletion.vcf lumpy.vcf lumpy.gff \
			diploidSV.vcf breakseq.vcf small_vcf.*
	rm -f *.svtyped.vcf* vcf_entries.vcf commands.txt header.txt svviz_summary.tsv
	rm -rf svtype_* svviz_outputs
	rm -rf breakseq2 manta

deepclean: clean
	rm -rf output/*
	rm input.bam input.bam.bai

pull:
	rm -f parliament2_latest.sif
	singularity pull docker://sameerdcosta/parliament2
	#singularity pull shub://sameerd/parliament2

run:
	LANG= singularity run \
		-B `pwd`/input:/home/dnanexus/in:rw \
		-B `pwd`/output:/home/dnanexus/out:rw \
		parliament2_latest.sif   \
			--bam SS4009013_sorted_unique.bam \
			--bai SS4009013_sorted_unique.bam.bai \
			-r human_g1k_v37.fasta \
			--fai human_g1k_v37.fasta.fai \
			--breakdancer --breakseq  --manta \
			--cnvnator --lumpy --genotype 
		    # \ --svviz --svviz_only_validated_candidates

