# Plot maximum sustainable yield (MSY)
library(tidyverse)
library(data.table)
library(ggplot2)
library(ggpubr)

rm(list=ls())
gc()

# import model estimates  
est = fread("alt_est_10Species.csv")

# compute MSY (Tonnes) associated with coral coverage (percent)
fishname = "Trevallies" 
fish.msy1 = data.table(Species = fishname, a = seq(1,40, 2))
fish.msy1$r = est$r[which(est$Name == fishname)]
fish.msy1$beta = est$beta[which(est$Name == fishname)]
fish.msy1$gamma = est$gamma[which(est$Name == fishname)]
fish.msy1 = fish.msy1 %>% mutate(MSY = 10000*r*beta/exp(1)*(a^gamma))

fishname = "Coral trout" 
fish.msy2 = data.table(Species = fishname, a = seq(1,40, 2))
fish.msy2$r = est$r[which(est$Name == fishname)]
fish.msy2$beta = est$beta[which(est$Name == fishname)]
fish.msy2$gamma = est$gamma[which(est$Name == fishname)]
fish.msy2 = fish.msy2 %>% mutate(MSY = 10000*r*beta/exp(1)*(a^gamma))

fishname = "Saddletail Snapper" 
fish.msy3 = data.table(Species = fishname, a = seq(1,40, 2))
fish.msy3$r = est$r[which(est$Name == fishname)]
fish.msy3$beta = est$beta[which(est$Name == fishname)]
fish.msy3$gamma = est$gamma[which(est$Name == fishname)]
fish.msy3 = fish.msy3 %>% mutate(MSY = 10000*r*beta/exp(1)*(a^gamma))

p1 <- ggplot(fish.msy1, aes(x=a,y=MSY)) + 
  geom_line(linewidth = 1.4, color = "coral") +
  labs(x = "live coral coverage (percent)", 
       y = "tonnes", title = fish.msy1$Species[1]) +
  theme_bw() +
  theme(panel.grid = element_blank())
p1
  
p2 <- ggplot(fish.msy2, aes(x=a,y=MSY)) + 
  geom_line(linewidth = 1.4, color = "coral") +
  labs(x = "live coral coverage (percent)", 
       y = "tonnes", title = fish.msy2$Species[1]) +
  theme_bw() +
  theme(panel.grid = element_blank())
p2

p3 <- ggplot(fish.msy3, aes(x=a,y=MSY)) + 
  geom_line(linewidth = 1.4, color = "coral") +
  labs(x = "live coral coverage (percent)", 
       y = "tonnes", title = fish.msy3$Species[1]) +
  theme_bw() +
  theme(panel.grid = element_blank())
p3


tiff("Fig3_MSY.tiff", res = 400, width = 8, height = 4, units = "in")
ggarrange(p1, p2, p3, nrow =1, labels = c("a.", "b.", "c."))
dev.off()