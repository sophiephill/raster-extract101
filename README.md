# raster-extract101

## R Code

<img src="https://i.stack.imgur.com/8E1ug.png" width="400" />

Raster data are gridded equally sized pixels that each store a value. A dataset with resolution 30 m has cells of size 30 x 30 m. When you extract data, you overlay the shape on the grid and aggregate the values in the cells it covers.

## Savio

Savio provides an in depth [User Guide](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/) that can better explain/address questions. Here is my normal workflow when I use Savio:

**Transferring Files **

**Note**: To transfer to or from Savio, use a Terminal shell that is not logged in to Savio. 
Open Terminal (or equivalent on Windows).
To transfer from local computer to Savio: scp ~/Desktop/lab/code.R rain@**dtn**.brc.berkeley.edu:/global/scratch/rain/ExampleDir 
*To transfer an entire folder, use scp -r path/to/dir*
To transfer from Savio to local: scp -r rain@**dtn**.brc.berkeley.edu:/global/scratch/rain/ExampleDir/ ~/Desktop/

There are faster alternatives to scp (such as Filezilla). Using scp to transfer large raster files (say 120 MB) could take an hour. You can transfer files from Google Drive or BDrive using rclone (described [here](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/transferring-data/rclone-box-bdrive/)).

**Submitting a Job **

Open Terminal (or equivalent on Windows).
ssh rain@hpc.brc.berkeley.edu
< enter password when prompted>
cd ../../../scratch/rain  *Change directory to my scratch directory. **Note:** make sure to submit jobs from the scratch directory.*
cd ExampleDir
sbatch script.txt *Send my script to be run*
squeue -u rain *Check the status of my job*
less code.Rout *Check the output of the compiler, see I made a typo so it errored on the second line*
module load nano *Nano is a text editor that enables you to edit files through the command line*
nano code.R *Open R file to fix the typo. To save file after edits, ctrl+x to exit, then press y to save edits.*
sbatch script.txt *Send job again, hopefully this time no errors.*

