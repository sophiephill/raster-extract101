#libraries
library(sp)
library(raster)
library(sf)
library(rgdal)
library(tidyverse)
library(velox)

#Load in CA counties boundary shapefile
CA_counties<-readOGR(dsn=path.expand("CA_Counties"), layer="CA_Counties_TIGER2016")
#plot to see
plot(CA_counties)

#subset to Kern
Kern<-subset(CA_counties, NAME=="Kern")
plot(Kern)

#check projection, units (units=m -important for setting grid cell size)
crs(Kern)

#create square grid
Kern_sf<-st_as_sf(Kern)   #set as sf object
Kern_square_grid<-st_make_grid(Kern_sf, cellsize = c(10000, 10000)) #create square grid

plot(Kern_square_grid) #check it out

#write grid shapefile
st_write(Kern_square_grid, "Kern_square_grid.shp", driver="ESRI Shapefile")

#create hex grid - must create a matrix of points first and then hexagons from those points
hex_points <- spsample(Kern, type = "hexagonal", cellsize = 10000, #cell size is distance between centroids
                       offset=c(0,0))  #offset makes sure the points are in the same location each time
hex_grid <- HexPoints2SpatialPolygons(hex_points, dx = 10000) #dx needs to match cellsize above

plot(hex_grid) #check it out

#write to shapefile
hex_shapefile<-st_as_sf(hex_grid)
st_write(hex_shapefile, "CA_hex_grid.shp", driver="ESRI Shapefile")

#Load temperature raster, plot
temp<-raster("PRISM_tmean_Jan18/PRISM_tmean_stable_4kmM3_201801_bil.bil")

plot(temp)

#Example extraction:hex grid

#set projections the same
Kern_hex_fix<-spTransform(hex_grid, crs(temp))

#crop raster to shapefile extent
temp_CA<-raster::crop(temp, Kern_hex_fix) #crop temp raster to Kern_fix extent [not outline of Kern_fix]

plot(temp_CA)
plot(Kern_hex_fix, add=TRUE)

#extract raster mean to gridshape
hex_temps<-raster::extract(temp_CA, Kern_hex_fix, fun=mean, df=TRUE)

#create random points as stand-in GPS case points
points<-spsample(Kern_hex_fix,n=1000,"random")

plot(points)

#count points in each grid cell
point.hex<-over(points, Kern_hex_fix) #vector of which grid cell id each point is in

hex.sum<-data.frame(point.hex) %>% group_by(point.hex)%>%summarize(N=n()) #dataframe with # points per grid cell

#fill in zero measures
#merge in zeroes
zero_grid <- data.frame(point.hex=1:length(hex_grid@polygons), vals=0) #make dataframe with hex ids and zero column

points.per.hex.full <- dplyr::full_join(hex.sum, zero_grid, 
                                            by = c("point.hex")) #full join count df and zeroes
points.per.hex.full$N[is.na(points.per.hex.full$N)] <-0 #fill in zeroes for NA values of N of points in hex grid
points.per.hex.full<-points.per.hex.full[,-points.per.hex.full$vals] #remove zeroes column

#example code: creating spatial points from .csv of X,Y coordinates
cocci_spatial <- SpatialPointsDataFrame(coords = cocci_GPS[,c("X", "Y")],
                                        data = cocci_GPS,
                                        proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs 
                                                    +ellps=WGS84 +towgs84=0,0,0")) #whatever crs you want, can copy from shapefile

#example code: velox for faster extraction
temp_velox<-velox(temp_CA) #velox(raster_name) creates a velox object
temp_ext<-temp_velox$extract(CA_hex_fix, fun=mean) #velox_object$extract(shapefile_name, fun=function)
#can also crop faster with velox_object$crop(shapefile_name)