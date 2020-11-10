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
<ul><li> I specify base::mean instead of just mean even though mean is the function name because I kept getting errors where somehow the name mean was being reassigned to a non-function value which took a while to debug. Now I just use base::mean for safety. </li></ul>

1. 

## Savio

Savio provides an in depth [User Guide](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/) that can better explain/address questions. Here is my normal workflow when I use Savio:

**Transferring Files**

***Note**: To transfer to or from Savio, use a Terminal shell that is not logged in to Savio.* <br/>
Open Terminal (or equivalent on Windows).<br/>
To transfer from local computer to Savio: scp ~/Desktop/lab/code.R rain@**dtn**.brc.berkeley.edu:/global/scratch/rain/ExampleDir <br/>
*To transfer an entire folder, use scp -r path/to/dir* <br/>
To transfer from Savio to local: scp -r rain@**dtn**.brc.berkeley.edu:/global/scratch/rain/ExampleDir/ ~/Desktop/ <br/>

There are faster alternatives to scp (such as Filezilla). Using scp to transfer large raster files (say 120 MB) could take an hour. You can transfer files from Google Drive or BDrive using rclone (described [here](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/transferring-data/rclone-box-bdrive/)).

**Submitting a Job**

Open Terminal (or equivalent on Windows).<br/>
ssh rain@hpc.brc.berkeley.edu <br/>
< enter password when prompted> <br/>
cd ../../../scratch/rain  *Change directory to my scratch directory. **Note:** make sure to submit jobs from the scratch directory.* <br/>
cd ExampleDir <br/>
sbatch script.txt *Send my script to be run* <br/>
squeue -u rain *Check the status of my job* <br/>
less code.Rout *Check the output of the compiler, see I made a typo so it errored on the second line* <br/>
module load nano *Nano is a text editor that enables you to edit files through the command line* <br/>
nano code.R *Open R file to fix the typo. To save file after edits, ctrl+x to exit, then press y to save edits.* <br/>
sbatch script.txt *Send job again, hopefully this time no errors.*

