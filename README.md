
This repository documents recipes to discover cis-regulatory motifs within proximal promoters of plants in [RSAT::Plants](http://rsat.eead.csic.es/plants). 

The reports and data in folder [peach/](./peach/) correspond to the benchmark experiment with peach expression-based gene modules.
You can browse them at [eead-csic-compbio.github.io/coexpression_motif_discovery/peach](https://eead-csic-compbio.github.io/coexpression_motif_discovery/peach) .

**Authors**

N Ksouri (1), JA Castro-Mondragón (2,3), F Montardit-Tardà (1), J van Helden (2), B Contreras-Moreira (1,4,5), Y Gogorcena (1)

1. Estación Experimental de Aula Dei-CSIC, Zaragoza, Spain
2. Aix-Marseille Univ, Theory and Approaches of Genome Complexity (TAGC), Marseille, France.
3. Centre for Molecular Medicine Norway (NCMM), Nordic EMBL Partnership, University of Oslo, Norway.
4. Fundacion ARAID, Zaragoza, Spain
5. European Bioinformatics Institute EMBL-EBI, Hinxton, UK

Questions or comments, please contact: nksouri at eead.csic.es


**Docker container**  

A docker container with Regulatory Sequence Analysis Tools (RSAT) image is available [here](https://hub.docker.com/r/ksouri1/rsat_nksouri). If you have not set a docker engine on your machine, please see the instructions provided by the docker community for a simplified [installation](https://docs.docker.com/install/) procedure.

Once docker is set up, you can get and run the RSAT docker image by typing the following command lines in the terminal:
```
# Get the docker image
docker pull ksouri1/rsat_nksouri

# Run the docker container
docker run --rm -v ~/rsat_data:/packages/rsat/public_html/data/ -v ~/rsat_results:/home/rsat/rsat_results -it ksouri1/rsat_nksouri

```   
“rsat_results” and “rsat_data” are two local directories in the host machine serving as a persistant storage volume inside the RSAT docker container.
  
  
**Findings**  
This work was partly funded by the Spanish Ministry of Economy and Competitiveness grants AGL2014-52063R, AGL2017-83358-R (MCIU/AEI/FEDER/UE); and the Government of Aragón with grants A44 and A09_17R which were co-financed with FEDER funds. N. Ksouri was hired-project (AGL2014-52063R) and supported by PhD contract awarded by the Government of Aragón



![**Legend.** Summary](./peach/flowchart.jpg)

