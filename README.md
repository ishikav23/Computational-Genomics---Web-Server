# Computational-Genomics---Web-Server

## Salmonella enterica Predictive Webserver

All relevant code is located inside the streamlit folder.

This web server takes in a pair of FASTQ reads and runs these processes, generates these outputs, and uses the following tools :

### Processes:

#### 1)  Assembly

 * Generates an assembly quality report (QUAST)

 #### 2)  Annotation for ABR genes and VFs

 * by blastx-ing FASTQ reads against two databases:
   * antibiotic resistance database (CARD) 
   * virulence factor database (VFDB)   

 #### 3)  Comparative Genomics

 * Generates a distance tree from other salmonella strains in the outbreak, and an NCBI reference genome




### Outputs:

* **Integrated Genome Viewer**- (IGV) shows antibiotic resistance genes and virulence genes. **
* **Distance Tree** - Built using ANI (average nucleotide identity) values between reference and input genomes (including other outbreak genomes)
  * Heat map
* **Quast report**  - Quality report for contig length from reads




### Tools Used:

If you'd like to re-create our pipeline on your local system, you will need to conda install the following dependencies:

**Assembly** - FALCO, Megahit, Trimmomatic, QUAST

**Prediction** - Prodigal, bedtools

**Annotation**- Blastx against CARD & VFDB

```
CARD DB- wget https://card.mcmaster.ca/download/0/broadstreet-v3.2.6.tar.bz2

VFDB- wget http://www.mgc.ac.cn/VFs/Down/VFDB_setA_pro.fas.gz 
```

**Comparative Genomics** - FastANI, scipy for generating tree and matplotblib and seaborn for graphics

### Scripts info

All the needed scripts used to run the pipeline are in the /streamlit/scripts folder. The main wrapper nexflow script to run is the **cgen_flow.nf** which calls all other scripts as needed.

### Setting up conda environments

The pipeline which is wrapped with the nexflow script requires 3 conda environments to run that are named nf (used to install nexflow), cgen (includes almost all tools needed for the pipeline with exception of igv-reports as it needs a different python version), igv (includes the igv-reports command ans samtools).

All environments can be setup with the .yml files located in the /streamlit/envs folder by typing this command 

```
conda env create -f [environment.yml file]
```

### Databases info

The **/streamlit/databases** folder contains the card databases in the **card_db** subfolder, virulence database in the **virulence_db** subfolder, and the 50 assembled contigs in the **phylogeny** subfolder used to help construct the phylogenetic tree and heatmaps while integrating the input fq.gz pairs.

### Inner workings of the backend

The website accepts an **fq.gz pair** and then a new folder with the same name as the job ID is generated inside the jobs folder. In there an **input folder** is generated in which the 2 **fq.gz** files are sent to. From there the nexflow script is run like this (--loc flag is optional). Note you need to be in the **nf** conda environment

```
nexflow run /home/projects/team2/app/scripts/cgen_flow.nf --job [JOB ID] --loc [OPTIONAL app folder location. By default set to /home/projects/team2/app/].
```

Then that script calls the other bash scripts involved in assembly, prediction, annotation, comparative genomics. Once that is done a final **output** folder inside the folder that is named after the job ID is generated with all the relevant output files and reports to display on the website.
