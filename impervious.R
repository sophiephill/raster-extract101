
library(rgdal)
library(sp)
library(rgeos)
library(sf)
library(raster)

imp <- raster("ImperviousSurfaceRaster.tif")
options(stringsAsFactors = F)
cases15 <- read.csv("CasesPerFireHex15km.csv")
over10pre15 <- cases15[(cases15$PreCaseCount>=10), "fire_id"]
fires15 <- sf::st_read("FireHexes15km/FireHexes15km.shp")
fires15 <- fires15[fires15$fire_id%in%over10pre15,]

cases25 <- read.csv("CasesPerFireHex25km.csv")
over10pre25 <- cases25[(cases25$PreCaseCount>=10), "fire_id"]
fires25 <- sf::st_read("FireHexes25km/FireHexes25km.shp")
fires25 <- fires25[fires25$fire_id%in%over10pre25,]
ct15 <- sf::st_read("HexControls15km/HexControls15km.shp")
ct25 <- sf::st_read("HexControls25km/HexControls25km.shp")

cols <- c("HEXID", "geometry")
all15 <- rbind(ct15[,cols], fires15[,cols])
all25 <- rbind(ct25[,cols], fires25[,cols])

all15 <- st_transform(all15, crs(imp))
all25 <- st_transform(all25, crs(imp))
croppedImp <- crop(imp, extent(all25))

imp_summary <- function(x, na.rm) {
  n <- length(x)
  return(c("pNA" = sum(is.na(x)) / n , "p127" = sum(x ==127) / n ,
           "PercImper" = base::mean(x[(x != 127) & !is.na(x)])))
}
vals15 <- extract(croppedImp, all15, imp_summary, df = T)
write.csv(vals15, "imperv15km.csv")
vals25 <- extract(croppedImp, all25, imp_summary, df = T)
write.csv(vals25, "imperv25km.csv")





