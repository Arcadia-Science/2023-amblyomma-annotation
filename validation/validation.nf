#! /usr/bin/env nextflow

// Description
// workflow to compare proteins from species of interest to other species to obtain protein length differences of homologs

nextflow.enable.dsl=2

params.threads=10
params.outdir=null

log.info """\
COMPARE PROTEIN SEQUENCE IDENTITY AND STRUCTURE HOMOLOGY TO QUERY PROTEIN
=========================================
query                       : $params.query
outgroup_species_proteins   : $params.outgroup_species_proteins
outdir                      : $params.outdir
"""


workflow {
    // channels
    species_proteins = channel.fromPath("${params.outgroup_species_proteins}/*.fasta", checkIfExists: true)
    .map{fasta -> tuple(fasta.baseName, fasta)}
    query = channel.fromPath(params.query, checkIfExists: true)

    // workflow
    species_db = diamond_makedb(query)
    blast_channel = species_proteins.combine(species_db)
    blast_results = diamond_blastp(blast_channel)

}

process diamond_makedb {
    // diamond_makedb of input species
    tag "${query}_makedb"
    publishDir "${params.outdir}/diamond_makedb", mode: 'copy', pattern:"*.dmnd"

    conda 'envs/diamond.yml'

    input:
    path(query)

    output:
    path("*.dmnd"), emit: diamond_db

    script:
    """
    diamond makedb --in ${query} --db ${query}.dmnd
    """

}

process diamond_blastp {
    // DIAMOND blastp of query outgroup species against the species DB
    tag "${species}_blastp"
    publishDir "${params.outdir}/diamond_blastp", mode: 'copy', pattern:"*.tsv"

    conda 'envs/diamond.yml'

    input:
    tuple val(species), path(species_fasta), path(diamond_db)

    output:
    path("*.tsv"), emit: blast_table

    script:
    """
    diamond blastp --threads ${params.threads} --max-target-seqs 1 --db ${diamond_db} --query ${species_fasta} --out ${species}.blast.tsv --outfmt 6 qseqid sseqid pident qlen slen length mismatch gapopen qstart qend sstart send evalue bitscore
    """
}
