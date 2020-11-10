# raster-extract101

## R Code

<img src="https://i.stack.imgur.com/8E1ug.png" width="400" />

Raster data are equally sized pixels arranged in a grid that each store a value. A dataset with resolution 30 m has cells of size 30 x 30 m. When you extract data, you overlay the shape on the grid and aggregate the values in the cells it covers.

The basic workflow is: 
1. Read in shapefile using readOGR/st_read 
<ul><li> censusTracts <- readOGR("tracts") </li></ul>
2. Reading in raster using raster()
<ul><li> r <- raster("temp.tif") </li></ul>
3. Use spTransform to convert CRS of shapefile to raster's units.
<ul><li> censusTracts <- spTransform(censusTracts, crs(r)@projargs) </li></ul>
<ul><li> There are a lot of things that can go wrong in this step. The raster package uses lowercase crs, while SpatialPolygons use CRS. Sometimes the shapefile doesn't have specify its CRS so spTransform will give the error <em>Cannot transform from NA reference system.</em> Then you have to check the shapefile's metadata to determine its CRS, and reread in the file using readOGR("tracts", p4s = "+init=epsg:3857"). </li></ul>
4. Use raster::extract to extract data per polygon to a dataframe. Specify the function you wish to aggregate the values. The output dataframe will not contain any of the original columns or IDs but the output will preserve the orginal order.
<ul><li> vals <- extract(r, censusTracts, base::mean, df = T) </li></ul>
<ul><li> vals$GEOID <- censusTracts$GEOID </li></ul>


## Savio

Savio provides an in depth [User Guide](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/) that can better explain/address questions. Here is my normal workflow when I use Savio:

**Transferring Files**

***Note**: To transfer to or from Savio, use a Terminal shell that is not logged in to Savio.* <br/><br/>
Open Terminal (or equivalent on Windows).<br/><br/>
Transfer from local computer to Savio: scp ~/Desktop/lab/code.R username@**dtn**.brc.berkeley.edu:/global/scratch/username/ExampleDir
<ul><li>To transfer an entire folder, use scp -r path/to/dir </li></ul> 
Transfer from Savio to local: scp -r username@dtn.brc.berkeley.edu:/global/scratch/rain/ExampleDir/ ~/Desktop/ <br/><br/>

There are faster alternatives to scp (such as Filezilla). Using scp to transfer large raster files (say 120 MB) could take an hour. You can transfer files from Google Drive or BDrive using rclone (described [here](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/transferring-data/rclone-box-bdrive/)).

**Submitting a Job**

Open Terminal (or equivalent on Windows).<br/><br/>
ssh username@hpc.brc.berkeley.edu <br/><br/>
cd ../../../scratch/username  
<ul><li>Change directory to my scratch directory. Make sure to submit jobs from the scratch directory.</li></ul>
cd ExampleDir <br/><br/>
sbatch script.txt 
<ul><li>Send my script to be run </li></ul>
squeue -u username 
  <ul><li>Check the status of my job</li></ul>
less code.Rout 
    <ul><li>Check the output of the compiler, see I made a typo so it errored on the second line</li></ul>
module load nano 
      <ul><li>Nano is a text editor that enables you to edit files through the command line</li></ul>
nano code.R 
        <ul><li>Open R file to fix the typo. To save file after edits, ctrl+x to exit, then press y to save edits.</li></ul>
sbatch script.txt 
          <ul><li>Send job again, hopefully this time no errors.</li></ul>

Example Script:
```
#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Partition:
#SBATCH --partition=savio2_htc
#
# Request one node:
#SBATCH --nodes=10
#
# Specify one task:
#SBATCH --ntasks-per-node=1
#
# Number of processors for threading:
#SBATCH --cpus-per-task=20
#
# Wall clock limit:
#SBATCH --time=01:00:00
#
## Command(s) to run (example):
module load r
R CMD BATCH code.R 
```

Notice you have to specify how long you think your job will take. If you say the job will take 72 hours (the maximum), it will be pushed to the bottom of the queue. However, if you underestimate the runtime, the job will be terminated before it has completed. You are charged for the actual time the job takes to run, not the time you forecast. 

**Cost Considerations**

The partition determines which cluster of nodes the job will be run on. Each partition uses a different type of node. For example, savio_bigmem has four nodes each with 20 cores. For reference, my Macbook Air has two cores. A list of all of Savio's partitions is [here](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/hardware-config/). <br/>
Savio charges in Service Units = number of cores x hours used. Some partitions scale the price up/down depending on the type of node used. On all partitions except savio2_htc and savio2_gpu, you will be charged for all the cores on all the nodes used even if your job does not use all the cores. For example, if you run a job for one hour on one savio_bigmem core, you will be charged for 20 cores x 1 hour (x scaling factor). In contrast, using savio2_htc, you can specify how many cores you need and only be charged for those cores. The number of cores used by the job = cpus-per-task x ntasks-per-node. So if you only need four cores, set ntasks=4, cpus-per-task=1.





