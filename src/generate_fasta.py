#!python3
"""
Extract mutant and wildtype peptide sequences for missense variants in a VCF file

Usage:
        generate_fasta.py --input=FILE_IN --output=FILE_OUT --peptide_sequence_length=INT
        generate_fasta.py -h | --help

Arguments:
  --input=FILE_IN                   VEP-annotated input VCF file
  --output=FILE_OUT                 Output csv file with peptide sequences
  --peptide_sequence_length=INT     Length to use for extracting peptide sequences
"""

from docopt import docopt
from pvacseq import lib
import tempfile
import csv
import yaml
import pandas
import os
import shutil

def generate_fasta(input_vcf, peptide_sequence_length):
    temp_dir = tempfile.mkdtemp()
    tsv_file_path = os.path.join(temp_dir, 'tmp.tsv')
    lib.convert_vcf.main([input_vcf, tsv_file_path])

    with open(tsv_file_path, 'r') as tsv_file:
        reader = csv.DictReader(tsv_file, delimiter='\t')
        filtered_tsv_file_path = os.path.join(temp_dir, 'tmp.filtered.tsv')
        with open(filtered_tsv_file_path, 'w') as filtered_tsv_file:
            writer = csv.DictWriter(filtered_tsv_file, fieldnames=reader.fieldnames, delimiter='\t')
            writer.writeheader()
            for entry in reader:
                if entry['variant_type'] == 'missense':
                    writer.writerow(entry)

    lib.generate_fasta.main([
        filtered_tsv_file_path,
        str(peptide_sequence_length),
        "9",
        os.path.join(temp_dir, 'tmp.fasta'),
        os.path.join(temp_dir, 'tmp.fasta.key'),
    ])

    return temp_dir

def generate_fasta_csv(input_vcf, csv_file, peptide_sequence_length):
    temp_output_dir = generate_fasta(input_vcf, peptide_sequence_length)
    fasta_file_path = os.path.join(temp_output_dir, 'tmp.fasta')
    fasta_file_key_path = fasta_file_path + '.key'
    tsv_file_path = os.path.join(temp_output_dir, 'tmp.filtered.tsv')

    with open(fasta_file_key_path) as fasta_file_key:
        keys = yaml.load(fasta_file_key)

    tsv_entries = {}
    with open(tsv_file_path) as tsv_file:
        reader = csv.DictReader(tsv_file, delimiter='\t')
        for line in reader:
            tsv_entries[line['index']] = line

    dataframe = {}
    with open(fasta_file_path, 'r') as fasta_file:
        for line in fasta_file:
            key      = line.rstrip().replace(">","")
            sequence = fasta_file.readline().rstrip()
            ids      = keys[int(key)]
            for id in ids:
                (type, tsv_index) = id.split('.', 1)
                if tsv_index not in dataframe:
                    dataframe[tsv_index] = {}
                dataframe[tsv_index][type] = sequence
                tsv_entry = tsv_entries[tsv_index]
                if 'variant_id' not in dataframe[tsv_index]:
                    variant_id = '~'.join([tsv_entry['chromosome_name'], tsv_entry['start'], tsv_entry['stop'], tsv_entry['reference'], tsv_entry['variant']])
                    dataframe[tsv_index]['variant_id'] = variant_id

    flattened_dataframe = []
    for (tsv_index, values) in dataframe.items():
        flattened_dataframe.append({
            'ID': tsv_index,
            'variant_id': values['variant_id'],
            'WT': values['WT'],
            'MT': values['MT'],
        })

    pandas.DataFrame.from_dict(flattened_dataframe).to_csv(csv_file, index=False)

    shutil.rmtree(temp_output_dir)

if __name__ == "__main__":
    arguments = docopt(__doc__)
    generate_fasta_csv(arguments['--input'],arguments['--output'],arguments['--peptide_sequence_length'])
