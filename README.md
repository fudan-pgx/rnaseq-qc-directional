# RNA Sequencing (RNA-seq) Quality Control Pipeline (Directional)

> Author: Li Zhihui, Qingwang Chen
>
> E-mail：18210700119@fudan.edu.cn, 20110700030@fudan.edu.cn
>
> Git: http://choppy.3steps.cn/chenqingwang/RNAseq-qc-directional
>
> Last Updates: 2022/05/17

## Requirements

- choppy(Cromwell Engine)
- Ali-Cloud
- Linux

```
# Activating the choppy environment
$ source activate choppy (open-choppy-env)

# First installation
$ choppy install chenqingwang/RNAseq-qc-directional
# Non-first-time installation
$ choppy install chenqingwang/RNAseq-qc-directional -f 

# Check the installed APP
$ choppy apps
```

## Quick Start

```
# Prepare the samples.csv file
$ choppy samples chenqingwang/RNAseq-qc-directional-latest > samples.csv

# Prepare samples.csv file without default parameters
$ choppy samples --no-default chenqingwang/RNAseq-qc-directional-latest> samples.csv

# Submit a task
$ choppy batch chenqingwang/RNAseq-qc-directional-latest samples.csv -p Your_project_name -l Your_label

# Query task status
$ choppy query -L Your_label | grep "status"

# Query Failed Task
$ choppy search -s Failed -p Your_project_name -u user_name --short-format

# Result file address
$ oss://choppy-cromwell-result/test-choppy/Your_project_name/
```

## Overview
This APP can be used for upstream analysis of strand-specific RNAseq library sequencing (Directional RNA Sequencing, dRNA-Seq) data. The process includes two parts: quality assessment and upstream analysis, where quality assessment includes raw data and alignment data QC and gene expression data QC, and upstream analysis can be realized from fastq files to fpkm expression profiles and count files for RNAseq downstream analysis.

## Process and Parameters

