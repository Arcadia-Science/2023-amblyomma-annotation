import argparse
from Bio import SeqIO

def calculate_contig_lengths(input_fasta, output_tsv):
    contig_lengths = {}

    with open(input_fasta, "r") as fasta_file:
        for record in SeqIO.parse(fasta_file, "fasta"):
            contig_name = record.id
            contig_length = len(record.seq)
            contig_lengths[contig_name] = contig_length

    with open(output_tsv, "w") as tsv_file:
        tsv_file.write("Contig Name\tContig Length\n")
        for contig_name, contig_length in contig_lengths.items():
            tsv_file.write(f"{contig_name}\t{contig_length}\n")

    print("Contig lengths have been written to", output_tsv)

def main():
    parser = argparse.ArgumentParser(description="Calculate contig lengths from a FASTA file and write to a TSV.")
    parser.add_argument("input_fasta", help="Input FASTA file path")
    parser.add_argument("output_tsv", help="Output TSV file path")
    args = parser.parse_args()

    calculate_contig_lengths(args.input_fasta, args.output_tsv)

if __name__ == "__main__":
    main()
