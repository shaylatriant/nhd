nhdFlowlineSnapper <- function(df, distance, max_dist = 1000) {
  
  source("setup.R")
  
  df$name <- gsub(" ", "_", df$name)
  
  results <- list()
  
  for(i in 1:nrow(df)) {
    # coordinates at outlet of lowest downstream extent of study site. Input as (x, y), so (longitude, latitude)
    river <- st_sfc(st_point(c(as.numeric(df[i,2]), as.numeric(df[i,3]))), 
                    crs = 4326)
    #check class is "sfc" and "sfc_POINT"
    class(river)
    # Find the nearest stream segment ID to our point
    river_comid <- discover_nhdplus_id(river)
    # Make a list defining the sourcetype and ID
    river_list <- list(featureSource = "comid", 
                       featureID = river_comid)
    # get upstream flowlines
    river_us_flowlines <- navigate_nldi(nldi_feature = river_list,
                                        mode = "UT", # "UT" for upstream with tributaries
                                        data_source = "",
                                        distance_km = distance) # Distance upstream from point it will stop navigating, a generous 500 for Swan
    # Compile a list with all the comids we've identified:
    all_comids_river <- c(river_us_flowlines[["UT_flowlines"]][["nhdplus_comid"]]) %>%
      as.numeric()
    
    # Get the nhd data and store temporarily as object "output"
    
    output <- subset_nhdplus(comids=all_comids_river,
                             simplified = TRUE,
                             overwrite = TRUE,
                             nhdplus_data = "download",
                             return_data = TRUE)
    
    # Pull the flowlines back as sf object
    flowlines <- output$NHDFlowline_Network
    
    # Best to have everything in the same projection
    if (st_crs(river) != st_crs(flowlines)) {
      river <- st_transform(river, st_crs(flowlines))
    }
    
    # first project
    x <- st_transform(river, crs = 26910)
    y <- st_transform(flowlines, crs=26910)    
    
    # snap points to the nearest line. This is adapted from a custom function from Tim Salabim on Stack Overflow
    
    # this evaluates the length of the data
    if (inherits(x, "sf")) n = nrow(x)
    if (inherits(x, "sfc")) n = length(x)
    
    # this part: 
    # 1. loops through every piece of data (every point)
    # 2. snaps a point to the nearest line geometries
    # 3. calculates the distance from point to line geometries
    # 4. retains only the shortest distances and generates a point at that intersection
    
    nrst = st_nearest_points(st_geometry(x), y)
    nrst_len = st_length(nrst)
    nrst_mn = which.min(nrst_len)
    if (as.vector(nrst_len[nrst_mn]) > max_dist) {snapped_point <- x}
    
    else{
      snapped_point <- st_cast(nrst[nrst_mn], "POINT")[2]
    }
    snapped_sf <- st_as_sf(
      data.frame(name = df$name[i]),
      geometry = st_sfc(snapped_point),
      crs = st_crs(x)
    )
    
    results[[i]] <- snapped_sf
    
  }
  
  result_sf <- do.call(rbind,results)
  
  if (!dir.exists("shapefiles")) {
    dir.create("shapefiles")
  }
  # Write output as shapefile
  st_write(result_sf, 
           dsn = "shapefiles/snapped_points.shp", 
           append=TRUE)
  
} 
