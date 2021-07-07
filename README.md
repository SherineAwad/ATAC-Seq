Author: Sherine Awad 

A snakefile pipeline for ATAC-Seq.

Change the config.yaml file appropriately according to your data. 
Update sample names, parameters of Genrich in the config file. Also, change workdir where the samples exist, reference genome,  etc. 

Then run: snakemake -jnumber_of_cores, for example for 5 cores use:

    snakemake -j5 

and for a dry run use: 

    snakemake -j1 -n 


and to print the commands in a dry run use:

    snakemake -j1 -n -p 

For the sake eproducibility, use conda to pull same versions of tools. Snakemake and conda have to be installed in your system:

 
   snakemake --cores --use-conda
