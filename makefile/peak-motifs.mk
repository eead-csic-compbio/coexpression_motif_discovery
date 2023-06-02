MAKEFILE=~/rsat_results/peak-motifs.mk

# Define the directories
DIR_DATA=/home/rsat_user/test_data
UP1=~/rsat_results/upstream1
UP2=~/rsat_results/upstream2
UP3=~/rsat_results/upstream3
UP4=~/rsat_results/upstream4

# Define the species of interest and the four upstream boundaries
SPECIES=Prunus_persica.Prunus_persica_NCBIv2.38
REGULON=M11
FROM1=-1500
TO1=+200
FROM2=-500
TO2=+200
FROM3=-500
TO3=0
FROM4=0
TO4=+200

# Define the corresponding background for each upstream boundary
BGMSK1=${UP1}/${SPECIES}-up1.rm.fna
BGMSK2=${UP2}/${SPECIES}-up2.rm.fna
BGMSK3=${UP3}/${SPECIES}-up3.rm.fna
BGMSK4=${UP4}/${SPECIES}-up4.rm.fna

# Precise the number of random clusters
RNDSAMPLES=50

# Collect the different upstream sequences from module M11 and prunus persica genome.
retrieve:
	@echo "Creating the result directories"
	@mkdir -p ${UP1}
	@mkdir -p ${UP2}
	@mkdir -p ${UP3}
	@mkdir -p ${UP4}
	@echo "Retrieving 4 upstream sequences boundaries from the genes of module M11"
	@retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM1} -to ${TO1} -noorf -i ${DIR_DATA}/${REGULON}.txt -label id -rm -o ${UP1}/regulon${REGULON}_up1.rm.fna
	@echo "${UP1}/regulon${REGULON}_up1.rm.fna"
	
	@retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM2} -to ${TO2} -noorf -i ${DIR_DATA}/${REGULON}.txt -label id -rm -o ${UP2}/regulon${REGULON}_up2.rm.fna
	@echo "${UP2}/regulon${REGULON}_up2.rm.fna"
	
	@retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM3} -to ${TO3} -noorf -i ${DIR_DATA}/${REGULON}.txt -label id -rm -o ${UP3}/regulon${REGULON}_up3.rm.fna
	@echo "${UP3}/regulon${REGULON}_up3.rm.fna"
	
	@retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM4} -to ${TO4} -noorf -i ${DIR_DATA}/${REGULON}.txt -label id -rm -o ${UP4}/regulon${REGULON}_up4.rm.fna
	@echo "${UP4}/regulon${REGULON}_up4.rm.fna"
	
	
	@echo "Retrieving 4 upstream sequences boundaries from all Prunus persica genome"
	@retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM1} -to ${TO1} -noorf -all -label id -rm -o ${BGMSK1}
	@retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM2} -to ${TO2} -noorf -all -label id -rm -o ${BGMSK2}
	@retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM3} -to ${TO3} -noorf -all -label id -rm -o ${BGMSK3}
	@retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM4} -to ${TO4} -noorf -all -label id -rm -o ${BGMSK4}

# Generate the fifty random clusters
random:
	@echo "Creating ${RNDSAMPLES} random clusters"
	@for r in `seq 1 ${RNDSAMPLES}`; do \
	echo Replicate $$r; \
	NSEQS=`wc -l ${DIR_DATA}/${REGULON}.txt`; \
	RNDREGULON=random$$r.txt; \
	random-genes -n $$NSEQS} -org ${SPECIES} -feattype gene -g 1 -o $$RNDREGULON; \
	done
	
	
	@echo "retrieve the different upstream sequence lengths from the random clusters"
	@for r in `seq 1 ${RNDSAMPLES}`; do \
	echo Replicate $$r; \
	RNDREGULON=random$$r.txt; \
	RNDMSK=random$${r}.rm.fna; \
	retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM1} -to ${TO1} -noorf -rm -i $$RNDREGULON -label id -o ${UP1}/$$RNDMSK; \
	retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM2} -to ${TO2} -noorf -rm -i $$RNDREGULON -label id -o ${UP2}/$$RNDMSK;\
	retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM3} -to ${TO3} -noorf -rm -i $$RNDREGULON -label id -o ${UP3}/$$RNDMSK;\
	retrieve-seq -org ${SPECIES} -feattype gene -from ${FROM4} -to ${TO4} -noorf -rm -i $$RNDREGULON -label id -o ${UP4}/$$RNDMSK;\
	done

