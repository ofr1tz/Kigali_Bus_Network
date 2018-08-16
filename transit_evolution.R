library(tidyverse)
library(ggmap)
library(osmdata)
library(sf)
library(magick)

bbox <- c(29.95,
          -2.10,
          30.25,
          -1.80)

map <- get_map(location=bbox,
               source="stamen",
               color="bw", 
               scale="auto")
g <- ggmap(map, darken=c(.4, "white"))

osmTimeSeries <- function(date) {
    q <- opq(bbox) %>%
        add_osm_feature("network", "Kigali")
    
    q$prefix[1] <- paste0("[out:xml][timeout:25][date:\"", as.character(date), "T00:00:00Z\"];\n(\n")
    
    routes <- osmdata_sf(q)$osm_multilines %>%
        filter(role!="platform")
    
    g + geom_sf(data=routes, size=1, color="red", inherit.aes=FALSE) +
        labs(title=paste0("Kigali Bus Network on OpenStreetMap (", as.character(date), ")")) +
        geom_text(x=bbox[3]-.002, y=bbox[2]+.002, 
                  hjust=1, vjust=0, 
                  label="Map tiles by Stamen Design, under CC BY 3.0. Data by OpenStreetMap, under ODbL.",
                  size=3.5, colour="grey60") +
        theme(plot.title = element_text(face="bold", hjust=0.5, size=10, colour="grey25"),
              axis.title.y=element_blank(),
              axis.title.x=element_blank(),
              axis.text.y=element_text(color="grey60", size=9),
              axis.text.x=element_text(color="grey60", size=9),
              axis.ticks=element_line(color="grey60")) 
        
    ggsave(filename=paste0("./output/OSM_Kigali_Transit_", date,".png"),
           device="png",
           width = 10,
           height=10,
           dpi = 150)
}

seq(as.Date("2018/02/23"), Sys.Date(), "week") %>% 
    map_df(osmTimeSeries)

list.files(path = "./output/", pattern = "OSM_Kigali_Transit_*.png", full.names = T) %>% 
    map(image_read) %>% 
    image_join() %>% 
    image_animate(fps=3) %>% 
    image_write("./output/OSM_Kigali_Transit_evolution.gif")
