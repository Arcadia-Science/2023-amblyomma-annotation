# Annotation of the _Ambylomma americanum_ genome

This repository contains documentation and analysis scripts for annotating the _Amblyomma americanum_ tick genome (available in Genbank at [accession GCA_030143305.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_030143305.1/)) at Arcadia Science.

## Planned Approach
1. Remove microbial contigs present from either contamination or symbionts
2. Use external evidence from both transcriptome assemblies and protein predictions from other tick species for genome annotation using the `nf-core/genomeannotator` pipeline
3. Validate predicted genes through BUSCO checks and comparisons to other tick species protein content

Each of these steps is documented in separate subdirectories in `microbial_decontamination`, `annotation`, and `validation`.
