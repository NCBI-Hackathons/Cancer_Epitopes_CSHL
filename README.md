# Cancer_Epitopes_CSHL

## Pipeline 

### Getting the variant calls

SRA_ID -1> RNAseq -2> BAM -3> vcf 

1: download
- ncbi-vdb `prefetch` tool 


2: alignment
- streaming mapper?
- BWA (RNAseq) / STAR

3. variant calling
- HC in RNAseq mode
- filtering:
   - quality
   - ?sanity check the expression profile of some genes


### Getting the background + sample 'epitope' sequence 

vcf -> peptide sequences (mutated and unmutated)

Format table:
chr, strand, start, end, mutated_sequence, background_sequence, ?Transcript_ID/Gene_ID


### Predict the immunogenicity change introduced by the mutation

- check what the previous group has done
- 

### Variant prioritization

- check the MAF's of variants (shouldn't be frequent)
- filter on expression
- filter/sort on the delta
- 

### Check if the top variants are known cancer variants 

- Use ClinVar

## Plan

Goal: given a SRA ID, prioritize and quantify variants wrt immunogenicity (single score) + variant annotation

- use pvacseq to generate the sequences around variants (wt/mutant)
- given the different prediction score, make one immunogenicity score




