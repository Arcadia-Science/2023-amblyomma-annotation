# Microbial Decontamination and Filtering of the Tick Genome
For detecting and removing microbial contigs, I will use `diamond blastx` to perform protein translation of contigs to a protein database and aggregate taxonomy to contigs with `MEGAN`.
With this approach, I can use the cluster NCBI-nr database that Taylor Reiter created as an [Arcadia resource](https://research.arcadiascience.com/pub/resource-nr-clustering/release/1) as the DIAMOND database to search against. This will pair with the [MEGAN mapper](https://software-ab.cs.uni-tuebingen.de/download/megan6/welcome.html) used with MEGAN6 to aggregate taxonomic annotations to contigs. Then from those classifications, pull out from the assembly anything classified as bacterial or viral.

To use the tools incorporated in these steps, you can use conda and create a conda environment with:
```
conda create -n microbial_decontamination -f environment.yml
```
MEGAN will have to be manually installed, install on your machine accordingly [here](https://software-ab.cs.uni-tuebingen.de/download/megan6/welcome.html), and either point to the direct path of the program or put all the executables from MEGAN in your path.

Once the clustered NCBI-nr database was downloaded, prepare a DIAMOND database with:
```
diamond makedb --in nr_rep_seq.fasta.gz --db diamond_nr_rep_db --threads 5
```

Then perform `blastx` with:
```
diamond blastx -d databases/diamond_nr_rep_db.dmnd -q inputs/Arcadia_Amblyomma_americanum_asm001_purged_cleanedup1.fasta -o results/Amblyomma_americanum_ncbi_nr_results.tsv --long-reads
```

Aggregate taxonomy results per contig with `MEGAN blastlca`. Run `blast2lca` with:

```
megan/tools/blast2lca -i Amblyomma_americanum_ncbi_nr_results.tsv -mdb ../databases/megan-map-ncbi-nr.db -o Amblyomma-americanum-contigs-tax.tsv -f BlastTab
```

The script `scripts/calculate-contig-length.py` was used to give extra information about the classified contigs when parsing with `scripts/bacterial-contigs-viz-analyze.R` which uses the Biostrings package from Bioconductor to filter out contigs that were provided in a list. The mmgenome2 package was also used in attempt to visualize clusters of contigs overlaid with taxonomical information, which didn't work out well due to how fragmented the assembly was.
