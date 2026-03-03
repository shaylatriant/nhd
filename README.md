# NHD_R.Rmd

Part 1: Code to pull NHD flowlines based on user-input coordinates. Creates shapefiles and store them in a geopackage. 

Part 2: Snaps user-input points in a csv to the flowlines. Creates a simple function adapted from Ryan Peek (https://mapping-in-r-workshop.ryanpeek.org/03_vig_snapping_points_to_line.html) to snap points to a line. This is useful for creating point files for batch StreamStats inputs which require that all points are on the cells of a raster of NHD flowline. 

Part 3: Split lines into segments based on snapped point input

# nhdFlowlineLooper.R

A function to loop through many sets of coordinates in a dateframe to save shapefiles of the flowlines in their contributing drainage network

The input dataframe should have three columns ordered as name, long, and lat.

# nhdFlowlineLooper_usecase.Rmd

Contains an example of using the nhdFlowlineLooper with a csv of input coordinates