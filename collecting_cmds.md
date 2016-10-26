Please just dump the commands for the different parts of the pipeline in here.

### defining variables that may be used by more then one script

```
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
```

### commands


```
# Get Fastq from BAM for HLA typing
# output: ${OUT_PREFIX}_read1.fq and ${OUT_PREFIX}_read2.fq
bash bam2hla_fastq -b $BAM -r ${MHC_LOCUS} -o ${OUT_PREFIX} --path ${PATH_SAMTOOLS} 

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
python3 -c 'import generate_fasta; generate_fasta.generate_fasta_dataframe(${ANNOTATED_VCF}, ${SEQUENCE_CSV}, 21, 9)' 

# Compute immunogenicity for each peptide

python2 fred2_allele_prediction.py --input=${OUT_PREFIX}_pvacseq_table.csv \
      --output=${OUT_PREFIX}_variant_immunogenicity.csv
```
