#Notice you should change 'path' to your real paths. This script works with our roommate data: in the case of control you must change the filenames and coverage.

raw_data=/path/raw_data
Sample=$raw_data/SRR1705851.fastq
Reference=$raw_data/KF848938.1.fasta
FastQC=/path/FastQC
VarScan=~/path/VarScan.v2.3.9.jar

#fastqc analysis
fastqc -o $FastQC $Sample


#index the reference file
bwa index $raw_data

#alignment

bwa mem $Reference $Sample > SRR1705851.sam

#compress SAM file

samtools view -S -b SRR1705851.sam > SRR1705851.bam

samtools flagstat SRR1705851.bam > statistics.txt

#sort and index BAM file

samtools sort SRR1705851.bam SRR1705851_sorted

samtools depth samtools depth SRR1705851_sorted.bam | awk '{sum+=$3} END { print "Average = ",sum/NR}' > average_coverage_for_mapped_reads.csv

samtools view -b -F 4 SRR1705851_sorted.bam | wc -l > number_of_mapped_reads.csv

samtools index SRR1705851_sorted.bam

#variant calling

samtools mpileup -d 44522 -f $Reference SRR1705851.bam >  SRR1705851.mpileup

java -jar $VarScan mpileup2snp SRR1705851.mpileup --min-var-freq 0.001 --variants --output-vcf 1 > SRR1705851.vcf
