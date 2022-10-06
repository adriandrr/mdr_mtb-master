Using gff file: /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.gff
Using ref file: /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.fasta
Using ann file: /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.ann.txt
Using barcode file: /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.barcode.bed
Using bed file: /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.bed
Using json_db file: /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.dr.json
Using version file: /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.version.json

Running command:
set -u pipefail; bwa mem -t 4 -c 100 -R '@RG\tID:22141791-e130-4998-b871-899e7d4a4795\tSM:22141791-e130-4998-b871-899e7d4a4795\tPL:illumina' -M -T 50 /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.fasta /22141791-e130-4998-b871-899e7d4a4795_1.fastq.gz /22141791-e130-4998-b871-899e7d4a4795_2.fastq.gz | samtools sort -@ 4 -o 22141791-e130-4998-b871-899e7d4a4795.pair.bam -

Running command:
set -u pipefail; samtools sort -m 348M -n -@ 4  22141791-e130-4998-b871-899e7d4a4795.pair.bam | samtools fixmate -@ 4 -m - - | samtools sort -m 348M -@ 4 - | samtools markdup -@ 4 - 22141791-e130-4998-b871-899e7d4a4795.bam

Running command:
set -u pipefail; rm 22141791-e130-4998-b871-899e7d4a4795.pair.bam

Running command:
set -u pipefail; samtools index -@ 4 22141791-e130-4998-b871-899e7d4a4795.bam

Using 22141791-e130-4998-b871-899e7d4a4795.bam

Please ensure that this BAM was made using the same reference as in the database.
If you are not sure what reference was used it is best to remap the reads.

Running command:
set -u pipefail; cat /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.bed | awk '{print $1":"$2"-"$3" "$1"_"$2"_"$3}' | parallel -j 4 --col-sep " " "samtools view -T /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.fasta -h 22141791-e130-4998-b871-899e7d4a4795.bam {1} | samclip --ref /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.fasta | samtools view -b > 22141791-e130-4998-b871-899e7d4a4795.{2}.tmp.bam && samtools index 22141791-e130-4998-b871-899e7d4a4795.{2}.tmp.bam && freebayes -f /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.fasta -r {1} --haplotype-length -1  22141791-e130-4998-b871-899e7d4a4795.{2}.tmp.bam | bcftools view -c 1 | bcftools norm -f /root/miniconda3/envs/tb-profiler/share/tbprofiler/tbdb.fasta | bcftools filter -t {1} -e 'FMT/DP<10' -S . -Oz -o 22141791-e130-4998-b871-899e7d4a4795.{2}.vcf.gz"
