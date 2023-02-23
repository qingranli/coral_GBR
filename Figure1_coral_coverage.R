# plot coral reef sites and time series used in the study
library(tidyverse)
library(data.table)
library(ggplot2)
library(ggmap)
library(ggpubr)

rm(list=ls())
gc()

# import data and basemap
dt1 = readRDS("reef_sites_data.rds")
load("basemap_stamen_zoom5.RData")

col3 = c("#c1272d", "#eecc16", "#008176")

#####################################################################
# Plot Figure 1(a)
#####################################################################
p1a <- ggmap(map_GBR) + 
  geom_point(data = dt1 %>% 
               select(REEF_ID, LONGITUDE, LATITUDE, SHELF) %>% unique(), 
             aes(x = LONGITUDE, y = LATITUDE,
                 shape = SHELF, fill = SHELF), 
             size = 1.2, alpha = 0.7) + 
  scale_fill_manual(values = col3,
                    breaks = c("I","M","O"),
                    labels = c("Inshore", "Mid-shelf", "Outer-shelf")) +
  scale_shape_manual(values = c(22,21,24),
                     breaks = c("I","M","O"),
                     labels = c("Inshore", "Mid-shelf", "Outer-shelf")) +
  labs(x="longitude", y="latitude", fill="GBR shelf", shape="GBR shelf") + 
  scale_x_continuous(limits = c(142,156)) +
  scale_y_continuous(limits = c(-25,-9)) +
  theme_bw() + 
  theme(legend.position= "bottom",
        legend.title = element_text(face = "bold"),
        legend.text = element_text(size = 12),
        text = element_text(size = 12)) 

p1a

# compute average coral cover for year 1990-2020
dt1$Shelf = dt1$SHELF
dt2 <- dt1 %>% group_by(Year, Shelf) %>% 
  summarise(COVER_live = mean(MEAN_LIVE_CORAL))

# fill in missing years for SHELF == I (linear interpolation)
dt.add = data.table(Year = c(2014,2016,2018), Shelf = "I", COVER_live = NA)
dt <- rbind(dt.add, dt2)
dt[which(Year == 2014, Shelf == "I"),3] = 
  0.5*(dt[which(Year == 2013, Shelf == "I"),3] +
         dt[which(Year == 2015, Shelf == "I"),3])
dt[which(Year == 2016, Shelf == "I"),3] = 
  0.5*(dt[which(Year == 2015, Shelf == "I"),3] +
         dt[which(Year == 2017, Shelf == "I"),3])
dt[which(Year == 2018, Shelf == "I"),3] = 
  0.5*(dt[which(Year == 2017, Shelf == "I"),3] +
         dt[which(Year == 2019, Shelf == "I"),3])
dt <- dt %>% arrange(Shelf, Year)

#####################################################################
# Plot Figure 1(b)
#####################################################################
p1b <- ggplot(dt %>% filter(Shelf %in% c("I","M","O")),
                 aes(x=Year,y=COVER_live,color = Shelf,fill=Shelf)) +
  geom_line(linewidth = 1) + 
  facet_grid(Shelf ~.) +
  scale_x_continuous(breaks = seq(1990,2020,5)) +
  scale_y_continuous(breaks = seq(5,30,5)) +
  scale_color_manual(values = col3, breaks = c("I","M","O"),
                     labels = c("Inshore", "Mid-shelf", "Outer-shelf")) +
  scale_fill_manual(values = col3,
                     breaks = c("I","M","O"),
                     labels = c("Inshore", "Mid-shelf", "Outer-shelf")) +
  labs(x="", y="live coral coverage (percent)", 
       color = "GBR Shelf", fill="GBR Shelf") +
  theme_bw() + theme(panel.grid = element_blank(),
                     legend.position = "none",
                     text = element_text(size = 12))
p1b


tiff("Fig1_GBR_coral_coverage.tiff",res = 500, width = 10, height = 7, units = "in")
ggarrange(p1a, p1b, nrow =1, widths = c(1,0.9), labels = c("a", "b"))
dev.off()
