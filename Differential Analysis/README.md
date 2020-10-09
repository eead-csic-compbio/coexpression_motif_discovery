## RNA-seq analysis  
------

This repository is used to store the code for detailed RNA-seq analysis.

- [Raw data material](#Raw-data-material)
- [Quality control](#Quality-control)
- [Pseudo alignment using Kallisto](#Pseudoalignment-using-Kallisto)
- [Normalization and differential analysis](#Normalization-and-differential-analysis)  



### Raw data material
Eight peach RNA-sequencing datasets of various peach cultivars under different stress conditions and from various tissues were used for this project. All the raw data files were downloaded from the European Nucleotide Archive (https://www.ebi.ac.uk/ena).


| Project IDs    | Experiments        | Tissues     |libraries type  |
| :--------------| :-----------------:|:-----------:|:--------------:|
| PRJNA271307    | Ripening stage     | Fruit       |single-end      |
| PRJNA288567    | Cold storage       | Fruit       |paired-end      |
| PRJNA248711    | Hyper hydricity    | Leaf        |paired-end      |
| PRJEB12334     | Drought            | Root/Leaf   |paired-end      |
| PRJNA252780    | Low T°             | Stigma      |single-end      |
| PRJNA323761    | Drought            | Root        |paired-end      |
| PRJNA328435    | Cold storage       | Fruit       |paired-end      |
| PRJNA397885    | Chilling injury    | Fruit       |paired-end      |



### Quality control

Quality metrics of the raw sequences was assessed using FastQC v.0.11.5 and Trimmomatic v.0.36.
For more details please refer to FastQC main page and manual (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and check the video tutorial here:http://www.youtube.com/watch?v=bz93ReOv87Y. 

Briefly, low-quality sequences with mean Phred score (*Q* < 30) and adaptors were trimmmed. The first nucleotides were then head-cropped to ensure a per-position A, C, G, T frequency near to 0.25 and only sequences longer than 36 bp were retained for downstream analysis.  
  
    
### Pseudo alignment using Kallisto    
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

The results of kallisto are saved at the specified output directory **kallisto_output** and the contents of the directory should look like this:
<ul> abundance.h5 </ul>
 <ul> abundance.tsv </ul>
  <ul> run_info.json </ul>
