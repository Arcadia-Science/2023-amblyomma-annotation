library(tidyverse)
library(ggridges)
library(viridis)
library(ggpubr)

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
  filter(proportion <= 1) %>% 
  ggplot(aes(x=proportion, y=species_name)) +
  geom_density_ridges_gradient(aes(fill = ..x..), scale = 2, size = 0.3) +
  scale_fill_gradientn(
    colours = c("#0D0887FF", "#CC4678FF", "#F0F921FF")) +
  facet_wrap(~ source, scales = "free", ncol=1) +
  theme_minimal() +
  theme(legend.position = "top", axis.title.x = element_blank(), strip.text = element_blank()) # remove facet labels to align

# combine with tick metadata for total protein counts
tick_species_protein_hit_counts <- diamond_tables_clean %>% 
  group_by(species_name) %>% 
  count() %>% 
  mutate(protein_hits = n) %>% 
  select(-n)

tick_species_metadata_hits <- left_join(tick_species_protein_hit_counts, tick_species_metadata) %>% 
  mutate(proportion = protein_hits / total_protein_count)

tick_metadata_heatmap <- tick_species_metadata_hits %>% 
  ggplot(aes(x = source, y=species_name, fill=proportion)) +
  facet_wrap(~ source, scales = "free", ncol = 1) +
  geom_tile() + 
  scale_fill_viridis() + 
  theme_minimal() +
  theme(axis.title.x = element_blank(), axis.text.x = element_blank(), axis.ticks.x = element_blank(), legend.position = "top")

# diamond results with proportion of total number of proteins plotted together
tick_proteins_grid <- ggarrange(tick_metadata_heatmap, diamond_proportion_plot, ncol=2, widths=c(1,3.5), align = "h")

# save raw plot
ggsave("validation/figs/tick_protein_validation_plot.pdf", tick_proteins_grid, width=11, height=8, units=c("in"))