![image-20200724020524943](https://tva1.sinaimg.cn/large/007S8ZIlgy1gh1g8dqs3kj30r209g40a.jpg)

### 1. Raw data quality and data alignment quality

#### [Fastqc](<https://www.bioinformatics.babraham.ac.uk/projects/fastqc/>) v0.11.5

FastQC is a commonly used quality control software for sequencing raw data, mainly including 12 modules, please refer to [FastQC](<https://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/3%20Analysis%20Modules/>)。

```bash
fastqc -t <threads> -o <output_directory> <fastq_file>
```

#### [Fastq Screen](<https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/>) 0.12.0

Fastq Screen is a test for contamination such as the introduction of other species or splice primers into the raw sequencing data.

For example, if the sample is human, we expect more than 99% of the reads to match the human genome and about 10% of the reads to match the small mouse with high homology to the human genome.

We expect more than 99% of the reads to match to the human genome, and about 10% to match to small mice with high homology to the human genome. If too many reads match to Ecoli or Yeast, it is important to consider whether the cell line was contaminated during cell culture or the library was contaminated during library construction.

```bash
fastq_screen --aligner <aligner> --conf <config_file> --top <number_of_reads> --threads <threads> <fastq_file>
```

`--conf`  The config file mainly input the fasta file address of several species, you can download the fasta file of other species to join the analysis according to your own needs

`--top` Generally do not need to search the entire fastq file, take the first 100000 lines

#### [Qualimap](<http://qualimap.bioinfo.cipf.es/>) 2.0.0

Qualimap is a software that calculates the quality of data matching and contains the results of bam file matching quality after sequencing data matching.

```bash
qualimap bamqc -bam <bam_file> -outformat PDF:HTML -nt <threads> -outdir <output_directory> --java-mem-size=32G 
qualimap rnaseq -bam ${bam} -outformat HTML -outdir ${bamname}_RNAseq -gtf ${gtf} -pe --java-mem-size=10G
```

###2. Quality of data presentation

```
Rscript
```

The analysis used codes used within the laboratory to assess the quality of the data in terms of 10 aspects.


- Number of detected genes
- Detection Jaccard index (JI)
- Coefficient of variation (CV)
- Correlation of technical replicates (CTR)
- Sensitivity of detection
- Specificity of detection
- Consistency ratio of relative expression
- Correlation of relative log2FC
- Sensitivity of DEGs
- Specificity of DEGs
- Signal-to-noise Ratio (SNR) )

## App input file

```
#read1	#read2	#sample_id	#adapter_sequence	#adapter_sequence_r2
#so on..
```

Parameter:

If you need to make changes, please add a new line to the samples.csv file.

#### [fastp](https://github.com/OpenGene/fastp)

| Parameter Name                    | Parameter explanation                                                | Default                                                       |
| ------------------------- | ------------------------------------------------------- | ------------------------------------------------------------ |
| fastp_docker              | fastp  version                                        | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/fastp:0.19.6 |
| fastp_cluster             | fastp cloud hpc                                   | OnDemand bcs.b2.3xlarge img-ubuntu-vpc                       |
| trim_front1               | Trim bases in front of read1                                 | 0                                                            |
| trim_tail1                |  Trim bases in tail of read1                               | 0                                                            |
| max_len1                  | Trim the end of read1 so that it is as long as max_len1                     | 0                                                            |
| trim_front2               |  Trim bases in front of read2                                                           | 0                                                            |
| trim_tail2                | Trim bases in tail of read2                                 | 0                                                            |
| max_len2                  | Trim the end of read2 so that it is as long as max_len2                   | 0                                                            |
| adapter_sequence          | R1 adapter          | AGATCGGAAGAGCACACGTCTGAACTCCAGTCA                            |
| adapter_sequence_r2       | R2 adapter                                            | AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT                            |
| disable_adapter_trimming  | Whether to perform connector filtering (non-zero then no filtering)                         | 0                                                            |
| length_required           | Adapter filter parameter: reads shorter than length_required will be discarded         | 50                                                           |
| length_required1          | Adapter filtering parameters: The default value of 20 means phred quality> = Q20 is qualified | 20                                                           |
| UMI                       | Whether to use the UMI connector (non-zero then use)                              | 0                                                            |
| umi_len                   | The length of UMI adapter.              | 0                                                            |
| umi_loc                   |  The location of UMI adapter.                                   | umi_loc                                                      |
| disable_quality_filtering | Whether to perform base mass filtering (filter if non-zero)                       | 1                                                            |
| qualified_quality_phred   | Base quality filtering parameter: percentage of allowed failures                    | 20                                                           |



#### [HISAT2](http://daehwankimlab.github.io/hisat2/)

| Parameter Name                    | Parameter explanation                                                | Default                                                      |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| hisat2_docker    | hisat2 version      | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/hisat2:v2.1.0-2 |
| hisat2_cluster   | hisat2 cloud hpc              | OnDemand                                                     |
| idx_prefix       | alignment file types                                                 | genome_snp_tran                                              |
| idx              | alignment file address                                                 | oss://pgx-reference-data/reference/hisat2/grch38_snp_tran/   |
| fasta            | alignment file name                                                 | GRCh38.d1.vd1.fa                                             |
| pen_cansplice    | Set penalties for each pair of canonical splice sites (e.g. GT/AG)                 | 0                                                            |
| pen_noncansplice | Set the penalty per pair of non-canonical splice sites (e.g. non-GT/AG)               | 3                                                            |
| pen_intronlen    | Set penalty points for long introns, so that shorter introns are preferred over shorter ones | G,-8,1                                                       |
| min_intronlen    | Set minimum intron length                                           | 30                                                           |
| max_intronlen    | Set maximum intron length                                           | 500000                                                       |
| maxins           | Maximum fragment length for valid paired-end alignments                             | 500                                                          |
| minins           | Minimum fragment length for a valid paired-end pairing                             | 0                                                            |



#### [Samtools](http://www.htslib.org/)

| Parameter Name                    | Parameter explanation                                                | Default                                                     |
| ---------------- | ---------------------- | ------------------------------------------------------------ |
| samtools_docker  | samtools version   | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/samtools:v1.3.1 |
| samtools_cluster | samtools cloud hpc | OnDemand bcs.a2.large img-ubuntu-vpc,                        |
| insert_size      | Maximum insertion reading length           | 8000                                                         |



#### [StringTie](https://ccb.jhu.edu/software/stringtie/)

| Parameter Name                    | Parameter explanation                                                | Default                                                       |
| ---------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| stringtie_docker                                     | stringtie version                                        | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/stringtie:v1.3.4 |
| stringtie_cluster                                    | stringtie cloud hpc                                      | OnDemand bcs.a2.large img-ubuntu-vpc,                        |
| gtf                                                  | Assemble gtf file address                                              | oss://pgx-reference-data/reference/annotation/Homo_sapiens.GRCh38.93.gtf |
| minimum_length_allowed_for_the_predicted_transcripts | Set the minimum length allowed for predicted transcripts                               | 200                                                          |
| minimum_isoform_abundance                            | Set the minimum isoform abundance of predicted transcripts as a fraction of the most abundant transcripts assembled at a given locus | 0.01                                                         |
| Junctions_no_spliced_reads                           | Splices that are not spliced are aligned with at least that number of bases at both ends, and these splices are filtered out | 10                                                           |
| maximum_fraction_of_muliplelocationmapped_reads      | Sets the maximum fraction of reads allowed to map polynucleotide positions present at a given locus | 0.95                                                         |



#### [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

| Parameter Name                    | Parameter explanation                                                | Default                                                       |
| --------------------- | -------------------- | ------------------------------------------------------------ |
| fastqc_cluster_config | fastqc cloud hpc | OnDemand bcs.b2.3xlarge img-ubuntu-vpc                       |
| fastqc_docker         | fastqc version   | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/fastqc:v0.11.5 |
| fastqc_disk_size      | fastqc disk size     | 150                                                          |



#### [Qualimap](http://qualimap.bioinfo.cipf.es/)

| Parameter Name                    | Parameter explanation                                                | Default                                                       |
| ----------------------------- | ---------------------------- | ------------------------------------------------------------ |
| qualimapBAMqc_docker          | qualimapBAMqc version    | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/qualimap:2.0.0 |
| qualimapBAMqc_cluster_config  | qualimapBAMqc cloud hpc  | OnDemand bcs.a2.7xlarge img-ubuntu-vpc                       |
| qualimapBAMqc_disk_size       | qualimapBAMqc disk size    | 500                                                          |
| qualimapRNAseq_docker         | qualimapRNAseq version   | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/qualimap:2.0.0 |
| qualimapRNAseq_cluster_config | qualimapRNAseq cloud hpc | OnDemand bcs.a2.7xlarge img-ubuntu-vpc                       |
| qualimapRNAseq_disk_size      | qualimapRNAseq disk size   | 500                                                          |



#### [FastQ Screen](https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/)

| Parameter Name                    | Parameter explanation                                                | Default                                                       |
| -------------------------- | --------------------------- | ------------------------------------------------------------ |
| fastqscreen_docker         | fastqscreen version     | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/fastqscreen:0.12.0 |
| fastqscreen_cluster_config | fastqscreen cloud hpc   | OnDemand bcs.b2.3xlarge img-ubuntu-vpc                       |
| screen_ref_dir             | reference sequence     | oss://pgx-reference-data/fastq_screen_reference/             |
| fastq_screen_conf          | index of reference sequence | oss://pgx-reference-data/fastq_screen_reference/fastq_screen.conf |
| fastqscreen_disk_size      | fastqscreen disk size       | 200                                                          |
| 



## App output

#### 1. results_upstream_total.csv

| library | date     | sample | replicate | Total.Sequences | GC_beforemapping | total_deduplicated_percentage | Human.percentage | ERCC.percentage | EColi.percentage | Adapter.percentage | Vector.percentage | rRNA.percentage | Virus.percentage | Yeast.percentage | Mitoch.percentage | Phix.percentage | No.hits.percentage | percentage_aligned_beforemapping | error_rate | bias_53 | GC_aftermapping | percent_duplicates | sequence_length | median_insert_size | mean_coverage | ins_size_median | ins_size_peak | exonic | intronic | intergenic |
| ------- | -------- | ------ | --------- | --------------- | ---------------- | ----------------------------- | ---------------- | --------------- | ---------------- | ------------------ | ----------------- | --------------- | ---------------- | ---------------- | ----------------- | --------------- | ------------------ | -------------------------------- | ---------- | ------- | --------------- | ------------------ | --------------- | ------------------ | ------------- | --------------- | ------------- | ------ | -------- | ---------- |
| D5_1    | 20200724 | D5     | 1         | 48872858        | 52               | 45.2953551                    | 94.79            | 0               | 0                | 0.01               | 0.15              | 17.01           | 1.23             | 4.54             | 0.61              | 0               | 0.9                | 98.6435612                       | 0.01       | 1.01    | 58.0426004      | 54.7046449         | 150             | 263                | 15.8021       | 258             | 192           | 52.05  | 41.37    | 6.58       |
|         |          |        |           |                         

Summary of raw data quality and data alignment quality results (EXAMPLE)

## Interpretation of results

### 1. Raw data quality and data alignment quality

| QC parameters                         | software         | definition                         | reference    |
| -------------------------------- | ------------ | ---------------------------- | --------- |
| Total.Sequences                  | Fastqc       | Total number of read segments                   | > 10 M    |
| GC_beforemapping                 | Fastqc       | GC content before alignment                 | 40% - 60% |
| total_deduplicated_percentage    | Fastqc       | Repeat sequence ratio                 |           |
| Human.percentage                 | FastQ Screen | Proportion of read segments aligned to the human genome       | > 90 %    |
| ERCC.percentage                  | FastQ Screen | Proportion of read segments aligned to ERCC genome     | < 5%      |
| EColi.percentage                 | FastQ Screen | Proportion of read segments aligned to E. coli genome | < 5%      |
| Adapter.percentage               | FastQ Screen |  Proportion of read segments aligned to Adapter           | < 5%      |
| Vector.percentage                | FastQ Screen |  Proportion of read segments aligned to vector           | < 5%      |
| rRNA.percentage                  | FastQ Screen |  Proportion of read segments aligned to rRNA           | < 10%     |
| Virus.percentage                 | FastQ Screen |  Proportion of read segments aligned to Virus genome           | < 5%      |
| Yeast.percentage                 | FastQ Screen |  Proportion of read segments aligned toyeast genome           | < 5%      |
| Mitoch.percentage                | FastQ Screen |  Proportion of read segments aligned to mitochondria genome         | < 5%      |
| Phix.percentage                  | FastQ Screen |  Proportion of read segments aligned to Phix genome           | < 5%      |
| No.hits.percentage               | FastQ Screen |  Proportion of read segments aligned to unkown genome     | < 5%      |
| percentage_aligned_beforemapping | Qualimap     | Mapping ratio                       | > 90%     |
| error_rate                       | Qualimap     | Error ratio                       | < 5%      |
| bias_53                          | Qualimap     | 5'-3' bias                    |           |
| GC_aftermapping                  | Qualimap     | GC content after alignment                 | 40% - 60% |
| percent_duplicates               | Qualimap     | Repetition rate after read alignment           |           |
| sequence_length                  | Qualimap     | Read segment length                     | ~150      |
| median_insert_size               | Qualimap     | Median insert size                 | 200 - 300 |
| mean_coverage                    | Qualimap     | Meam coverage                       |           |
| ins_size_median                  | Qualimap     | Median insert size           | 200 - 300 |
| ins_size_peak                    | Qualimap     | Mode insert size            | 200 - 300 |
| exonic                           | Qualimap     | Ratio of bases aligned to exonic region       | 40% - 60% |
| intronic                         | Qualimap     |  Ratio of bases aligned to intronic region       | 40% - 60% |
| intergenic                       | Qualimap     |Ratio of bases aligned to intergenic region  | < 10%     |
