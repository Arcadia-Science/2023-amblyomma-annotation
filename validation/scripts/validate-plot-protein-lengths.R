library(tidyverse)
library(ggridges)
library(viridis)
library(ggpubr)
library(plotly)

# blast table results
blast_results <- "validation/results/blast_results/diamond_blastp/"
files <- dir(blast_results, pattern="*.tsv")
diamond_tables <- data_frame(filename = files) %>% 
  mutate(file_contents = map(filename, ~ read.table(file.path(blast_results, .)))
         ) %>% 
  unnest(cols = c(file_contents))

colnames(diamond_tables) <- c("species", "qseqid", "sseqid", "pident", "qlen", "slen", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")

# tick metadata
tick_species_metadata <- read.table("validation/metadata/all_tick_species_counts.tsv", header=TRUE)

# clean and plot diamond results
diamond_tables_clean <- diamond_tables %>% 
  mutate(species_name = gsub(".blast.tsv", "", species)) %>% 
  select(-species)

diamond_proportion_plot <- diamond_tables_clean %>% 
  left_join(tick_species_metadata) %>% 
  mutate(proportion = slen / qlen) %>%
  mutate(species_name_clean = gsub("_", " ", species_name)) %>% 
  filter(proportion <= 1) %>% # proportion of proteins that are equal to or less than the query length, not including proportions larger than the reference in this plot
  ggplot(aes(x=proportion, y=species_name_clean)) +
  geom_density_ridges_gradient(aes(fill = ..x..), scale = 2, size = 0.3) +
  scale_fill_gradientn(
    colours = c("#0D0887FF", "#CC4678FF", "#F0F921FF")) +
  facet_wrap(~ source, scales = "free", ncol=1) +
  theme_bw() +
  theme(legend.position = "bottom", axis.title.y=element_blank()) +
  labs(x="Proportion of Length of Amblyomma Protein : Length of Reference Hit")

diamond_proportion_plot

diamond_tables_clean %>%
  left_join(tick_species_metadata) %>% 
  mutate(proportion = slen / qlen) %>% 
  filter(proportion > 1) %>% 
  ggplot(aes(x=proportion, y=species_name)) +
  geom_density_ridges_gradient()

# combine with tick metadata for total protein counts
tick_species_protein_hit_counts <- diamond_tables_clean %>% 
  group_by(species_name) %>% 
  count() %>% 
  mutate(protein_hits = n) %>% 
  select(-n)

tick_species_metadata_hits <- left_join(tick_species_protein_hit_counts, tick_species_metadata) %>% 
  mutate(proportion_of_reference = protein_hits / total_protein_count) %>% 
  mutate(proportion_of_amblyomma_query = protein_hits / 34557) %>% 
  select(species_name, source, proportion_of_reference, proportion_of_amblyomma_query) %>% 
  pivot_longer(!c(species_name, source), names_to="reference_or_query", values_to="proportion")

protein_hit_labels = c("Total Protein Hits Relative to Amblyomma", "Total Protein Hits Relative to Reference")

tick_species_hits_boxplot <- tick_species_metadata_hits %>% 
  ggplot(aes(x=reference_or_query, y=proportion)) +
  geom_boxplot(fill="#BAB0A8") +
  geom_jitter(aes(color=source), size=4) +
  theme_minimal() +
  labs(x="\n Protein Hits in Amblyomma Genome or Outgroup References", y="Proportion of Protein Hits") +
  scale_x_discrete(labels = protein_hit_labels) +
  scale_color_manual(values=c("#F28360", "#5088C5"))

# save plots for length density and tick species hits boxplots
ggsave("validation/figs/tick_protein_validation_gradient.pdf", diamond_proportion_plot, width=9, height=8, units=c("in"))
ggsave("validation/figs/tick_protein_species_hits.pdf", tick_species_hits_boxplot, width=8, height=10, units=c("in"))
