# Validation of Predicted Gene Models

The two main validations of the predicted gene models/proteins will be through BUSCO lineage calculations and comparisons of protein content to other tick species. Below shows the BUSCO results from the resulting set of proteins and instructions for running the `DIAMOND blastp` workflow to determine alignment lengths of homologous proteins in other tick species.

## BUSCO validation for each proteome set
`BUSCO` was ran against the set of proteins predicted from the output of Augustus and Evidence Modeler (which takes the set from Augustus and refines further), and the original set of proteins predicted from Augustus only using the Isoseq reads as hints, all with the command:

```
busco --cpu 8 -i $file -o $file-arachnid-busco-checks -l arachnida_odb10 -m prot
```
When running the annotation job without giving it external proteins from other ticks, these were the BUSCO results
`Amblyomma_americanum_filtered_assembly.evm.updated.proteins.fasta` with 34,557 proteins, which is closer to the expected amount:

```
	---------------------------------------------------
	|Results from dataset arachnida_odb10              |
	---------------------------------------------------
	|C:81.5%[S:73.1%,D:8.4%],F:4.7%,M:13.8%,n:2934     |
	|2392	Complete BUSCOs (C)                        |
	|2146	Complete and single-copy BUSCOs (S)        |
	|246	Complete and duplicated BUSCOs (D)         |
	|139	Fragmented BUSCOs (F)                      |
	|403	Missing BUSCOs (M)                         |
	|2934	Total BUSCO groups searched                |
	---------------------------------------------------
```

The original Augustus proteins from this run were more duplicated with ~40,000 proteins:
```
	---------------------------------------------------
	|Results from dataset arachnida_odb10              |
	---------------------------------------------------
	|C:82.4%[S:51.5%,D:30.9%],F:4.5%,M:13.1%,n:2934    |
	|2419	Complete BUSCOs (C)                        |
	|1512	Complete and single-copy BUSCOs (S)        |
	|907	Complete and duplicated BUSCOs (D)         |
	|133	Fragmented BUSCOs (F)                      |
	|382	Missing BUSCOs (M)                         |
	|2934	Total BUSCO groups searched                |
	---------------------------------------------------
```

## DIAMOND blastp workflow
The Nextflow workflow automates creating a DIAMOND database of a query species (in this case our Amblyomma proteins) and performing DIAMOND `blastp` jobs between the query database and other tick species proteins that were obtained and processed through the [2023-chelicerate-analysis pipeline](https://github.com/Arcadia-Science/2023-chelicerate-analysis).

To use the workflow, you will need to have Docker and Nextflow installed:
1. Install Docker [according to these instructions for your operating system](https://docs.docker.com/engine/install/).
2. The easiest way to install Nextflow without worrying about dependency issues on your machine is through a conda environment, and can [install according to the instructions for your operation system](https://docs.conda.io/en/latest/miniconda.html). This is included in the `environment.yml` file. You can access the `environment.yml` file and all files neccessary for running the workflow with:

```
nextflow run validation.nf \\
	--query <AMBLYOMMA_PROTEINS> \\
	--outgroup_species_proteins <DIRECTORY_OUTGROUP_TICK_SPECIES_PROTEINS> \\
	--outdir blast_results
```

The results are then processed with `scripts/validate-plot-protein-lengths.R`
