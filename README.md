# Cancer_Epitopes_CSHL

## Plan

Goal: given a SRA ID, prioritize and quantify variants with respect to immunogenicity (single score) + variant annotation

- use pvacseq to generate the sequences around variants (wt/mutant)
- use FRED2 to make binding predictions
- given the different prediction score, make one immunogenicity score

-------------------------

## Pipeline 

### Getting the variant calls: `SRA-to-VCF`

SRA_ID -1> RNAseq -2> BAM -3> vcf 

taken care of by the [UltraFastHackers](https://github.com/NCBI-Hackathons/Ultrafast_Mapping_CSHL)


### Getting the peptide sequences: `VCF-to-FASTA`

vcf -> peptide sequences (mutated and unmutated)

1. annotate VCF using VEP
2. focus on variants with non-synonymosu changes
3. extract FASTA sequence of 9mers surrounding the variant position within an affected peptide

##### Output:
chr, strand, start, end, mutated_sequence, background_sequence, Transcript_ID/Gene_ID

### Predict the immunogenicity change introduced by the mutation (`FRED2`)

### Variant prioritization

- check the MAF's of variants (shouldn't be frequent)
- filter on expression
- filter/sort on the delta
- OptiTope as implemented in FRED2

### Check if the top variants are known cancer variants 

- Use ClinVar


## Requirements 
* Phyton 3.5 
* Ensembl's [Variant Effect Predictor](http://uswest.ensembl.org/info/docs/tools/vep/index.html)


### Variant Effect Predictor installation  
Variant Effect Predictor requires a few modules and programs which are currently not installed on the AWS instance. Here's how you install them [notes](http://uswest.ensembl.org/info/docs/tools/vep/script/vep_download.html):

~~~~ 
    sudo -u root -s 
    cpanm File::Copy::Recursive   
    cpanm Bio::Root::Version
    cpanm Archive::Zip 
    cpanm  Class::HPLOO::Base
    apt-get install mysql-server 
    apt-get install libmysqlclient-dev  (for mysql_config)
    cpanm DBD::mysql
    wget 'https://github.com/Ensembl/ensembl-tools/archive/release/86.zip'  
    unzip 86.zip 
    cd  ensembl-tools-release-86/variant_effect_predictor/ 
    perl INSTALL.pl  
    
~~~~  
** TODO: copy vep + libraries to /usr/local 
** setup PERL5LIB so VEP libs are included  


#### Test your installation  

     cp  head -1000 /home/data/vcf/hisat_tags_output_SRR1616919.sorted.vcf  > $HOME/test.vcf  

     perl variant_effect_predictor.pl --input_file $HOME/test.vcf \
      --format vcf --output_file test.output --vcf --symbol --terms SO --database \
      --force_overwrite 


#### Install cache files for better peformance 

    cd $HOME/.vep 
    wget ftp://ftp.ensembl.org/pub/release-86/variation/VEP/homo_sapiens_vep_86_GRCh38.tar.gz    
    tar -xzvf homo_sapiens_vep_86_GRCh38.tar.gz 

    perl variant_effect_predictor.pl --input_file $HOME/test.vcf \
     --format vcf --output_file test.output --vcf --symbol --terms SO --offline \
      --force_overwrite 


**TODO** : install chache files globally -  in data dir ? 

#### Install pvacSeq's WT plugin  

    mkdir $HOME/tmp 
    cd $HOME/tmp   
    wget 'https://github.com/griffithlab/pVAC-Seq/archive/master.zip' 
    unzip master.zip
    mkdir -p $HOME/.vep/Plugins
    cp Bio/EnsEMBL/Variation/Utils//Wildtype.pm /home/devsci7/.vep/Plugins/

#### Test WT-Plugin 

### Install all python packages

`pip3 install -r requirements.txt`

`pip2 install -r requirements_python2.txt`

### Download and Install Binding Prediction Software to run with FRED2

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHC

http://www.cbs.dtu.dk/services/doc/netMHC-4.0.readme

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCpan

http://www.cbs.dtu.dk/services/doc/netMHCpan-3.0.readme

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCII

http://www.cbs.dtu.dk/services/doc/netMHCII-2.2.readme

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCIIpan

http://www.cbs.dtu.dk/services/doc/netMHCIIpan-3.0.readme

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?pickpocket

http://www.cbs.dtu.dk/services/doc/pickpocket-1.1.readme

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netCTLpan

http://www.cbs.dtu.dk/services/doc/netCTLpan-1.1.readme

### Install all R packages

