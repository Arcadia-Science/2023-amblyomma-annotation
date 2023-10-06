# Validation of Predicted Gene Models

The two main validations of the predicted gene models/proteins will be through BUSCO lineage calculations and comparisons of protein content to other tick species.

## BUSCO validation for each proteome set
`BUSCO` was ran against the set of proteins predicted from the output of Augustus and Evidence Modeler (which takes the set from Augustus and refines further), and the original set of proteins predicted from Augustus only using the Isoseq reads as hints, all with the command:

```
busco --cpu 8 -i $file -o $file-arachnid-busco-checks -l arachnida_odb10 -m prot
```

Augustus predictions:
```
	---------------------------------------------------
	|Results from dataset arachnida_odb10              |
	---------------------------------------------------
	|C:89.8%[S:47.4%,D:42.4%],F:3.6%,M:6.6%,n:2934     |
	|2637	Complete BUSCOs (C)                        |
	|1392	Complete and single-copy BUSCOs (S)        |
	|1245	Complete and duplicated BUSCOs (D)         |
	|105	Fragmented BUSCOs (F)                      |
	|192	Missing BUSCOs (M)                         |
	|2934	Total BUSCO groups searched                |
	---------------------------------------------------
```

Evidence modeler predictions:
```
	---------------------------------------------------
	|Results from dataset arachnida_odb10              |
	---------------------------------------------------
	|C:89.2%[S:74.9%,D:14.3%],F:3.6%,M:7.2%,n:2934     |
	|2617	Complete BUSCOs (C)                        |
	|2198	Complete and single-copy BUSCOs (S)        |
	|419	Complete and duplicated BUSCOs (D)         |
	|107	Fragmented BUSCOs (F)                      |
	|210	Missing BUSCOs (M)                         |
	|2934	Total BUSCO groups searched                |
	---------------------------------------------------
```

Original Augustus predictions:
```
	---------------------------------------------------
	|Results from dataset arachnida_odb10              |
	---------------------------------------------------
	|C:82.4%[S:50.9%,D:31.5%],F:4.0%,M:13.6%,n:2934    |
	|2415	Complete BUSCOs (C)                        |
	|1492	Complete and single-copy BUSCOs (S)        |
	|923	Complete and duplicated BUSCOs (D)         |
	|116	Fragmented BUSCOs (F)                      |
	|403	Missing BUSCOs (M)                         |
	|2934	Total BUSCO groups searched                |
	---------------------------------------------------
```

When rerunning the annotation job without giving it external proteins from other ticks, these were the BUSCO results
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

## cd-hit Clustering
I took the updated proteins from evidence modeler and clustered at 99% with cd-hit and got a final total of 31,905 proteins. Interestingly the output of cd-hit also gives protein stats:
```
================================================================
                            Output
----------------------------------------------------------------
total seq: 34557
longest and shortest : 28230 and 49
Total letters: 12510674
Sequences have been sorted
```
So according to this nothing shorter than 25 AAs?
