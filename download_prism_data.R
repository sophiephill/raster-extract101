
library(prism)

# Where to put the files
paths <- list(tmpmax = "/global/scratch/rain/prism/tmax",
              tmpmean = "/global/scratch/rain/prism/tmean",
              ppt = "/global/scratch/rain/prism/ppt",
              tmpmin = "/global/scratch/rain/prism/tmin")

options(prism.path=paths$tmpmax)
get_prism_monthlys("tmax", year=2000:2018, mon=1:12, keepZip=F)

options(prism.path=paths$tmpmean)
get_prism_monthlys("tmean", year=2000:2018, mon=1:12, keepZip=F)

options(prism.path=paths$ppt)
get_prism_monthlys("ppt", year=2000:2018, mon=1:12, keepZip=F)

options(prism.path=paths$tmpmin)
get_prism_monthlys("tmin", year=2000:2018, mon=1:12, keepZip=F)





