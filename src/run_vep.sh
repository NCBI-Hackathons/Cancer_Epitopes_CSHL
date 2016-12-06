#!/bin/bash

function vepUsage() {
    echo "Usage: $0 -i input.vcf -o output.vcf -c cache_dir
        -i      Input VCF file. Required.
        -o      Output VCF file. Required.
        -c,    Path to directory with VEP cache files. Required."
}

function exitWithError() {
    echo -e "$1\n" #| tee -a $logfile
    if [ ! -z "$2" ]; then echo "$2"; fi
    vepUsage
    exit 
}

INPUT_VCF=""
OUTPUT_VCF=""
CACHE_DIR=""

# Parse command line arguments
if [ $# -eq 0 ]; then
    exitWithError "Not enough command line arguments."
fi

until [ -z "$1" ]; do 
    case $1 in
        -i)
            INPUT_VCF=${2%/}
            shift; shift;;
        -o)
            OUTPUT_VCF=${2%/}
            shift; shift;;
        -c)
            CACHE_DIR=${2%/}
            shift; shift;;
        -*)
            exitWithError "Invalid option ($2).";;
        *)
            break;;
    esac
done

perl variant_effect_predictor.pl -i $INPUT_VCF --dir_cache $CACHE_DIR --dir_plugins ~/.vep/Plugins --format vcf --vcf --plugin Downstream --plugin Wildtype --symbol --terms SO --flag_pick -o $OUTPUT_VCF
