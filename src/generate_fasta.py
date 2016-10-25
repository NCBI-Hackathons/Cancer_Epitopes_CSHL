#!python3
from pvacseq import lib
import tempfile
import csv
import shutil
import yaml

def generate_fasta(input_vcf, output_fasta, peptide_sequence_length, epitope_length):
    tsv_file = tempfile.NamedTemporaryFile()
    lib.convert_vcf.main([input_vcf, tsv_file.name])

    tsv_file_copy = tempfile.NamedTemporaryFile(mode='r')
    shutil.copy(tsv_file.name, tsv_file_copy.name)
    reader = csv.DictReader(tsv_file_copy, delimiter='\t')
    filtered_tsv_file = tempfile.NamedTemporaryFile('w')
    writer = csv.DictWriter(filtered_tsv_file, fieldnames=reader.fieldnames, delimiter='\t')
    writer.writeheader()
    for entry in reader:
        if entry['variant_type'] == 'missense':
            writer.writerow(entry)

    lib.generate_fasta.main([
        filtered_tsv_file.name,
        str(peptide_sequence_length),
        str(epitope_length),
        output_fasta,
        output_fasta + '.key'
    ])

def generate_fasta_dataframe(input_vcf, peptide_sequence_length, epitope_length):
    fasta_file = tempfile.NamedTemporaryFile()
    generate_fasta(input_vcf, fasta_file.name, peptide_sequence_length, epitope_length)
    fasta_file_key_path = fasta_file.name + '.key'

    with open(fasta_file_key_path) as fasta_file_key:
        keys = yaml.load(fasta_file_key)

    fasta_file_copy = tempfile.NamedTemporaryFile(mode='r')
    shutil.copy(fasta_file.name, fasta_file_copy.name)
    dataframe = {}
    for line in fasta_file_copy:
        key      = line.rstrip().replace(">","")
        sequence = fasta_file_copy.readline().rstrip()
        ids      = keys[int(key)]
        for id in ids:
            (type, variant_id) = id.split('.', 1)
            if variant_id not in dataframe:
                dataframe[variant_id] = {}
            dataframe[variant_id][type] = sequence

    return dataframe
