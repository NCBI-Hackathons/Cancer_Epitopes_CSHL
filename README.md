# Cancer_Epitopes_CSHL

## Pipeline 

### Getting the variant calls: `SRA-to-VCF`

SRA_ID -1> RNAseq -2> BAM -3> vcf 

taken care of by the [UltraFastHackers](https://github.com/NCBI-Hackathons/Ultrafast_Mapping_CSHL)

* annotate with VEP?


### Getting the background + sample 'epitope' sequence: `VCF-to-FASTA`

vcf -> peptide sequences (mutated and unmutated)

Format table:
chr, strand, start, end, mutated_sequence, background_sequence, ?Transcript_ID/Gene_ID


### Predict the immunogenicity change introduced by the mutation (`FRED2`)

### Variant prioritization

- check the MAF's of variants (shouldn't be frequent)
- filter on expression
- filter/sort on the delta
- OptiTope as implemented in FRED2

### Check if the top variants are known cancer variants 

- Use ClinVar

## Plan

Goal: given a SRA ID, prioritize and quantify variants with respect to immunogenicity (single score) + variant annotation

- use pvacseq to generate the sequences around variants (wt/mutant)
- use FRED2 to make binding predictions
- given the different prediction score, make one immunogenicity score


## Installation

Install all python packages with

pip3 install -r requirements.txt
pip2 install -r requirements_python2.txt

Install all R packages

