#!/usr/bin/env Rscript

library(here)

file_dir <- here()

file_path <- here(file_dir, "contigs.length.csv")

library(ggplot2)

# Import the cumulative sum table

contig_cumulative_sum_df <- read.csv(file_path, header = TRUE)

# Organize the table

contig_cumulative_sum_df$type <- factor(contig_cumulative_sum_df$type, levels=c("scaffold", "contig")) # or any other assembly types

# Create a plot for cumulative sum

plot <- ggplot(data=contig_cumulative_sum_df, aes(x=coverage, y=length/1000000, color=line)) +

  geom_vline(xintercept = 0.5, linetype="dotted", size=0.5) +

  xlim(0, 1) +

  geom_step(aes(linetype=type)) +

  labs(x = "Cumulative coverage", y = "Length (Mb)")

# Save the plot as a “coverage.pdf” file

pdf("coverage.pdf",width=4,height=3,paper='special')

print(plot)

dev.off()
