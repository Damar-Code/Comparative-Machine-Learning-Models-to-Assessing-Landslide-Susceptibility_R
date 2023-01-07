library(RSAGA)
library(raster)
library(sf)


#############################
# Compute Spatial Parameter
#############################

## Setting RSAGA Environtment
env <- rsaga.env("C:/Program Files/saga-6.3.0_x64/")
rsaga.get.version(env)

#rsaga.get.usage("ta_hydrology", 21, show = TRUE, env=env)

#for loop choosing the folder
create_terrain <- function(dtm, shp_output){
  
  aoi <- read.table(text = gsub("[_.]", " ", dtm))$V2 #Extract the name
  # Slope
  rsaga.geoprocessor("ta_morphometry", 0, list( ELEVATION = dtm,
                                                SLOPE = paste0("Slope_", aoi,".sgrd"),
                                                ASPECT = paste0("Aspect_", aoi,".sgrd"),
                                                UNIT_SLOPE = 1,
                                                UNIT_ASPECT = 1,
                                                METHOD = 6), 
                     env = env)
  ## Topographic Position Index
  rsaga.geoprocessor("ta_morphometry", 18, list( DEM = dtm,
                                                 TPI = paste0("TPI_", aoi,".sgrd"),
                                                 DW_WEIGHTING = 0),
                     env=env)
  
  
  ## SAGA Wetness Index
  rsaga.geoprocessor("ta_hydrology", 15, list( DEM = dtm,
                                               TWI = paste0("TWI_", aoi,".sgrd")),
                     env=env)
  
  ## Stream Power Index
  rsaga.geoprocessor("ta_hydrology", 21, list( SLOPE = paste0("Slope-Radians_", aoi,".sdat"),
                                               AREA = dtm,
                                               SPI = paste0("SPI_", aoi,".sgrd")),
                     env=env)
  
  ## Slope Length
  rsaga.geoprocessor("ta_hydrology", 7, list( DEM = dtm,
                                              LENGTH = paste0("Slope-Length_", aoi,".sgrd")),
                     env=env)
  
  ## compound Analysis: Channels 
  rsaga.geoprocessor("ta_compound", 0, list( ELEVATION = dtm,
                                             SLOPE = paste0("Slope-Percent_", aoi,".sgrd"),
                                             CHANNELS = paste0(shp_output, "Channel-Network_", aoi,".shp"),
                                             CHNL_DIST = paste0("Channel-Distance_", aoi,".sgrd"),
                                             BASINS = paste0(shp_output,"Basins_",aoi,".shp"),
                                             HCURV = paste0("PlC_", aoi,".sgrd"),
                                             VCURV = paste0("PrC_", aoi,".sgrd"),
                                             CONVERGENCE = paste0("CI_", aoi,".sgrd"),
                                             RSP = paste0("RSP_", aoi,".sgrd")),
                     env=env)

  ## Create DtD
  ### Step 1 - Read Channels File
  DtD <- st_read(paste0(shp_output,"Channel-Network_", aoi,".shp"))
  DtD <- st_zm(DtD)
  DtD <- DtD[DtD$ORDER >= 2,]
  
  st_write(DtD, paste0(shp_output,"ORDER.shp"), append=FALSE, overwirite=TRUE)
  
  base_extent <- raster(dtm)
  
  ### Step 2 - Rasterize the Channels
  rsaga.geoprocessor("grid_gridding",0,list( INPUT = paste0(shp_output,"ORDER.shp"),
                                             FIELD = "ORDER",
                                             OUTPUT = 2,
                                             TARGET_USER_FITS = 1,
                                             TARGET_USER_SIZE = res(base_extent)[1], # resolution
                                             TARGET_USER_FITS = 1,
                                             TARGET_USER_XMIN = base_extent@extent@xmin,
                                             TARGET_USER_XMAX = base_extent@extent@xmax,
                                             TARGET_USER_YMIN = base_extent@extent@ymin,
                                             TARGET_USER_YMAX = base_extent@extent@ymax,
                                             GRID = "ORDER.sgrd"),
                     env=env)
  
  ### Step 3 - Proximity Grid
  rsaga.geoprocessor("grid_tools",26,list( FEATURES = "ORDER.sgrd",
                                           DISTANCE = "Distance.sgrd"),
                     env=env)
  
  ### Step 4 - Mask with Raster
  rsaga.geoprocessor("grid_tools",24,list( GRID = "Distance.sgrd",
                                           MASK = dtm,
                                           MASKED = paste0("DtD_", aoi,".sgrd")),
                     env=env)
  
  # Landform
  rsaga.geoprocessor("ta_morphometry", 19, list( DEM = dtm,
                                                 LANDFORMS = paste0("Landform_", aoi,".sgrd"),
                                                 RADIUS_A_MIN = 0,
                                                 RADIUS_A_MAX = 100,
                                                 RADIUS_B_MIN = 0,
                                                 RADIUS_B_MAX = 1000,
                                                 DW_WEIGHTING = "3",
                                                 DW_BANDWIDTH = 0),
                     env=env)
}

setwd("E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/raster/terrain/")
create_terrain(dtm = "DTM_Arjuno-Welirang-Anjasmara.tif",
               shp_output = "E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/shp/")

## CREATE RASTER STACK
list.Ras <- grep(list.files(pattern=".sdat$|.tif$"), pattern='ORDER|Distance|Channel', invert=TRUE, value=TRUE)
list.Ras
ras_stack <- stack(list.Ras)



####################################################
## CREATE TRAINING AND TESTING DATASET
####################################################
# Read Landslide Inventory Data
inv <- st_read("E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/shp/Landslide_Inv/Landslide and Non-landslide Inv.shp") 

library(ggplot2)
library(dplyr)

## Quick Visualization
inv$label <- ifelse(inv$L.NL == "1", "Landslide", "Non-Landslide")
ggplot(data=inv, aes(x=label, fill=label)) +
  geom_bar(stat="count", width=0.7)+
  xlab("Training Dataset") +
  geom_text(stat = 'count', aes(label=..count..), vjust=1.6, color="white",
            position = position_dodge(0.9), size=5)+
  theme_classic() +
  theme( plot.title = element_text(size = 18, family = "Tahoma", face = "bold"),
         legend.position="none",
         text=element_text(family="Tahoma"),
         axis.text.x=element_text(colour="black", size = 12),
         axis.text.y=element_text(colour="black", size = 12),
         axis.title = element_text(size = 15))

# Raster Extaction
dataset <- as.data.frame(cbind(data.frame(inv[2]), extract(ras_stack, inv)))
dataset <- subset(dataset, select = -c(geometry))

colnames(dataset) <- gsub("_Arjuno.Welirang.Anjasmara","",colnames(dataset))
dataset$Landform <- as.factor(dataset$Landform)
dataset$L.NL <- ifelse(dataset$L.NL == "1", "Landslide", "Non-Landslide")
dataset$L.NL <- as.factor(dataset$L.NL)
unique(dataset$L.NL)

write.csv(dataset, "E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/table/train&test_dataset.csv")
