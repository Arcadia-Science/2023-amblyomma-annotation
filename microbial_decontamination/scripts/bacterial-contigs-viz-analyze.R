library(mmgenome2)
library(tidyverse)
library(Biostrings)
library(vegan)
library(Rtsne)

###############################
# Visualize and get stats on bacterial contigs
###############################

# contigs
contigs <- ("inputs/Arcadia_Amblyomma_americanum_asm001_purged_cleanedup1.fasta")

# taxonomy
tax <- read.table("microbial_decontamination/results/Amblyomma_americanum_contigs_tax_modf.tsv", sep = "\t", col.names = c("contig", "kingdom", "phylum", "class", "order", "family", "genus", "species"))

bac_tax_table <- tax %>%
  filter(kingdom == "d__Bacteria" | kingdom == "d__unknown") # add viral contig

bac_contigs <- bac_tax_table %>%
  pull(contig)

# assembly prep
assembly <- readDNAStringSet(contigs, format="fasta")
filtered_contigs <- assembly[names(assembly) %in% bac_contigs]
filtered_assembly <- DNAStringSet(filtered_contigs)

# load into mmgenomes
mm <- mmload(
  assembly = filtered_assembly,
  taxonomy = bac_tax_table,
  kmer_BH_tSNE = TRUE,
  kmer_size = 4,
  perplexity = 40, thea=0.5, max_iter = 2000
)
mmstats(mm)

# view bacterial scaffolds
full_mmplot <- mmplot(mm,
                       x = 'tSNE1',
                       y = 'tSNE2',
                       color_by = 'species',
                       color_vector = scales::viridis_pal(option = "plasma")(3),
                       # color_scale_log10 = TRUE,
                       factor_shape = 'solid',
                       alpha = 0.05,
                       locator = TRUE)


###############################
# Further stats on bacterial contigs
###############################

contig_lengths <- read.table("microbial_decontamination/results/Amblyomma_americanum_contig_lengths.tsv", sep="\t", header = TRUE) %>%
  mutate(contig = Contig.Name) %>%
  mutate(length = Contig.Length) %>%
  select(contig, length)

bac_contig_info <- left_join(bac_tax_table, contig_lengths)

bac_contig_info %>%
  filter(phylum != '') %>%
  ggplot(aes(length)) +
  geom_histogram(aes(fill=class)) +
  theme_bw()

bac_contig_info %>%
  filter(phylum != '') %>%
  ggplot(aes(length)) +
  geom_histogram(aes(fill=species)) +
  theme_bw()

###############################
# Filtered and split assemblies
###############################

# filtered tick assembly with bacterial and virus contigs removed
filtered_tick_assembly <- assembly[!(names(assembly) %in% names(filtered_contigs))]
writeXStringSet(filtered_tick_assembly, "microbial_decontamination/results/Amblyomma_americanum_filtered_assembly.fasta", format="fasta")

# bacterial contigs
final_bacterial_contigs <- tax %>%
  filter(kingdom == 'd__Bacteria') %>%
  pull(contig)

final_bacterial_contigs_list <- assembly[names(assembly) %in% final_bacterial_contigs]

bacterial_contigs_fasta <- assembly[names(assembly) %in% names(final_bacterial_contigs_list)]
writeXStringSet(bacterial_contigs_fasta, "microbial_decontamination/results/bacterial_contigs.fasta", format="fasta")

# viral Quaranjavirus contig
virus_fasta <- assembly[(names(assembly) == 'contig_136223_1')]
writeXStringSet(virus_fasta, "microbial_decontamination/results/Quaranjavirus.fasta", format="fasta")
