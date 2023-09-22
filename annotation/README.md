# Annotation and Prediction of Gene Models
To annotate the decontaminated tick genome, we used the [`nf-core/genomeannotator` Nextflow workflow](https://nf-co.re/genomeannotator/dev/), which is still under active development but far enough in development to work for our purposes. We specifically used the latest branch of the workflow from `dev` branch of [nf-core/genomeannotator](https://github.com/marchoeppner/genomeannotator).

## External Evidence
Most annotation workflows will perform better if you have external evidence in the form of transcripts, predicted proteins from other species, a closely related reference genome to map to, etc. The `nf-core/genomeannotator` workflow requires at least one set of external reference data. Here we have supplied two sets in the form of proteins from other tick species and assembled transcripts from _Amblyomma_ datasets.

Proteins were predicted as part of a larger effort for processing Chelicerate proteomes, and selected from just tick species as documented [here](https://github.com/Arcadia-Science/2023-chelicerate-analysis).

Transcripts were compiled and assembled from various _Amblyomma americanum_ datasets including our own in-house Isoseq tick saliva dataset, which is documented [here](https://github.com/Arcadia-Science/2023-amblyomma-americanum-txome-assembly).

## Installation and Running the Workflow
You can install Docker [according to your OS](https://docs.docker.com/engine/install/), and Nextflow and the dependencies by creating a conda environment:
```
conda create -n nextflow -f environment.yml
```

The nf-core tools aren't necessary to install, but were helpful when debugging the workflow code and working with the schema. Then clone the `dev` branch of the actively maintained repo of `nf-core/genomeannotator` until the main repo is updated with:
```
git clone https://github.com/marchoeppner/genomeannotator.git
git checkout dev
```

This run of the workflow was run from commit a7726da. Launch the workflow with specific parameters for annotating the tick genome with:
```
nextflow run main.nf \\
-profile docker \\
--assembly ../assembly/Amblyomma_americanum_filtered_assembly.fasta \\
 --proteins ../external_info/2023-08-25-all-tick-species-proteins.fasta \\
 --transcripts ../external_info/orthofuser_final_clean.fa \\
 --outdir ../tick_annotation_v1 \\
 --aug_species human \\
 --spaln_taxon ixodscap
```

Currently running this on Nextflow Tower fails because of how certain files are called from the `assets` folder, and running this from the command-line works best but takes some time with RepeatMasking/RepeatModeling.
