## TFs annotation and prediction of their potential TFBS using FootprintDB

To verify whether modules with predicted motifs might contain their potential binding TFs, gene-encoding TFs were annotated were individually examined for their potential DNA motifs using [footprintDB}(http://floresta.eead.csic.es/footprintdb/).
The results were results were compared to those obtained with RSAT.
For consistency, control subsets of 50 random TFs selected from outside each module were additionally assessed. 
Motif-to-motif similarities between footprintDB and RSAT predicted matrices were computed using the Ncor score. 
Note this is an independent analysis, which does not use the clustered sequences; instead, it uses protein sequence of TFs. 


## Scripts
To reproduce this analysis, 2 scripts are available
1. [randomTF_footDB.mk](https://github.com/eead-csic-compbio/coexpression_motif_discovery/blob/master/footprintdb_predictions/randomTF_footdb.mk) - Genearte 50 random TFs for modules M6, M7, M18, M21 and M41. These subsets of random TFs are retrieved from all TFs annotated in 
(M1, M2, M3, M4, M5, M6, M7, M9, M10, M11, M18, M21, M24, M28, M41, M43 and M44). Subsequently, it assigns a protein sequence for each TF.

2. [footDBclient.pl](https://github.com/eead-csic-compbio/footprintDBclient/blob/main/footDBclient.pl) - is for users that wish to query footprintDB from the command-line through the Web Services interface.


## Results
Please check [Figure S4](https://github.com/eead-csic-compbio/coexpression_motif_discovery/blob/master/footprintdb_predictions/Figure%20S4.pdf)
