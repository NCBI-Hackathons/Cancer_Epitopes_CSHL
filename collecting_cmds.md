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
# output: ${OUT_PREFIX}_read1.fq and ${OUT_PREFIX}_read2.fq
bash bam2hla_fastq -b $BAM -r ${MHC_LOCUS} -o ${OUT_PREFIX} --path ${PATH_SAMTOOLS} 

# Annotate RNAseq VCF
nohup  variant_effect_predictor.pl \
   --input_file $VCF \
    --format vcf \
     --terms SO --offline  --force_overwrite \
      --plugin Wildtype --plugin Downstream  \
       --dir ${PATH_VEP}   --vcf --symbol \
        --fork 16  --coding_only --no_intergenic \
         --output_file ${OUT_PREFIX}.annotated.vcf  & 


```

from inside ${repo}/src

```
python3 -c 'import generate_fasta; generate_fasta.generate_fasta_dataframe(${ANNOTATED_VCF}, ${SEQUENCE_CSV}, 21, 9)' 
```
