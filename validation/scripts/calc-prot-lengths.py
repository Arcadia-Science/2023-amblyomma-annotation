#! /usr/bin/env python3

import argparse
from Bio import SeqIO

# Function to calculate sequence lengths and write to TSV
def calculate_sequence_lengths(input_fasta, output_tsv):
    with open(output_tsv, "w") as tsv_file:
        tsv_file.write("Sequence Header\tSequence Length\n")
        for record in SeqIO.parse(input_fasta, "fasta"):
            header = record.id
            sequence_length = len(record.seq)
            tsv_file.write(f"{header}\t{sequence_length}\n")

def main():
    parser = argparse.ArgumentParser(description="Calculate sequence lengths from a FASTA file and write to a TSV file.")
    parser.add_argument("input_fasta", help="Input FASTA file")
    parser.add_argument("output_tsv", help="Output TSV file")
    args = parser.parse_args()

    calculate_sequence_lengths(args.input_fasta, args.output_tsv)

if __name__ == "__main__":
    main()
