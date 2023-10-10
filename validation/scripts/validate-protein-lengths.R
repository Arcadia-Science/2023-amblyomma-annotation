library(tidyverse)
library(ggridges)

######################################
# Validation checks of Amblyomma predicted proteins
# Check length distribution of all proteins
# Check alignment/length of proteins against Ixodes proteins
######################################

# length of each protein
amblyomma_protein_lengths <- read_tsv("validation/results/2023-10-02-amblyomma-protein-lengths.tsv")


amblyomma_protein_lengths %>% 
  ggplot(aes(x=`Sequence Length`)) +
  geom_histogram(fill="white", color="grey25", bins=50) + 
  xlab("Protein Length") +
  ylab("Frequency") +
  theme_minimal()


# blast results against Ixodes proteins
amblyomma_v_ixodes_blast <- read_tsv("validation/results/diamond_blast_ixodes/Amblyomma_vs_Ixodes_blast_table.tsv", col_names = c("species", "qseqid", "sseqid", "pident", "qlen", "slen", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore"))

fragments <- sum(amblyomma_v_ixodes_blast$qlen / amblyomma_v_ixodes_blast$slen < 0.8)

amblyomma_v_ixodes_blast <- amblyomma_v_ixodes_blast %>% 
  mutate(proportion = qlen / slen)

amblyomma_v_ixodes_blast %>% 
  filter(proportion <= 1) %>% 
  ggplot(aes(x=proportion)) +
  geom_histogram(fill="white", color="grey25", bins=30) + 
  xlab("Query Length / Hit Length") +
  ylab("Frequency") +
  theme_minimal()

amblyomma_v_ixodes_blast %>% 
  filter(proportion <= 1) %>% 
  ggplot(aes(x=proportion)) + 
  geom_density_ridges()

amblyomma_v_ixodes_blast %>% 
  filter(proportion > 1) %>% 
  ggplot(aes(x=proportion)) +
  geom_histogram()
  

  