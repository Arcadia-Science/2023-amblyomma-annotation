#! /usr/bin/env nextflow

// Description
// workflow to compare proteins from species of interest to other species to obtain protein length differences of homologs

nextflow.enable.dsl=2

params.threads=8
params.outdir=null

log.info """\
COMPARE PROTEIN SEQUENCE IDENTITY AND STRUCTURE HOMOLOGY TO QUERY PROTEIN
=========================================
query                       : $params.query
outgroup_species_proteins   : $params.outgroup_species_proteins
outdir                      : $params.outdir
lineage                     : $params.lineage
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
    busco_results = busco_check(species_proteins, "${params.lineage}")

    busco_dir = channel.fromPath("${params.outdir}/busco/")
    parse_busco_results(busco_dir)

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

process busco_check {
    // busco prot check against input lineage
    tag "${species}_busco"
    publishDir "${params.outdir}/busco", mode: 'copy', pattern:"*.txt"

    conda 'envs/busco.yml'

    input:
    tuple val(species), path(species_fasta)
    val(lineage)

    output:
    path("*.txt"), emit: busco_txt
    path("*.json"), emit: busco_json

    script:
    """
    busco --cpu ${params.threads} -i ${species_fasta} -o ${species} -l ${params.lineage} -m prot

    mv ${species}/short_summary.*.{json,txt} .
    """
}

process parse_busco_results {
    // busco prot check against input lineage
    tag "busco_parsing"
    publishDir "${params.outdir}/busco_parsed", mode: 'copy', pattern:"*.tsv"

    conda 'envs/busco.yml'

    input:
    path(busco_dir)

    output:
    path("*.tsv"), emit: busco_parsed

    script:
    """
    python3 ${baseDir}/bin/parse-busco.py ${busco_dir} parsed_busco_results.tsv
    """
}
