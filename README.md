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

1. annotate VCF using VEP **done** 
2. focus on variants with non-synonymosu changes **done** 
3. extract FASTA sequence of 9mers surrounding the variant position within an affected peptide **done**

##### Output:
chr, strand, start, end, mutated_sequence, background_sequence, Transcript_ID/Gene_ID **running**

### Predict the immunogenicity change introduced by the mutation (`FRED2`)

### Variant prioritization

- check the MAF's of variants (shouldn't be frequent) - can be done with VEP
- filter on expression 
- filter/sort on the delta
- OptiTope as implemented in FRED2
    * OptiTope tries to _identify peptides that elicit a broad and potent immune response in the target population_, therefore a common allele weighs more than an uncommon allele

### Check if the top variants are known cancer variants 

- Use ClinVar
- vcf from ICGC


## Requirements and pre-requisites ... 
* Phyton 3.5 
* Ensembl's [Variant Effect Predictor](http://uswest.ensembl.org/info/docs/tools/vep/index.html)


### Variant Effect Predictor installation  
Variant Effect Predictor (VEP) requires a few modules and programs which are currently not installed on the AWS instance. Notes how to install VEP are [here](http://uswest.ensembl.org/info/docs/tools/vep/script/vep_download.html):

~~~~ 
    sudo -u root -s 
    cpanm File::Copy::Recursive   
    cpanm Bio::Root::Version
    cpanm Archive::Zip  

    cpanm  Class::HPLOO::Base  

    apt-get install libssl-dev  (for openssl.h)
    cpanm LWP::Protocol::https 

    apt-get install mysql-server 
    apt-get install libmysqlclient-dev  (for mysql_config) 

    cpanm DBD::mysql 

    cd $HOME 
    wget 'https://github.com/Ensembl/ensembl-tools/archive/release/86.zip'  
    unzip 86.zip 
    cd  $HOME/ensembl-tools-release-86/scripts/variant_effect_predictor/ 
    perl INSTALL.pl   

    cp variant_effect_predictor.pl /usr/local/bin 
    chmod a+x  /usr/local/bin/variant_effect_predictor.pl 
~~~~    

#### Copy VEP modules over 

     cd  $HOME/ensembl-tools-release-86/scripts/variant_effect_predictor/ 
     cp -rn Bio  /usr/local/share/perl/5.18.2/  

     chmod -R a+x /usr/local/share/perl/5.18.2/Bio 
     chmod -R a+r /usr/local/share/perl/5.18.2/Bio 

#### Test your installation  

     head -1000 /home/data/vcf/hisat_tags_output_SRR1616919.sorted.vcf  > $HOME/test.vcf  

     variant_effect_predictor.pl --input_file $HOME/test.vcf \
      --format vcf --output_file test.output --vcf --symbol --terms SO --database \
       --force_overwrite 


    
#### Install cache files for better peformance 

    mkdir -p /home/data/vep
    cd       /home/data/vep
    wget ftp://ftp.ensembl.org/pub/release-86/variation/VEP/homo_sapiens_vep_86_GRCh38.tar.gz    

    cp homo_sapiens_vep_86_GRCh38.tar.gz /home/data/vep 


#### Install pvacSeq's WT plugin  

    mkdir -p /home/data/vep/Plugins 
    wget 'https://github.com/griffithlab/pVAC-Seq/archive/master.zip' 
    unzip master.zip
    cp pVAC-Seq-master/pvacseq/VEP_plugins/Wildtype.pm /home/data/vep/Plugins 

#### Downstream plugin 

    cd  cd /home/data/vep/Plugins 
    wget https://github.com/Ensembl/VEP_plugins/archive/release/86.zip
    unzip 86.zip
    mv VEP_plugins-release-86/Downstream.pm  . 
    rm -rf VEP_plugins-release-86/
    rm 86.zip 

#### Test both plugins
 
    nohup  variant_effect_predictor.pl \
       --input_file /home/data/vcf/hisat_tags_output_SRR1616919.sorted.vcf  \
        --format vcf \
         --terms SO --offline  --force_overwrite \
          --plugin Wildtype --plugin Downstream  \
           --dir /home/data/vep   --vcf --symbol \
            --fork 4 \
             --output_file /home/data/imm/hisat_tags_output_SRR1616919.sorted..annotated.vcf  & 

### Download protein data 
Download protein data and change Ensembl's fasta header to work with our tools downstream. 

      mkdir -p /home/data/peptides 
      cd /home/data/peptides 
  
      wget ftp://ftp.ensembl.org/pub/release-86/fasta/homo_sapiens/pep/Homo_sapiens.GRCh38.pep.all.fa.gz 
      perl ./Cancer_Epitopes_CSHL/src/fix_headers.pl Homo_sapiens.GRCh38.pep.all.fa.gz > Homo_sapiens.GRCh38.pep.all.fixheader.fa 


### Define MHC locus for HLA genotyping

Tools for HLA genotyping typically re-align the raw reads in order to identify the HLA type from RNA-seq.
To obtain the reads roughly aligned to these genes we need to define the region and specify it during the alignment process.
The MHC complex consists of more than 200 genes located close together on chromosome 6.

      BAM=/home/data/hisat_tags_output_SRR1616919.sorted.bam
      REGION=NC_000006.12:29600000-33500000
      OUT=`basename "$BAM" .sorted.bam`
      
      # extract reads overlapping with MHC locus and turn them into two fastq files
      samtools view -h $BAM $REGION | samtools bam2fq -1 ${OUT}_read1.fq -2 ${OUT}_read2.fq -

### Install all python packages

`pip3 install -r requirements.txt`

`pip2 install -r requirements_python2.txt`

### Download and Install Binding Prediction Software to run with FRED2

|Software|Download Link|Installation Instructions|
|--------|-------------|-------------------------|
|netMHC|http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHC|http://www.cbs.dtu.dk/services/doc/netMHC-4.0.readme|
|netMHCpan|http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCpan|http://www.cbs.dtu.dk/services/doc/netMHCpan-3.0.readme|
|netMHCII|http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCII|http://www.cbs.dtu.dk/services/doc/netMHCII-2.2.readme|
|netMHCIIpan|http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCIIpan|http://www.cbs.dtu.dk/services/doc/netMHCIIpan-3.0.readme|
|PickPocket|http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?pickpocket|http://www.cbs.dtu.dk/services/doc/pickpocket-1.1.readme|
|netCTLpan|http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netCTLpan|http://www.cbs.dtu.dk/services/doc/netCTLpan-1.1.readme|

### Install all R packages


## Sharpen up : Run the pipline

### 1) Annotate RNAseq VCF   
 
    nohup  variant_effect_predictor.pl \
       --input_file /home/data/vcf/hisat_tags_output_SRR1616919.sorted.vcf  \
        --format vcf \
         --terms SO --offline  --force_overwrite \
          --plugin Wildtype --plugin Downstream  \
           --dir /home/data/vep   --vcf --symbol \
            --fork 16  --coding_only --no_intergenic \
             --output_file /home/data/imm/hisat_tags_output_SRR1616919.sorted.annotated.vcf  & 


### 2) Generate FASTA with pVACSeq 

    cd $HOME  
    git clone https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL.git
 
    source activate python3 
    
    cd $HOME/Cancer_Epitopes_CSHL/src   
    python -c 'import generate_fasta; print(generate_fasta.generate_fasta_dataframe("/home/devsci7/test.output.2",21,9))'  


### 2B) Write to file 

    python -c 'import generate_fasta; \
     generate_fasta.generate_fasta("/home/devsci7/test.output.2", \
     "/home/devsci7/step2.fasta", 21, 9)' 


### Copy file over 

    cp  /home/devsci7/step2.fasta   /home/data/imm 

