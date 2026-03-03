nhdFlowlineLooper <- function(df, distance) {
  
  source("setup.R")
  
  df$name <- gsub(" ", "_", df$name)
  
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
    
    # if(!file.exists(output_file)) {
    #   stop(paste("File doesn't exist:", output_file))
    # }
    
    # Pull the flowlines back in to R as sf object
    flowlines <- output$NHDFlowline_Network
    
    # Optional: Write as shapefile in folder connected to ArcPro. User updated file path
    # Create folder called shapefiles
    if (!dir.exists("shapefiles")) {
      dir.create("shapefiles")
      }
    
    st_write(flowlines, 
             dsn = paste0("shapefiles/", 
                          df[i,1], "_flowlines.shp"), 
             append=TRUE)
  }
}