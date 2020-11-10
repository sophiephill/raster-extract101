
library(rgdal)
library(raster)
library(prism)
library(sf)
library(sp)
library(parallel)
options(stringsAsFactors = F)

ncores <- detectCores()
cl <- makeCluster(ncores)

clusterEvalQ(cl, {library(prism) })

meantmp <- list("../prism/tmean/")
mintmp <- list("../prism/tmin/")
maxtmp <- list("../prism/tmax/")
precip <- list("../prism/ppt/")

prism_list <- parLapply(cl, maxtmp, fun=function(path) {
  options(prism.path = path)
  dat <- ls_prism_data()
  stacks <- prism_stack(dat[1:nrow(dat),])
  return(stacks)
})
stopCluster(cl)

# COUNTY
counties <- readOGR("CA_counties/CA_Counties_TIGER2016.shp", p4s = "+init=epsg:3857")
counties <- spTransform(counties,crs(prism_list[[1]])@projargs)
ext <- raster::extent(counties)

# Mean Temp.

stack <- prism_list[[1]]
res_list <- list()

begin <- Sys.time()
for( i in 1:length(stack@layers)) {
    temp <- stack@layers[[i]]
    crop <- raster::crop(x=temp, y = ext) 
    vals <- raster::extract(crop, counties, base::mean, na.rm=T)
    vals <- lapply(vals, mean)
    df <- data.frame(vals) %>% tidyr::gather(date, tmean)
    
    df$date <- names(stack[[i]])
    df$date <- readr::parse_number(gsub(".*4kmM3_", "", df$date))
    df$date <- as.Date(paste0(df$date, "01"), "%Y%m%d")
    res_list[[i]] <- df
    gc()
}
  
final_df <- do.call(rbind, res_list)
final_df$County<- rep(counties$NAMELSAD, length(unique(final_df$date)))
final_df$Geoid <- rep(counties$GEOID, length(unique(final_df$date)))
write.csv(final_df, "CountyTmean.csv")
end <- Sys.time()
print(end- begin)

# Min Temp.

stack <- prism_list[[2]]
res_list <- list()

begin <- Sys.time()
for( i in 1:length(stack@layers)) {
  temp <- stack@layers[[i]]
  crop <- raster::crop(x=temp, y = ext) 
  vals <- raster::extract(crop, counties, base::mean, na.rm=T)
  vals <- lapply(vals, mean)
  df <- data.frame(vals) %>% tidyr::gather(date, tmin)
  
  df$date <- names(stack[[i]])
  df$date <- readr::parse_number(gsub(".*4kmM3_", "", df$date))
  df$date <- as.Date(paste0(df$date, "01"), "%Y%m%d")
  res_list[[i]] <- df
  gc()
}

final_df <- do.call(rbind, res_list)
final_df$County<- rep(counties$NAMELSAD, length(unique(final_df$date)))
final_df$Geoid <- rep(counties$GEOID, length(unique(final_df$date)))
write.csv(final_df, "CountyTmin.csv")
end <- Sys.time()
print(end- begin)








