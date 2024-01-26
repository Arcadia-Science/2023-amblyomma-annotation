# Annotation of the _Amblyomma americanum_ genome

This repository contains documentation and analysis scripts for annotating the _Amblyomma americanum_ tick genome (available in Genbank at [accession GCA_030143305.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_030143305.1/)) at Arcadia Science. This work is described in the pub [**Predicted genes from the Amblyomma americanum draft genome assembly**](https://research.arcadiascience.com/pub/dataset-amblyomma-americanum-predicted-genes). Cite at DOI:[10.57844/arcadia-9602-3351](https://doi.org/10.57844/arcadia-9602-3351).

## Planned Approach
1. Remove microbial contigs present from either contamination or symbionts
2. Use external evidence from both transcriptome assemblies and protein predictions from other tick species for genome annotation using the `nf-core/genomeannotator` pipeline
3. Validate predicted genes through BUSCO checks and comparisons to other tick species protein content

Each of these steps is documented in separate subdirectories in `microbial_decontamination`, `annotation`, and `validation`.

## Contributing
If you use the code or ideas in this repository for your own work, please cite DOI:10.57844/arcadia-9602-3351. If you would like to contribute to this repository, please read our [guide on credit for contributions](https://github.com/Arcadia-Science/arcadia-software-handbook/blob/main/guides-and-standards/guide-credit-for-contributions.md).
