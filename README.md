# Cancer_Epitopes_CSHL

## Plan

Goal: given a SRA ID, prioritize and quantify variants with respect to immunogenicity (single score) + variant annotation

- use pvacseq to generate the sequences around variants (wt/mutant)
- use FRED2 to make binding predictions
- given the different prediction score, make one immunogenicity score

-------------------------

## Pipeline 

### Getting the variant calls: `SRA-to-VCF`

SRA_ID -1> RNAseq -2> BAM -3> vcf 

taken care of by the [UltraFastHackers](https://github.com/NCBI-Hackathons/Ultrafast_Mapping_CSHL)


### Getting the peptide sequences: `VCF-to-FASTA`

vcf -> peptide sequences (mutated and unmutated)

1. annotate VCF using VEP
2. focus on variants with non-synonymosu changes
3. extract FASTA sequence of 9mers surrounding the variant position within an affected peptide

##### Output:
chr, strand, start, end, mutated_sequence, background_sequence, Transcript_ID/Gene_ID

### Predict the immunogenicity change introduced by the mutation (`FRED2`)

### Variant prioritization

- check the MAF's of variants (shouldn't be frequent)
- filter on expression
- filter/sort on the delta
- OptiTope as implemented in FRED2

### Check if the top variants are known cancer variants 

- Use ClinVar


## Installation

### Install all python packages

`pip3 install -r requirements.txt`

`pip2 install -r requirements_python2.txt`

### Download and Install Binding Prediction Software to run with FRED2

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHC

http://www.cbs.dtu.dk/services/doc/netMHC-4.0.readme

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCpan

http://www.cbs.dtu.dk/services/doc/netMHCpan-3.0.readme

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCII

http://www.cbs.dtu.dk/services/doc/netMHCII-2.2.readme

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netMHCIIpan

http://www.cbs.dtu.dk/services/doc/netMHCIIpan-3.0.readme

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?pickpocket

http://www.cbs.dtu.dk/services/doc/pickpocket-1.1.readme

http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?netCTLpan

http://www.cbs.dtu.dk/services/doc/netCTLpan-1.1.readme

### Install all R packages

