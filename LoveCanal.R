## Love Canal

library(leaflet)
library(ggplot2)
library(ggmap)
library(dplyr)
library(htmlwidgets)
library(rgdal)
library(ggiraph)


lc=geocode("Love Canal, NY")
ub=geocode("University at Buffalo North Campus, Amherst, NY")

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=lc$lon, lat=lc$lat, popup="The Love Canal") %>%
  addMarkers(lng=ub$lon, lat=ub$lat, popup="University at Buffalo")%>%
  setView(lng=ub$lon, lat=ub$lat+.1,10)
m  # Print the map

saveWidget(m, file="LoveCanal.html")


#### Other layers
library(rgdal)
library(sf)
library(raster)

#ogrInfo("/Users/adamw/GoogleDrive/Work/courses/2017_Spring/GEO105/LoveCanal.kml",layer="test")

ae=stack("img/Aerial.jpg")
  extent(ae)=c(-78.95718485972279, -78.94225869680191,43.0743827000953,43.08738630751778)
  #rotate 1.375133404821186
projection(ae)=projection("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
ae2=projectRasterForLeaflet(ae)
tf=file.path(tempdir(),".tif")
ae3=aggregate(ae2,2,filename=tf,overwrite=T)  

tf2=RGB2PCT(GDAL.open(tf), band=1:3,set.ctab=F)
tf3=t(getRasterData(tf2$dataset))
aergb=raster(dropLayer(ae3,2:3))
values(aergb)=tf3
aergb@legend@colortable=tf2$pct


plot(aergb)

## Measure map
km=st_as_sf(readOGR("LoveCanal/data/doc.kml"))


m2 <- leaflet(options = leafletOptions(minZoom = 12, maxZoom = 16)) %>%
  addTiles('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution='Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community') %>%
  addCircleMarkers(color="red",radius=10,lng=-78.949992, lat=43.080385, popup="The Love Canal",group="Measure") %>%
  addCircleMarkers(color="red",radius=10,lng=-78.948022, lat=43.080385, popup="Residential Area",group="Measure") %>%
  addRasterImage(x=aergb,colors=aergb@legend@colortable,group = "1978",
                 maxBytes = 28574103,project=F,attribution = "'Aerial photographic map illustrating the swale theory of chemical waste migration'
           Courtesy University at Buffalo <a href=http://digital.lib.buffalo.edu/cdm/singleitem/collection/LIB-003/id/267/rec/1>Source</a>")%>%
  addMarkers(popup = ~Description, data=km,group="Photos")%>%
  setView(lng=lc$lon, lat=lc$lat,15)%>% 
  addMeasure(
        position = "topright"
       , primaryLengthUnit = "meters"
       , primaryAreaUnit = "sqmeters"
       , activeColor = "#3D535D"
       , completedColor = "#7D4479"
       , localization = 'EN'
     )%>%
  addLayersControl(
       overlayGroups = c("1978", "Photos","Measure"),
       options = layersControlOptions(collapsed = FALSE)
     )
m2  # Print the map

saveWidget(m2, selfcontained = T, file="LoveCanalMeasure.html")

