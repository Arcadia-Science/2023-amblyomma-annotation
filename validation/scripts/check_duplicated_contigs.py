#! /usr/bin/env python3

import argparse

def read_fasta(filename):
    sequences = {}
    current_header = ""
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()
            if line.startswith('>'):
                current_header = line[1:]
                if current_header in sequences:
                    # Duplicate header found, generate a new name
                    count = 1
                    while f"{current_header}_{count}" in sequences:
                        count += 1
                    current_header = f"{current_header}_{count}"
                sequences[current_header] = ""
            else:
                sequences[current_header] += line
    return sequences

def write_fasta(output_filename, sequences):
    with open(output_filename, 'w') as output_file:
        for header, sequence in sequences.items():
            output_file.write(f">{header}\n{sequence}\n")

def main():
    parser = argparse.ArgumentParser(description="Check and rename duplicate headers in a FASTA file.")
    parser.add_argument("input_file", help="Input FASTA file")
    parser.add_argument("output_file", help="Output FASTA file")

    args = parser.parse_args()

    sequences = read_fasta(args.input_file)
    write_fasta(args.output_file, sequences)

if __name__ == "__main__":
    main()
