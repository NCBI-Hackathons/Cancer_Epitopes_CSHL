#!python3
from pvacseq import lib
import tempfile

def generate_fasta(input_vcf, output_fasta, peptide_sequence_length, epitope_length):
    tsv_file = tempfile.NamedTemporaryFile()
    lib.convert_vcf.main([input_vcf, tsv_file.name])
    lib.generate_fasta.main([
        tsv_file.name,
        str(peptide_sequence_length),
        str(epitope_length),
        output_fasta,
        output_fasta + '.key'
    ])