####################################################################################
# THIS SECOND PART IS FOR PEAK-MOTIFS ANALYSIS IN DIFFERENTIAL MODE
####################################################################################

# Define the directories
INPUT1=${UP1}/regulon${REGULON}_up1.rm.fna
INPUT2=${UP2}/regulon${REGULON}_up2.rm.fna
INPUT3=${UP3}/regulon${REGULON}_up3.rm.fna
INPUT4=${UP4}/regulon${REGULON}_up4.rm.fna
FOOTDBFILE=/packages/rsat/public_html/motif_databases/footprintDB/footprintDB.plants.motif.tf
DISCO=oligos,dyads
PM_TASKS=purge,seqlen,composition,disco,merge_motifs,split_motifs,timelog,motifs_vs_db,synthesis,small_summary,clean_seq

# Run peak-motifs pipeline
peakmotifs: 
	@echo "Running peak-motifs for M11 within upstream1"
	@peak-motifs -i ${INPUT1} -ctrl ${BGMSK1} -motif_db footprintDB-plants transfac ${FOOTDBFILE} -prefix peaks -outdir ${UP1}/regulon${REGULON}.rm.fna.peaks-rm -title analysis_M11 -origin end \
	-disco ${DISCO} -nmotifs 5 -minol 5 -maxol 8 -scan_markov 1 -noov -img_format png -task ${PM_TASKS}
	@rm -rf ${UP1}/regulon${REGULON}.rm.fna.peaks-rm/data
	
	@echo "Running peak-motifs for random clusters within upstream1"
	for r in `seq 1 ${RNDSAMPLES}`; do \
	echo Replicate $$r; \
	RNDMSK=random$${r}.rm.fna; \
	peak-motifs -i ${UP1}/$${RNDMSK} -ctrl ${BGMSK1} -motif_db footprintDB-plants transfac ${FOOTDBFILE} -prefix peaks -outdir ${UP1}/random$$r.rm.fna.peaks-rm -title analysis_random$$r -origin end -disco \
	${DISCO} -nmotifs 5 -minol 5 -maxol 8 -scan_markov 1 -noov -img_format png -task ${PM_TASKS};\
	rm -rf ${UP1}/random$$r.rm.fna.peaks-rm/data;\
	done
	
	@echo "Running peak-motifs for M11 within upstream2"
	@peak-motifs -i ${INPUT2} -ctrl ${BGMSK2} -motif_db footprintDB-plants transfac ${FOOTDBFILE} -prefix peaks -outdir ${UP2}/regulon${REGULON}.rm.fna.peaks-rm -title analysis_M11 -origin end \
	-disco ${DISCO} -nmotifs 5 -minol 5 -maxol 8 -scan_markov 1 -noov -img_format png -task ${PM_TASKS}
	@rm -rf ${UP2}/regulon${REGULON}.rm.fna.peaks-rm/data
	
	@echo "Running peak-motifs for random clusters within upstream2"
	for r in `seq 1 ${RNDSAMPLES}`; do \
	echo Replicate $$r; \
	RNDMSK=random$${r}.rm.fna; \
	peak-motifs -i ${UP2}/$${RNDMSK} -ctrl ${BGMSK2} -motif_db footprintDB-plants transfac ${FOOTDBFILE} -prefix peaks -outdir ${UP2}/random$$r.rm.fna.peaks-rm -title analysis_random$$r -origin end -disco \
	${DISCO} -nmotifs 5 -minol 5 -maxol 8 -scan_markov 1 -noov -img_format png -task ${PM_TASKS};\
	rm -rf ${UP2}/random$$r.rm.fna.peaks-rm/data;\
	done
	
	@echo "Running peak-motifs for M11 within upstream3"
	@peak-motifs -i ${INPUT3} -ctrl ${BGMSK3} -motif_db footprintDB-plants transfac ${FOOTDBFILE} -prefix peaks -outdir ${UP3}/regulon${REGULON}.rm.fna.peaks-rm -title analysis_M11 -origin end \
	-disco ${DISCO} -nmotifs 5 -minol 5 -maxol 8 -scan_markov 1 -noov -img_format png -task ${PM_TASKS}
	@rm -rf ${UP3}/regulon${REGULON}.rm.fna.peaks-rm/data
	
	
	@echo "Running peak-motifs for random clusters within upstream3"
	for r in `seq 1 ${RNDSAMPLES}`; do \
	echo Replicate $$r; \
	RNDMSK=random$${r}.rm.fna; \
	peak-motifs -i ${UP3}/$${RNDMSK} -ctrl ${BGMSK3} -motif_db footprintDB-plants transfac ${FOOTDBFILE} -prefix peaks -outdir ${UP3}/random$$r.rm.fna.peaks-rm -title analysis_random$$r -origin end -disco \
	${DISCO} -nmotifs 5 -minol 5 -maxol 8 -scan_markov 1 -noov -img_format png -task ${PM_TASKS};\
	rm -rf ${UP3}/random$$r.rm.fna.peaks-rm/data;\
	done
	
	@echo "Running peak-motifs for M11 within upstream4"
	@peak-motifs -i ${INPUT4} -ctrl ${BGMSK4} -motif_db footprintDB-plants transfac ${FOOTDBFILE} -prefix peaks -outdir ${UP4}/regulon${REGULON}.rm.fna.peaks-rm -title analysis_M11 -origin end \
	-disco ${DISCO} -nmotifs 5 -minol 5 -maxol 8 -scan_markov 1 -noov -img_format png -task ${PM_TASKS}
	@rm -rf ${UP4}/regulon${REGULON}.rm.fna.peaks-rm/data
	
	@echo "Running peak-motifs for random clusters within upstream4"
	for r in `seq 1 ${RNDSAMPLES}`; do \
	echo Replicate $$r; \
	RNDMSK=random$${r}.rm.fna; \
	peak-motifs -i ${UP4}/$${RNDMSK} -ctrl ${BGMSK4} -motif_db footprintDB-plants transfac ${FOOTDBFILE} -prefix peaks -outdir ${UP4}/random$$r.rm.fna.peaks-rm -title analysis_random$$r -origin end -disco \
	${DISCO} -nmotifs 5 -minol 5 -maxol 8 -scan_markov 1 -noov -img_format png -task ${PM_TASKS}; \
	rm -rf ${UP4}/random$$r.rm.fna.peaks-rm/data; \
	done


