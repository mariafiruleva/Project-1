Trimmomatic=/usr/share/java/trimmomatic-0.35.jar
raw_data=/home/maria/Bioinformatics/Practice/Project/raw_data
Forward=$raw_data/amp_res_1.fastq
Reverse=$raw_data/amp_res_2.fastq
Reference=$raw_data/GCA_000005845.2_ASM584v2_genomic.fna
FastQC=/home/maria/Bioinformatics/Practice/Project-1/FastQC
Trimmed_forward=trimmed_1_P.fq
Trimmed_reverse=trimmed_2_P.fq
#fastqc analysis
fastqc -o $FastQC $Forward $Reverse

#trimmomatic
java -jar $Trimmomatic PE -phred33 $Forward $Reverse trimmed_1_P.fq trimmed_1_U.fq trimmed_2_P.fq trimmed_2_U.fq LEADING:20 TRAILING:20 SLIDINGWINDOW:10:20 MINLEN:20
java -jar $Trimmomatic PE -phred33 $Forward $Reverse 30q_trimmed_1_P.fq 30q_trimmed_1_U.fq 30q_trimmed_2_P.fq 30q_trimmed_2_U.fq LEADING:30 TRAILING:30 SLIDINGWINDOW:10:30 MINLEN:20

#fastqc analysis

fastqc -o $FastQC $Trimmed_forward $Trimmed_reverse
fastqc -o $FastQC 30q_trimmed_1_P.fq 30q_trimmed_2_P.fq

#index the reference file
bwa index $raw_data

#alignment

bwa mem $Reference $Trimmed_forward $Trimmed_reverse > alignment.sam

#compress SAM file

samtools view -S -b alignment.sam > alignment.bam

samtools flagstat alignment.bam > statistics.txt

#sort and index BAM file

samtools sort alignment.bam alignment_sorted

samtools index alignment_sorted.bam

#variant calling

samtools mpileup -f $Reference alignment_sorted.bam >  my.mpileup

java -jar ~/Programs/VarScan.v2.3.9.jar mpileup2snp my.mpileup --min-var-freq 0 --variants --output-vcf 1 > VarScan_zero_results.vcf
