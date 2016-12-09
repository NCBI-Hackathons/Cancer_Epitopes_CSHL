# Cancer Epitopes CSHL

## Plan

Goal: given an SRA ID, prioritize and quantify variants with respect to immunogenicity (single score) + variant annotation

- use pvacseq to generate the sequences around variants (wt/mutant)
- use FRED2 to make binding predictions
- given the different prediction score, make one immunogenicity score

-------------------------

1. [Annotate VCF](#anno)
2. [Extract peptide sequences](#pvac)
3. [Define sample's MHC alleles](#mhc)
4. [Collect MHC-peptide affinity predictions](#fred2)
5. [Add our own classifier score](#new)

![workflow](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/doc/images/Workflow.png)

More info:

* [Meaning of the different immunogenicity scores returned by FRED2](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/doc/ig_scores.md)
* [How to run and work with the Docker image](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/doc/Docker.md)
* [Notes on individual installations](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/doc/installation_notes.md)


-------------------------

## 1) Annotate RNAseq VCF <a name="anno"></a> 
 
    nohup  variant_effect_predictor.pl \
       --input_file /home/data/vcf/hisat_tags_output_SRR1616919.sorted.vcf  \
        --format vcf \
         --terms SO --offline  --force_overwrite \
          --plugin Wildtype --plugin Downstream  \
           --dir /home/data/vep   --vcf --symbol \
            --fork 16  --coding_only --no_intergenic \
             --output_file /home/data/imm/hisat_tags_output_SRR1616919.sorted.annotated.vcf  & 


## 2a) Generate FASTA with `pVACSeq` and write to csv <a name="pvac"></a> 

The genome information stored in the vcf file need to be translated into corresponding peptide sequences.
For this, we use parts of `pVacSeq`, which generates a csv file with 21-mers surrounding the mutation (both, WT and mutant form)

```
    cd $HOME  
    git clone https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL.git
 
    source activate python3 
    
    cd $HOME/Cancer_Epitopes_CSHL/src   
    python -c 'import generate_fasta; generate_fasta.generate_fasta_dataframe("/home/devsci7/test.output.2", "/home/devsci7/step2.csv", 21,9)'  
```

### 2b) Define MHC locus for HLA genotyping <a name="mhc"></a> 

Tools for HLA genotyping typically re-align the raw reads in order to identify the HLA type from RNA-seq.
To obtain the reads roughly aligned to these genes we need to define the region and specify it during the alignment process.
The MHC complex consists of more than 200 genes located close together on chromosome 6.
The script `hla_type.sh` extracts reads overlapping with the MHC locus and turns them into two fastq files.
These reads are then re-aligned and analyzed by [OptiType](http://dx.doi.org/10.1093/bioinformatics/btu548)

      src/hla_type.sh -b /home/data/hisat_tags_output_SRR1616919.sorted.bam \
        -r NC_000006.12:29600000-33500000 -o test --path /opt/samtools/1.3.1/bin/


### 3) Compute immunogenicity for each peptide <a name="fred2"></a> 

Run the script: `src/imm_predict/fred2_allele_prediction.py` to compute the MHC binding affinity predictions for each reference and alternative allele.   

#### Example

```bash
python2 ./src/imm_predict/fred2_allele_prediction.py \
        ./pvacseq_table.csv ./variant_immunogenicity.csv
```

#### Usage

```
       fred2_allele_prediction.py [--alleles=<alleles_list>] FILE_IN FILE_OUT                          
       fred2_allele_prediction.py -h | --help                                                          
                                                         
```

| Argument | Explanation |
|----------|-------------|
| FILE IN (req.)  | Input csv file with... ??? |
| FILE OUT (req.) | Name for output csv file |                                                                         
| alleles | Comma separated list of target alleles, e.g., `--alleles="B*27:20,B*83:01,A*32:15" ` [Default: use all] |                             


## 4. Create and explore the training data set <a name="new"></a>

* GOAL: classifier learnt on peptides with reported immunogenic cancer neoantigens (WT sequences without immunogenicity)

[Collection of training sets](https://docs.google.com/spreadsheets/d/1zE5Hkxpjl9jVeJWD1OwyvBBlzsAM3xNAUOh42JoVs7g/edit?usp=sharing)

To play around with the data sets, here are the current workflows:

```
# read in the data (this expects that you're in Cancer_Epitopes_CSHL;
# just check the paths that are hard-coded at the moment within the
# script
Rscript --vanilla --slave src/imm_explore/0-read.R
# this should have created data/immunogenic_SNVs-training_sets.csv

export TMPDIR=/tmp/
PYTHON=/opt/modules/i12g/anaconda/3-4.1.1/envs/python27/bin/python 

# calculate the binding affinities
PYTHON src/imm_explore/fred2_design_matrix.py \
	--input=data/immunogenic_SNVs-training_sets.csv \
	--output=data/immunogenic_SNVs-model_data.csv
```

-------------------------------------------------


#### Compute the background protein immunogenicity [optional]

> This needs some discussion and perhaps work?


Given a FASTA file with all human proteins, compute the  immunogenicity for all posible 9-mer peptides. 

**NOTE**: This will take a very long time to compute! 
                   
Script: `src/imm_predict/fred2_background.py`. 

##### Usage:  

```                                                                                               
       fred2_background.py [--alleles=<alleles_list> --top_N=N] FILE_IN FILE_OUT                       
       fred2_background.py -h | --help   
```


| Argument | Explanation |
|----------|-------------|
| FILE IN (req.)  | Input FASTA file with all human proteins, can be retrieved from [ENSEMBL](ftp://ftp.ensembl.org/pub/release-86/fasta/homo_sapiens/pep/Homo_sapiens.GRCh38.pep.all.fa.gz) |
| FILE OUT (req.) | Name for output csv file |                                                                         
| top N | Number of top N proteins to compute the background for. [Default: all]. |    
| alleles | Comma separated list of target alleles, e.g., `--alleles="B*27:20,B*83:01,A*32:15" ` [Default: use all] |                


##### Example:

```bash
python2 ./src/imm_predict/fred2_background.py \
        ./Homo_sapiens.GRCh38.pep.all.fixheader.fa ./background_peptides.csv
```


### Copy file over

> Not sure where this belongs?

    cp  /home/devsci7/step2.fasta   /home/data/imm 