####################################################################################
# THIS THIRD PART IS FOR MATRIX-SCANNING
####################################################################################

SCAN_INPUT=${UP1}/regulon${REGULON}.rm.fna.peaks-rm/results/discovered_motifs/
matrix=m1 #here we are going to scan the first matrix
SCAN_OLIGO_OUTPUT=${UP1}/scan_results/oligo/
SCAN_DYAD_OUTPUT=${UP1}/scan_results/dyad/
SCANMAXPVALUE=1e-4
scan:
	@mkdir -p ${SCAN_OLIGO_OUTPUT}
	@mkdir -p ${SCAN_DYAD_OUTPUT}
	@echo "Run the matrix-scan within long upstream region -1500 +200 for oligo-motif"
	@matrix-scan -v 1 -matrix_format transfac -m ${SCAN_INPUT}/oligos_5-8nt_m1/peaks_oligos_5-8nt_m1.tf -i ${UP1}/regulon${REGULON}_up1.rm.fna \
	-seq_format fasta \
	-pseudo 1 -decimals 1 -2str -origin end -bginput -markov 1 -bg_pseudo 0.01 -return limits -return sites -return pval -lth score 1 -uth pval ${SCANMAXPVALUE} \
	-n score -o ${SCAN_OLIGO_OUTPUT}/scan_oligo_up1.tab
	
	@echo "Run the matrix-scan within long upstream region -1500 +200 for dyad-motif"
	@matrix-scan -v 1 -matrix_format transfac -m ${SCAN_INPUT}/dyads_test_vs_ctrl_m1/peaks_dyads_test_vs_ctrl_m1.tf -i ${UP1}/regulon${REGULON}_up1.rm.fna -seq_format fasta \
	-pseudo 1 -decimals 1 -2str -origin end -bginput -markov 1 -bg_pseudo 0.01 -return limits -return sites -return pval -lth score 1 -uth pval ${SCANMAXPVALUE} \
	-n score -o ${SCAN_DYAD_OUTPUT}/scan_dyad_up1.tab

# Run all target at once
all: retrieve random peakmotifs scan
    
