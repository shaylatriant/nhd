# nhd

Part 1: Code to pull NHD flowlines based on user-input coordinates. Creates shapefiles and store them in a geopackage. 

Part 2: Snaps user-input points in a csv to the flowlines. Creates a simple function adapted from Ryan Peek (https://mapping-in-r-workshop.ryanpeek.org/03_vig_snapping_points_to_line.html) to snap points to a line. This is useful for creating point files for batch StreamStats inputs which require that all points are on the cells of a raster of NHD flowline. 