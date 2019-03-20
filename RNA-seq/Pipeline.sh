!#/bin/bash

#Notice you must change all paths to your own paths.

#Quality Control
for i in 'SRR941816' 'SRR941817' 'SRR941818' 'SRR941819'
do
fastqc $i.fastq
done

#Adapters trimming and Qualiti Control of paired fastq. 'adapters.fasta' is a file with adapters sequences which are presented in the section 'overrepresented sequences' in html output of previous step
for i in 'SRR941816' 'SRR941817'
do
java -jar /usr/share/java/trimmomatic-0.35.jar SE -phred33 $i.fastq paired_$i.fastq ILLUMINACLIP:adapters.fasta:2:30:10 MINLEN:50
fastqc paired_$i.fastq
paired_$i.fastq > $i.fastq
done

#Alignment
for i in 'SRR941816' 'SRR941817' 'SRR941818' 'SRR941819'
do
/hisat2 -p 4 -x /home/maria/Bioinformatics/Practice/rna-seq/GCF_000146045.2_R64_genomic_index -U /home/maria/Bioinformatics/Practice/rna-seq/$i.fastq > $i.sam
samtools view -bS $i.sam > $i.bam
samtools sort $i.bam > sorted_$i.bam
done

#Raw counts
featureCounts -g gene_name -a ../../GCF_000146045.2_R64_genomic../featureCounts -g gene_name -a ../../GCF_000146045.2_R64_genomic.gtf -o ../../summary_output_coord_sorted sorted_*.bam
