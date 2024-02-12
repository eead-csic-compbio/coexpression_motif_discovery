
This repository documents recipes to discover cis-regulatory motifs within proximal promoters of plants in [RSAT::Plants](http://rsat.eead.csic.es/plants). 

The reports and data in folder [peach/](./peach/) correspond to the benchmark experiment with peach expression-based gene modules.
You can browse them at [eead-csic-compbio.github.io/coexpression_motif_discovery/peach](https://eead-csic-compbio.github.io/coexpression_motif_discovery/peach) .

The recipes can be executed on the command-line with on a Docker container, as explained in the [tutorial](https://eead-csic-compbio.github.io/coexpression_motif_discovery/peach/Tutorial.html), or using the RSAT Web interfaces, as explained in the [Web protocol](https://github.com/RSAT-doc/motif_discovery_clusters).

![**Legend.** Summary](./peach/flowchart.jpg)

**Citation:** 
[N Ksouri](https://orcid.org/0000-0001-8956-2920)(1), [JA Castro-Mondragón](https://orcid.org/0000-0003-4069-357X) (2,3), F Montardit-Tardà (1), [J van Helden](https://orcid.org/0000-0002-8799-8584) (2), [B Contreras-Moreira](http://orcid.org/0000-0002-5462-907X) (1,4,5), [Y Gogorcena](https://orcid.org/0000-0003-1081-430X) (1) (2021) Tuning promoter boundaries improves regulatory motif discovery in non-model plants: the peach example. Plant Physiology, [https://doi.org/10.1093/plphys/kiaa091](https://doi.org/10.1093/plphys/kiaa091)


**Affiliations**

1. Estación Experimental de Aula Dei-CSIC, Zaragoza, Spain
2. Aix-Marseille Univ, Theory and Approaches of Genome Complexity (TAGC), Marseille, France.
3. Centre for Molecular Medicine Norway (NCMM), Nordic EMBL Partnership, University of Oslo, Norway.
4. Fundacion ARAID, Zaragoza, Spain
5. European Bioinformatics Institute EMBL-EBI, Hinxton, UK

Questions or comments, please contact: nksouri at eead.csic.es


**Docker Biocontainer**  

A docker biocontainer with Regulatory Sequence Analysis Tools (RSAT) image is available [here](https://hub.docker.com/r/biocontainers/rsat). If you have not set a docker engine on your machine, please see the instructions provided by the docker community for a simplified [installation](https://docs.docker.com/install/) procedure.

Once docker is set up, you can get and run the RSAT docker image by typing the following command lines in the terminal:
```
# 1. Get the docker image (This will take 10GB of your filesystem)
# from the Linux/WSL terminal
$docker pull biocontainers/rsat:20230828_cv1

# 2. Create local folders for input data and results named respectively rsat_data/ and rsat_results/
# In addition, a subfolder (rsat_data/genomes) should be created too

$mkdir -p $HOME/rsat_data/genomes rsat_results
$chmod -R a+w rsat_data/genomes rsat_results

# 3. Launch Docker RSAT container
$docker run --rm -v $HOME/rsat_data:/packages/rsat/public_html/data/ -v $HOME/rsat_results:/home/rsat_user/rsat_results -it biocontainers/rsat:20230828_cv1

# you should see a warning that can be safely ignored: 
# * Starting Apache httpd web server apache2
# (13)Permission denied: AH00091: apache2: could not open error log file /var/log/apache2/error.log.
# AH00015: Unable to open logs
# Action 'start' failed.
# The Apache error log may have more information

# 4. Download organism from public RSAT server (in this case Prunus persica)
$download-organism -v 2 -org Prunus_persica.Prunus_persica_NCBIv2.38 -server https://rsat.eead.csic.es/plants

# 5. Test the container
$cd rsat_results 
$make -f ../test_data/peak-motifs.mk RNDSAMPLES=2 all
```   
“rsat_results” and “rsat_data” are two local directories in the host machine serving as a persistant storage volume inside the RSAT docker container.

- The dockerfile used to create this Biocontainer is available [here](https://github.com/rsa-tools/rsat-code/blob/master/docker/Dockerfile)
  
    
    
**Funding**  
This work was partly funded by the Spanish Ministry of Economy and Competitiveness grants AGL2014-52063R, AGL2017-83358-R (MCIU/AEI/FEDER/UE); and the Government of Aragón with grants A44 and A09_17R, which were co-financed with FEDER funds. N Ksouri was hired by project AGL2014-52063R and now funded by a PhD fellowship awarded by the Government of Aragón and co-financed with ESF funds respectively.

![](./logomicin.png)

