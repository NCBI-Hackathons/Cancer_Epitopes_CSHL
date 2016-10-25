Please just dump the commands for the different parts of the pipeline in here.

### defining variables that may be used by more then one script

```
BAM=SRR1616919.sorted.bam
MHC_LOCUS=NC_000006.12:29600000-33500000
```

### commands

```
# output: test_read1.fq and test2_read2.fq
bash bam2hla_fastq -b $BAM -r ${MHC_LOCUS} -o test --path /opt/samtools/1.3.1/bin/ 

```
