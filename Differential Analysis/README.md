## RNA-seq analysis  
------

This repository is used to store the code for detailed RNA-seq analysis.

- [Raw data material](#Raw-data-material)
- [Quality control](#Quality-control)
- [Pseudo alignment using Kallisto](#Pseudoalignment-using-Kallisto)
- [Normalization and differential analysis](#Normalization-and-differential-analysis)  


### Raw data material
Eight peach RNA-sequencing datasets of various peach cultivars under different stress conditions and from various tissues were used for this project. All the raw data files were downloaded from the European Nucleotide Archive (https://www.ebi.ac.uk/ena).


| Project IDs    | Experiments        | Tissues     |
| :--------------| :-----------------:|:-----------:|
| PRJNA271307    | Ripening stage     | Fruit       |
| PRJNA288567    | Cold storage       | Fruit       |
| PRJNA248711    | Hyper hydricity    | Leaf        |
| PRJEB12334     | Drought            | Root/Leaf   |
| PRJNA252780    | Low T°             | Stigma      |
| PRJNA323761    | Drought            | Root        |
| PRJNA328435    | Cold storage       | Fruit       |
| PRJNA397885    | Chilling injury    | Fruit       |


### Quality control
Quality metrics of the raw sequences was assessed using FASTQC v.0.11.5 and Trimmomatic v.0.36.
For more details about please refer to FASTQC main page and manual (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
