[![Snakemake](https://img.shields.io/badge/snakemake-≥6.0.2-brightgreen.svg)](https://snakemake.github.io)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![DOI](https://zenodo.org/badge/362067971.svg)](https://zenodo.org/badge/latestdoi/362067971)


Snakemake Workflow for ATAC-Seq  
=====================================

A snakefile pipeline for ATAC-Seq.

Change the config.yaml file appropriately according to your data. 
Update replicate1.tsv and replicate2.tsv for Replicates 1 and Replicates 2 respectively. 
Update parameters of Genrich in the config file. 


Then run: snakemake -jnumber_of_cores, for example for 5 cores use:

    snakemake -j5 

and for a dry run use: 

    snakemake -j1 -n 


and to print the commands in a dry run use:

    snakemake -j1 -n -p 

To use another config file use: 

    snakemake -j1 -p --configfile configfilehere.yaml

For the sake reproducibility, use conda to pull same versions of tools. Snakemake and conda have to be installed in your system:

    snakemake --cores --use-conda

### Cite US

If you use this pipeline, please cite us using this DOI:  "doi:10.5281/zenodo.5939988"
