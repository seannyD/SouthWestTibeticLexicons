library(tidyverse)
library(ggmap)
library(osmdata)
library(ggplot2)
library(grid)

setwd("~/OneDrive - Cardiff University/Funding/InternationalStrategicFund/project/visualisation/")

d = read.csv("../data/langaugeLocation.csv",stringsAsFactors = F,quote="")
d$source = factor(d$source,levels=c("S","DND"))
d = d[rev(order(d$source,d$lat,d$long)),]
d$label = paste0(1:nrow(d),". ",d$language)

d$label.lat = d$lat
d$label.long = d$long

#d[d$language=="Alike",]$label.lat = d[d$language=="Alike",]$label.lat-1
#d[d$language=="Old Tibetan",]$label.lat = d[d$language=="Old Tibetan",]$label.lat+0.5

d[d$source=="DND",]$label.long = d[d$source=="DND",]$label.long-0.05
d[d$source=="S",]$label.long = d[d$source=="S",]$label.long-0.8
d[d$language=="Batang",]$label.long = d[d$language=="Batang",]$label.long +3.8
d[d$language=="Batang",]$label.lat = d[d$language=="Batang",]$label.lat -2
#d[d$language=="Lhasa",]$label.lat = d[d$language=="Lhasa",]$label.lat 
d[d$language=="Old Tibetan",]$label.lat = d[d$language=="Old Tibetan",]$label.lat +2
d[d$language=="Lhasa",]$label.long = d[d$language=="Lhasa",]$label.long -1
d[d$language=="Old Tibetan",]$label.long = d[d$language=="Old Tibetan",]$label.long +3.5

#d[d$language=="Lhasa",]$label.lat = d[d$language=="Lhasa",]$label.lat -3

d$hjust = "right"
#d[d$language=="Lhasa",]$hjust = "bottom"
#d[d$language=="Batang",]$hjust = "bottom"

#d = d[d$source=="DND",]

#bb = getbb("Nepal")
#79.88,25.48,89.42,30.56
#bb["y","max"]= 34.7
#bb["y","min"]= 25.48
#bb["x","max"]= 101
#bb["x","min"]= 82

bb = matrix(c(83,27,88,29.2), ncol=2)
rownames(bb) = c("x","y")
colnames(bb) = c("min","max")

#cm <- get_map(bb,source = "osm")
cm = get_stadiamap(bb, zoom = 8, maptype = "stamen_terrain")

bb2 = matrix(c(80,23,103,39), ncol=2)
rownames(bb2) = c("x","y")
colnames(bb2) = c("min","max")

#cm2 <- get_map(bb2,source = "osm")
cm2 = get_stadiamap(bb2, zoom = 6, maptype = "stamen_terrain")


cmap = ggmap(cm) + geom_point(aes(x=long,y=lat),data=d[d$source=="DND",]) +
  geom_label(aes(x=label.long,y=label.lat,label=label,hjust="right"),data=d[d$source=="DND",])+
  theme(axis.title = element_blank())
cmap

cmap2 = ggmap(cm2) + geom_point(aes(x=long,y=lat,colour="red"),data=d[d$source=="S",]) +
  geom_point(aes(x=long,y=lat),data=d[d$source=="DND",]) +
  geom_label(aes(x=label.long,y=label.lat,label=label,hjust=hjust),
             data=d[d$source=="S",]) +
  theme(axis.title = element_blank(),legend.position = "none")

pdf("LanguagesMap.pdf",width=8,height=6)
cmap + inset(ggplotGrob(cmap2), 
                       xmin = 85.7, xmax = 88, 
                       ymin = 27.86, ymax = 29.2)
dev.off()
