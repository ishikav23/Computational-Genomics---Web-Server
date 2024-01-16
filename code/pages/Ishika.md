## Salmonella enterica Predictive Webserver

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

**Comparative Genomics** - FastANI, matplotblib and seaborne for graphics



