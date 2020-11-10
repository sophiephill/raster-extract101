# raster-extract101

## R Code

<img src="https://i.stack.imgur.com/8E1ug.png" width="400" />

Raster data are gridded equally sized pixels that each store a value. A dataset with resolution 30 m has cells of size 30 x 30 m. When you extract data, you overlay the shape on the grid and aggregate the values in the cells it covers.

The basic workflow is: 
1. Read in shapefile using readOGR/st_read 
<ul><li> censusTracts <- readOGR("tracts") </li></ul>
2. Reading in raster using raster()
<ul><li> r <- raster("temp.tif") </li></ul>
3. Use spTransform to convert CRS of shapefile to raster's units.
<ul><li> censusTracts <- spTransform(censusTracts, crs(r)@projargs) </li></ul>
<ul><li> There are a lot of things that can go wrong in this step. The raster packages uses lowercase crs, while SpatialPolygons use CRS. Sometimes the shapefile doesn't have specify its CRS so spTransform will say *Cannot transform from NA reference system.* Then you have to check the shapefile's metadata to determine its CRS, and reread in the file using readOGR("tracts", p4s = "+init=epsg:3857"). </li></ul>
4. Use raster::extract to extract data per polygon to a dataframe. Specify the function you wish to aggregate the values. The output dataframe will not contain any of the original columns or IDs but the output will preserve the orginal order.
<ul><li> vals <- extract(r, censusTracts, base::mean, df = T) </li></ul>
<ul><li> vals$GEOID <- censusTracts$GEOID </li></ul>


## Savio

Savio provides an in depth [User Guide](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/) that can better explain/address questions. Here is my normal workflow when I use Savio:

**Transferring Files**

***Note**: To transfer to or from Savio, use a Terminal shell that is not logged in to Savio.* <br/><br/>
Open Terminal (or equivalent on Windows).<br/><br/>
Transfer from local computer to Savio: scp ~/Desktop/lab/code.R username@**dtn**.brc.berkeley.edu:/global/scratch/rain/ExampleDir
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

