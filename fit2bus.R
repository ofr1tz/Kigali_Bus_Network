# Install packages if necessary
if (!require(tidyverse)) {
      install.packages("tidyverse")
      library(tidyverse)
}
if (!require(rgdal)) {
      install.packages("rgdal")
      library(rgdal)
}
if (!require(sp)) {
    install.packages("sp")
    library(sp)
}

# Fit package from https://github.com/kuperov/fit
require(fit)

# Choose fit file and read data
file <- file.choose()
fit <- read.fit(file)

# Extract bus stops
stops <- as.tibble(fit$lap) %>% 
      arrange(message_index) %>%
      select(lap=message_index, 
             start.time=start_time, 
             start.lat=start_position_lat,
             start.lon=start_position_long,
             end.time=timestamp,
             end.lat=end_position_lat,
             end.lon=end_position_long) %>%
      mutate(start.time=as.POSIXct(start.time, origin="1989-12-31",tz="GMT"),
             end.time=as.POSIXct(end.time, origin="1989-12-31",tz="GMT")) %>%
      filter(!(is.na(start.lat) | is.na(start.lon)))

# Save bus stop coordinates to kml file
coordinates(stops) <- c("end.lon", "end.lat")
proj4string(stops) <- CRS("+proj=longlat +datum=WGS84")
writeOGR(stops["lap"], paste0(file, "_stops.kml"), layer="busstops", driver="KML") 

# Extract route points
route <- as.tibble(fit$record) %>%
    select(time=timestamp,
           lat=position_lat,
           lon=position_long) %>%
    mutate(time=as.POSIXct(time, origin="1989-12-31",tz="GMT")) %>%
    filter(!(is.na(lat) | is.na(lon)))
    
# Save route coordinates to kml file
coordinates(route) <- c("lon", "lat")
proj4string(route) <- CRS("+proj=longlat +datum=WGS84")
writeOGR(route["time"], paste0(file, "_route.kml"), layer="route", driver="KML")