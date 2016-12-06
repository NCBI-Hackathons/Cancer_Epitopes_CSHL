#!/bin/bash
function immsnp_main() {
  echo "Usage: $0 -b SRR1616919.sorted.bam -r NC_000006.12:29600000-33500000 -o test --path /opt/samtools/1.3.1/bin/
    -b,     --BAM               BAM file. Required.
    -r,     --region            Region for which reads will be extracted in this format: <chr:start-end> . Optional.
    -o,     --output            Prefix for output files. Required.
    -p,     --path              Path to samtools installation. Optional."
    }

function exitWithError() {
  echo -e "$1\n" 
  if [ ! -z "$2" ]; then echo "$2"; fi
  immsnp_main
  exit 1
}

function exitWithError2() {
  echo -e "$1\n" 
  if [ ! -z "$2" ]; then echo "$2"; fi
  exit 1
}


function checkExitStatus() {
  if [ $? -ne 0 ]; then exitWithError "$1" "$2"; fi
}

# Initialize all options

HLALOCUS=chr6:29600000-33500000
BAM=""
OUT=testrun

VCF=""
VCF_ANNO=/home/linuxbrew/test_hisat_SRR1616919_annotated.vcf


# Parse command line arguments
if [ $# -eq 0 ]; then
   exitWithError "Not enough command line arguments."
fi

until [ -z "$1" ]; do 
  case $1 in
    -b | --BAM) 
      BAM=${2%/}
      shift; shift;;
    -r | --region)
      REGION=${2%/}
      shift; shift;;
    -o | --output)
      OUT=${2%/}
      shift; shift;;
    -p | --path)
      PATH=${2%/}
      shift; shift;;
    -*)
      exitWithError "Invalid option ($2).";;
    *)
      break;;
  esac
done 


# Definitions for the Docker image [optional parameters --> these are the default settings!]  
SRC_FOLDER=/home/linuxbrew/Cancer_Epitopes_CSHL/src 
SAMTOOLS=/root/samtools/
OPTITYPE=/usr/local/bin/OptiType/

###################################################################


# annotate the VCF file using VEP
TMP=`basename "$VCF" .vcf`
VCF_ANNO=`echo $"TMP".VEPanno.vcf`

echo "Annotating $VCF with VEP"
variant_effect_predictor.pl  --input_file $VCF  --format vcf --terms SO --offline --force_overwrite --plugin Wildtype --plugin Downstream --dir /home/data/vep  --vcf --symbol --fork 16  --coding_only --no_intergenic  --output_file $VCF_ANNO &

# determine HLA alleles 
echo "Determining the HLA alleles"
ALLELES=`bash ${SRC_FOLDER}/hla_type.sh -b "$BAM" -r "$HLALOCUS" -o "$OUT"_hla -ps "$SAMTOOLS" -po "$OPTITYPE" `

wait

# use python3 env managed by conda  
source /opt/conda/bin/activate python3

# obtain the peptide sequences for the proteins affected by missense mutations
echo "Extracting the peptide sequences for the mutated proteins and their WT counterparts"
FASTA_OUTPUT=${OUT}_pep_seq 
python ${SRC_FOLDER}/generate_fasta.py --input=$VCF_ANNO --output=$FASTA_OUTPUT --peptide_sequence_length=21

echo "File $FASTA_OUTPUT generated"  

echo "Predicting the peptides' immunogenicity using FRED2"
FRED_PREDICTION=${OUT}_variant_immunogenicity.csv
${SRC_FOLDER}/imm_predict/fred2_allele_prediction.py --input=$FASTA_OUTPUT --output=$FRED_PREDICTION --alleles=$ALLELES

echo "File $FRED_PREDICTION generated" 
