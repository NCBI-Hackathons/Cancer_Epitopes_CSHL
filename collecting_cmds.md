Please just dump the commands for the different parts of the pipeline in here.

### defining variables that may be used by more then one script

```
export PATH="/opt/python/anaconda2/bin:$PATH"
export PATH="/opt/netMHC-4.0/Linux_x86_64/bin/:$PATH"
export PATH="/opt/netCTLpan-1.1/Linux_x86_64/bin/:$PATH"
export PATH="/opt/netMHCII-2.2/Linux_x86_64/bin/:$PATH"
export PATH="/opt/netMHCIIpan-3.1/:$PATH"
export PATH="/opt/netMHCpan-3.0/Linux_x86_64/bin/:$PATH"
export PATH="/opt/pickpocket-1.1/:$PATH"
export PATH="/opt/optitype/:/opt/glpk/4.6.0/bin/:$PATH"


BAM=SRR1616919.sorted.bam
OUT_PREFIX=hisat_tags_output_SRR1616919
MHC_LOCUS=NC_000006.12:29600000-33500000
VCF=/home/data/vcf/hisat_tags_output_SRR1616919.sorted.vcf 
ANNOTATED_VCF
SEQUENCE_CSV
```

Paths to tools

```
PATH_VEP=home/data/vep
PATH_SAMTOOLS=/opt/samtools/1.3.1/bin/
PATH_OPTITYPE=/opt/optitype/OptiTypePipeline.py
```

### commands


```
# Get Fastq from BAM for HLA typing
# output: ${OUT_PREFIX}_read1.fq and ${OUT_PREFIX}_read2.fq
bash bam2hla_fastq -b $BAM -r ${MHC_LOCUS} -o ${OUT_PREFIX} --path ${PATH_SAMTOOLS}
# run OptiType for HLA prediction
mkdir hlatyping
python2 ${PATH_OPTITYPE} --input ${OUT_PREFIX}_read1.fq ${OUT_PREFIX}_read2.fq -r -o hlatyping

FOLD=`ls hlatyping/`
ALLELES=`egrep "\*" hlatyping/${FOLD}/${FOLD}_result.tsv | cut -f 2-7 | sed 's/\s/,/g'`


# Annotate RNAseq VCF
variant_effect_predictor.pl \
   --input_file $VCF \
    --format vcf \
     --terms SO --offline  --force_overwrite \
      --plugin Wildtype --plugin Downstream  \
       --dir ${PATH_VEP}   --vcf --symbol \
        --fork 16  --coding_only --no_intergenic \
         --output_file ${OUT_PREFIX}.annotated.vcf

# Generate FASTA with pVACSeq and write to csv
python3 generate_fasta.py --input=${OUT_PREFIX}.annotated.vcf --output=${OUT_PREFIX}_pvacseq_table.csv --peptide_sequence_length=21

# Compute immunogenicity for each peptide

python2 fred2_allele_prediction.py --input=${OUT_PREFIX}_pvacseq_table.csv \
      --output=${OUT_PREFIX}_variant_immunogenicity.csv
```
