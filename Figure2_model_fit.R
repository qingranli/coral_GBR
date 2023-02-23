# plot fitted values of annual growth rates
library(tidyverse)
library(data.table)
library(ggplot2)
library(ggpubr)

rm(list=ls())
gc()

# import CPUE data ================================================
dt = fread("fitted_growth_10Species.csv")
fish.dt = dt %>% 
  filter(Species %in% c("Trevallies", "Coral trout","Saddletail Snapper"))

dt1 = fish.dt %>% select(Species, Year, y) %>% mutate(type = "observed")
dt2 = fish.dt %>% select(Species, Year, yhat1) %>% mutate(type = "modeled")
colnames(dt1) = c("Species","Year", "y", "type")
colnames(dt2) = c("Species","Year", "y", "type")
dt.plot = rbind(dt1, dt2)
dt.plot$type = factor(dt.plot$type, 
                      levels = c("observed","modeled"))
dt.plot$Species = factor(dt.plot$Species, 
                         levels = c("Trevallies", "Coral trout","Saddletail Snapper"))

p2 <- ggplot(dt.plot, aes(x=Year, y = y, color = type)) +
  geom_line(linewidth = 0.6) +
  facet_grid(.~ Species) +
  scale_color_manual(values = c("darkgrey", "firebrick")) +
  scale_x_continuous(breaks = seq(1990,2020,5)) +
  labs(x = "", y = "", color = "", title = " ") +
  theme_bw() +
  theme(panel.grid = element_blank(), 
        text = element_text(size = 10),
        legend.text = element_text(size = 10, face = "bold"),
        legend.title = element_blank(),
        legend.position = "top")
p2

tiff("Fig2_fitted_growth.tiff",res = 400, width= 8,height = 5, units = "in")
p2
dev.off()
