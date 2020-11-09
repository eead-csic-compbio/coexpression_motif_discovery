MAKEFILE=~/randomTF_validation/randomTF_footdb.mk
MAKE=make -s -f ${MAKEFILE}


## Define the parameters
INPUT=~/randomTF_validation/
LISTTF=${INPUT}/TFs_all_modules.txt
PROTEINSEQ=${INPUT}/TF-seq.fasta

Modules=M6 M7 M18 M21 M41

## sed command to Eliminate all rows that contain the specified pattern 
## cut command only print the column 2(we just need the list of gene ids)


tflist:
	@echo "Generate list of TFs from all modules except module of interest"
	@for m in ${Modules}; do \
	sed -n '/$${m}/!p' ${LISTTF} > ${INPUT}/tfs_except$${m}.txt;\
	done
	@echo
	@echo "Delete extra columns"
	@for m in ${Modules}; do \
	cut -f2 ${INPUT}/tfs_except$${m}.txt > 	${INPUT}/tfs_exc$${m}.txt;\
	done
	@echo
	@echo "Generate 50 random TF for each module"
	@for m in ${Modules}; do \
	shuf ${INPUT}/tfs_exc$${m}.txt -n 50 -o randomTF$${m}.txt;\
	done
	@echo
	#remove files containing the except pattern
	@echo "Remove unnecessary files"
	rm *except*
	@echo 
	@echo "Create a fasta index for protein sequences"
	fasta-make-index TFs_seq.fasta
	@echo 
	@echo "Assign protein sequence to each random TF"
	@for m in ${Modules}; do \
	fasta-fetch  TFs_seq.fasta -f randomTF$${m}.txt -c > 	randomTF_$${m}.fasta;\
	done

footprintdb:
	@echo "Run the footDBclient.pl for each module"
	@for m in ${Modules}; do \
	perl footDBclient.pl -p randomTF_M1.fasta > results_footdb_M1.txt;\
	done
		
