## RNA-seq analysis  
------

This repository is used to store the code for detailed RNA-seq analysis.

- [Raw data material](#Raw-data-material)
- [Quality control](#Quality-control)
- [Pseudo alignment and transcript quantification using Kallisto](#Pseudoalignment-and-transcript-quantification-using-Kallisto)
- [Normalization and differential analysis using Sleuth](#Normalization-and-differential-analysis-using-Sleuth)  


***
### Raw data material
Eight peach RNA-sequencing datasets of various peach cultivars under different stress conditions and from various tissues were used for this project. All the raw data files were downloaded from the European Nucleotide Archive (https://www.ebi.ac.uk/ena).


| Project IDs    | Experiments        | Tissues     |Libraries type  |References             |
| :--------------| :-----------------:|:-----------:|:--------------:|:---------------------:|
| PRJNA271307    | Ripening stage     | Fruit       |single-end      |(Li et al., 2015)      |
| PRJNA288567    | Cold storage       | Fruit       |paired-end      |(Sanhueza et al., 2015)|
| PRJNA248711    | Hyper hydricity    | Leaf        |paired-end      |(Bakir et al., 2016)   |
| PRJEB12334     | Drought            | Root/Leaf   |paired-end      |(Ksouri et al., 2016)  |
| PRJNA252780    | Low T°             | Stigma      |single-end      |(Jiao et al., 2017)    |
| PRJNA323761    | Drought            | Root        |paired-end      |Unpublished            |
| PRJNA328435    | Cold storage       | Fruit       |paired-end      |Unpublished            |
| PRJNA397885    | Chilling injury    | Fruit       |paired-end      |Unpublished            |


***
### Quality control

Quality metrics of the raw sequences was assessed using FastQC v.0.11.5 and Trimmomatic v.0.36.
For more details please refer to FastQC main page and manual (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and check the video tutorial here:http://www.youtube.com/watch?v=bz93ReOv87Y. 

Briefly, low-quality sequences with mean Phred score (*Q* < 30) and adaptors were trimmmed. The first nucleotides were then head-cropped to ensure a per-position A, C, G, T frequency near to 0.25 and only sequences longer than 36 bp were retained for downstream analysis.  
  
***    
### Pseudo alignment and transcript quantification using Kallisto

Once the high quality reads from each RNA-seq project were obtained, the pseudo-aligner kallisto v.0.43.1 was used for fast and accurate transcripts count and abundance.  
Kallisto was run in two steps:  

**1. Building the transcriptome index from all cDNA transcripts of Prunus persica v2, release 39 (Ensembl Plants)**:

```console
cd kallisto  

kallisto index -i prunus_persica.idx Prunus_persica.Prunus_persica_NCBIv2.cdna.all.fa
```

**2. Quantification**

  - For paired-end reads:
  
  ````console
  RESULTS_DIR=~/kallisto_output/
  kallisto quant -i prunus_persica.idx -b 100 reads_1.fastq.gz reads_2.fastq.gz -o ${RESULTS_DIR}
  ````

  - For single-end reads:
add the *--single* </span>  parameter and supply the length *-l*  and standard deviation of the fragment length *-s*:
  
  ````console
  RESULTS_DIR=~/kallisto_output/
  kallisto quant -i prunus_persica.idx -b 100 --single -l 200 -s 20 reads_1.fastq.gz -o ${RESULTS_DIR}
  
  ````

The results of kallisto are saved at the specified output directory **kallisto_output** and should have this structure:

```
kallisto_output
|
└───abundance.h5
│
└───abundance.tsv
│
└───run_info.json
```



The main quantification results are found in the **abundance.tsv** file, where abundances are reported in “estimated counts” (est_counts) and in Transcripts Per Million (TPM). The abundance.tsv file you get should look like this.  


| target_id| length | eff_length|est_counts| tpm    |
| :--------| :----- |:----------|:---------|:-------|
| ONH90035 | 2743   | 2599.58   |82        | 16.7163|
| ONH93890 | 1822   | 624.308   |23        | 19.5235|
| ONH93493 | 3250   | 1957.58   |11.7188   | 13.1724|
| ONH93490 | 2493   | 1876.58   |91.2579   | 25.7711|


***
### Normalization and differential analysis using Sleuth

Differential expression analysis and data normalization were conducted with Sleuth R package v.0.29.0. This analysis was consisted mainly of two steps:

- Normalizing each RNA-seq project separetly and retain the list of differential expressed transcripts (DETs).

- Transcripts from all RNA-seq experiments were normalized together using Sleuth function and then merged into a single list with an assigned mean TPM value for each treatment


```r
#Install packages
source("https://bioconductor.org/biocLite.R")
biocLite("biomaRt")
biocLite("rhdf5")
biocLite("devtools")
biocLite("pachterlab/sleuth")

#Upload the required librairies
library("rhdf5")
library("devtools")
library("sleuth")
library("biomaRt")
library("plyr")

# Define the main directory
dir.main <- "~/kallisto_out/bakir-experiment"
setwd(dir.main)

###################################### STEP 1: Individaul normalization (EXP. Bakir experiment) ##########################
# 1. Bakir experiment
# Specify the path to **kallisto results**
sample_id <- list.files(dir.main, pattern = "kallisto_out/")
kallisto_dirs <- file.path(dir.main, sample_id)

#Load an auxillary table that describes the experimental design and the relationship between the kallisto directories and the samples:
s2c <- read.table(file.path(dir.main,"bhiseq_info.txt"),header = T, stringsAsFactors = F)
s2c <- dplyr::select(s2c, sample = accession, condition)
s2c <- dplyr::mutate(s2c, path = kallisto_dirs)
print(s2c)

# Describe the different conditions
control <- which(s2c$condition == "C_HYD")
treat <- which(s2c$condition == "T_HYD")
s2c_Lt_vs_Lc <- s2c[c(treat,control),]

# Construct the sleuth object (SO) where we will store not only the information about the experiment, but also details of the model to be used for differential  analysis and the results
so <- sleuth_prep(s2c_Lt_vs_Lc, ~ condition, extra_bootstrap_summary = TRUE)

# Perform the differential analysis adopting  the full model and WT test
so <- sleuth_fit(so)
so <-sleuth_wt(so, which_beta = "conditionT_HYD", which_model = "full")
tests(so)
result_table <- sleuth_results(so, "conditionT_HYD", test_type = "wt")
result_ordred <- result_table[order(result_table$qval, decreasing = F),]

# set Qval <= 0.01 and (|β| > 1 as threshold to retain the differentially expressed transcripts 
# Note that β is an approximation to Log(Fold Change)
table(result_ordred$qval <= 0.01)
sleuth_signficant <- dplyr::filter(result_table, qval <= 0.01 & (abs(b)> 1))

# Save the results
write.table(sleuth_signficant[,1], "~/sleuth_out/wt/bakir.txt", sep = "\t", row.names = F)
write.table(sleuth_signficant[,1:5], "~/sleuth_out/expression_data/bakir.txt", sep = "\t", row.names = F)


###################################### STEP 2: All datasets normalization (EXP. Bakir experiment) ##########################


dir.main <- ("~/exper_info")
setwd(dir.main)
## Get the list of samples ID
samples_id <- list.files(path = dir.main, pattern = "kallisto_out")
kallisto_dirs <- file.path(dir.main, samples_id)

## Descibing the experimental design (defining the conditions and the replicates)
s2c <- read.table("all_experiments_info.txt",header = T, stringsAsFactors = F)
s2c <- dplyr::select(s2c, sample = accession, condition)
s2c <- dplyr::mutate(s2c, path = kallisto_dirs)
print(s2c)

## Defining sleuth object (SO) that stores the kallisto results
so <- sleuth_prep(s2c, ~condition, extra_bootstrap_summary = TRUE)

## Merging all normalized tpm of all replicates in one single file (between )
all_tpm <- as.data.frame(sleuth_to_matrix(so,"obs_norm","tpm")) # convert sleuth object to matrix with the condition names
all_tpm <- cbind (target_id = rownames(all_tpm), all_tpm)
rownames(all_tpm)<- NULL
write.table(all_tpm, "~/exper_info/normalized_tpm.txt", sep = "\t", row.names = F)
```



