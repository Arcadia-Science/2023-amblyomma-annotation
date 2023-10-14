library(tidyverse)

# plot busco results of all tick species
busco_results <- read.table("validation/full_tick_results/busco_parsed/parsed_busco_results.tsv", header=TRUE)

colnames(busco_results) = c("species_name", "complete", "Complete", "Complete (redundant)", "Fragmented", "Missing")

# metdata
tick_species_metadata <- read.table("validation/metadata/all_tick_species_counts.tsv", header = TRUE)

# join busco results and metadata
tick_busco_metadata <- left_join(busco_results, tick_species_metadata) %>% 
  select(-total_protein_count)

# plot 
my_colors <- c("#C6E7F4", "#5088C5", "#F7B846", "#F28360")

busco_comps_plot <- tick_busco_metadata %>% 
  select(-complete) %>% 
  mutate(species_clean = gsub("_", " ", species_name)) %>% 
  select(-species_name) %>% 
  pivot_longer(!c(species_clean, source), values_to = "percent") %>% 
  mutate(name = fct_rev(factor(name))) %>%
  ggplot(aes(x=percent, y=species_clean, fill=name)) + 
  geom_bar(stat = "identity") +
  scale_fill_manual(values = my_colors) +
  scale_x_continuous(expand = expansion(add = c(0, 0))) +
  scale_y_discrete(expand = expansion(add = c(0,0))) +
  labs(
    x = "Percentage",
    y = "Species",
    fill = "Status"
  ) +
  theme_minimal(base_size = 15) +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 1),
    strip.text = element_text(size = 12, face = "bold"), 
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()) +
  facet_wrap(~source, scales = "free_y", ncol = 1)

ggsave("validation/figs/busco-comparisons-plot.pdf", busco_comps_plot, width=11, height=8, units=c("in"))




  