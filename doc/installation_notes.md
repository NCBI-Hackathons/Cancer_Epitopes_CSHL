Installation notes
================================


* [Python](#python)
* [Variant Effect Predictor (VEP)](#VEP)
* [FRED2 dependencies](#fred2)


Python 2.7 and 3 packages <a name="python"></a>
--------------------------

`pip3 install -r requirements.txt`

`pip2 install -r requirements_python2.txt`


Variant Effect Predictor installation <a name="VEP"></a>
---------------------------------------

Variant Effect Predictor (VEP) requires a few modules and programs which are currently not installed on the AWS instance. Notes on how to install VEP are [here](http://uswest.ensembl.org/info/docs/tools/vep/script/vep_download.html):

```
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
``` 

### Copy VEP modules over 

```
     cd  $HOME/ensembl-tools-release-86/scripts/variant_effect_predictor/ 
     cp -rn Bio  /usr/local/share/perl/5.18.2/  

     chmod -R a+x /usr/local/share/perl/5.18.2/Bio 
     chmod -R a+r /usr/local/share/perl/5.18.2/Bio 
```

### Test your installation  

```
     head -1000 /home/data/vcf/hisat_tags_output_SRR1616919.sorted.vcf  > $HOME/test.vcf  

     variant_effect_predictor.pl --input_file $HOME/test.vcf \
      --format vcf --output_file test.output --vcf --symbol --terms SO --database \
       --force_overwrite 
```

### Install cache files for better peformance 

```
    mkdir -p /home/data/vep
    cd       /home/data/vep
    wget ftp://ftp.ensembl.org/pub/release-86/variation/VEP/homo_sapiens_vep_86_GRCh38.tar.gz    
    cp homo_sapiens_vep_86_GRCh38.tar.gz /home/data/vep 
```

### Install pvacSeq's WT plugin  

```
    mkdir -p /home/data/vep/Plugins 
    wget 'https://github.com/griffithlab/pVAC-Seq/archive/master.zip' 
    unzip master.zip
    cp pVAC-Seq-master/pvacseq/VEP_plugins/Wildtype.pm /home/data/vep/Plugins 
```

### Downstream plugin 

```
    cd  cd /home/data/vep/Plugins 
    wget https://github.com/Ensembl/VEP_plugins/archive/release/86.zip
    unzip 86.zip
    mv VEP_plugins-release-86/Downstream.pm  . 
    rm -rf VEP_plugins-release-86/
    rm 86.zip 
```

### Test both plugins
 
```
    nohup  variant_effect_predictor.pl \
       --input_file /home/data/vcf/hisat_tags_output_SRR1616919.sorted.vcf  \
        --format vcf \
         --terms SO --offline  --force_overwrite \
          --plugin Wildtype --plugin Downstream  \
           --dir /home/data/vep   --vcf --symbol \
            --fork 4 \
             --output_file /home/data/imm/hisat_tags_output_SRR1616919.sorted..annotated.vcf  & 
```

### Download protein data 

Download protein data and change Ensembl's fasta header to work with our tools downstream. 

```
      mkdir -p /home/data/peptides 
      cd /home/data/peptides 
  
      wget ftp://ftp.ensembl.org/pub/release-86/fasta/homo_sapiens/pep/Homo_sapiens.GRCh38.pep.all.fa.gz 
      perl ./Cancer_Epitopes_CSHL/src/fix_headers.pl Homo_sapiens.GRCh38.pep.all.fa.gz > Homo_sapiens.GRCh38.pep.all.fixheader.fa 
```

Download and Install Binding Prediction Software run by FRED2 <a name="fred2"></a>
------------------------------------------------------------------

|Software|Download Link|Installation Instructions|
|--------|-------------|-------------------------|
| netMHC | http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHC|http://www.cbs.dtu.dk/services/doc/netMHC-4.0.readme|
| netMHCpan | http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCpan | http://www.cbs.dtu.dk/services/doc/netMHCpan-3.0.readme|
| netMHCII | http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCII | http://www.cbs.dtu.dk/services/doc/netMHCII-2.2.readme|
| netMHCIIpan | http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCIIpan | http://www.cbs.dtu.dk/services/doc/netMHCIIpan-3.0.readme|
| PickPocket | http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?pickpocket | http://www.cbs.dtu.dk/services/doc/pickpocket-1.1.readme |
| netCTLpan | http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netCTLpan| http://www.cbs.dtu.dk/services/doc/netCTLpan-1.1.readme |


Install all R packages
----------------------
