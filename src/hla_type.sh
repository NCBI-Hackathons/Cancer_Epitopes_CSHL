#!/bin/bash

function bam2hla() {
  echo "Usage: $0 -b /home/data/hisat_tags_output_SRR1616919_hg38.sorted.bam -r chr6:29600000-33500000 -o test -ps /opt/samtools/1.3.1/bin/ -po /opt/optitype/
    -b,     --BAM               BAM file. Required.
    -r,     --region            Region for which reads will be extracted in this format: <chr:start-end> . Optional.
    -o,     --output            Prefix for output files. Required.
    -ps,    --path_samtools     Path to samtools installation. Optional. E.g. /opt/samtools/1.3.1/bin/
    -po,    --path_optitype     Path to Optitype. Optional. E.g. /opt/samtools/1.3.1/bin/"
    }

function exitWithError() {
  echo -e "$1\n" #| tee -a $logfile
  if [ ! -z "$2" ]; then echo "$2"; fi
  bam2hla
  exit 1
}

function exitWithError2() {
  echo -e "$1\n" #| tee -a $logfile
  if [ ! -z "$2" ]; then echo "$2"; fi
 # bam2hla
  exit 1
}


function checkExitStatus() {
  if [ $? -ne 0 ]; then exitWithError "$1" "$2"; fi
}

# Initialize all options
BAM=""
REGION=""
OUT=""
PATH_S=""
PATH_O=""


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
    -ps | --path_samtools)
      PATH_S=${2%/}
      shift; shift;;
    -po | --path_optitype)
      PATH_O=${2%/}
      shift; shift;;
    -*)
      exitWithError "Invalid option ($2).";;
    *)
      break;;
  esac
done


# extract reads overlapping with MHC locus and turn them into two fastq files
echo "# bam2fq" >> ${OUT}.log
${PATH_S}/samtools view -h $BAM $REGION | ${PATH_S}/samtools bam2fq -1 ${OUT}_read1.fq -2 ${OUT}_read2.fq - 2>>${OUT}.log

# run OptiType for HLA prediction
echo "# running Optitype" >> ${OUT}.log
if [ ! -d "${OUT}_hlatyping" ]; then mkdir ${OUT}_hlatyping; fi
python2 ${PATH_O}/OptiTypePipeline.py --input ${OUT}_read1.fq ${OUT}_read2.fq -r -o ${OUT}_hlatyping 2>>${OUT}.log

folder=`ls -tm "${OUT}"_hlatyping/ | head -n 1 |  awk -F "," '{print $1}'`
ALLELES=`egrep "\*" "${OUT}"_hlatyping/${folder}/${folder}_result.tsv | cut -f 2-7 | sed 's/\s/,/g'`

echo "$ALLELES"

