setwd("E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/raster/terrain/")

library(raster)
## CREATE RASTER STACK SELECTED PREDICTOR FEATURES
Selected.features
list.Ras <- grep(list.files(pattern=".sdat$|.tif$|Slope|Aspect|DtD|DTM|SPI|Elevation|TPI|RSP|CI|TWI|PlC"), 
                 pattern='ORDER|Distance|Landform|PrC|Channel|Slope-Length|Slope-Percent|Slope_|.sgrd|.aux.xml|.mgrd|prj', invert=TRUE, value=TRUE)

list.Ras <-list.Ras[-4] # Takeout DTM for Main Extent Extraction
list.Ras
ras_stack <- stack(list.Ras)

############################
## CREATE BACKGROUND DATA
###########################

## create main extent (Raster Pixel to Polygon using QGIS)
extent <- st_read("E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/shp/background_data/extent.shp")

# Extract Classify Value
library(exactextractr)

background_data <- cbind(extent, exact_extract(ras_stack, extent, c('majority')))
colnames(background_data) <- gsub("_Arjuno.Welirang.Anjasmara","",colnames(background_data))
head(background_data)

st_write(background_data, "E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/shp/background_data/background_data.shp", append = FALSE)

library(caret)
names(background_data)

df.bg <- as.data.frame(background_data)[1:9]
geometry <- as.data.frame(background_data)[10]

## Check NA value of Predictor
Selected.features
check.na <- data.frame(Factors = c(Selected.features),
                       na.value = c(sum(is.na(df.bg$Slope.Percent)),sum(is.na(df.bg$Aspect)),
                                    sum(is.na(df.bg$DtD)),sum(is.na(df.bg$SPI)),
                                    sum(is.na(df.bg$Elevation)),sum(is.na(df.bg$TPI)),
                                    sum(is.na(df.bg$RSP)),sum(is.na(df.bg$CI)),
                                    sum(is.na(df.bg$TWI)),sum(is.na(df.bg$PlC))))
check.na
library(dplyr)
df.bg$Aspect <- ifelse(is.na(df.bg$Aspect), 0, df.bg$Aspect) # as a flat area

# Normalize
library(caret)
process <- preProcess(df.bg, method=c("range"))
bg.norm <- predict(process, df.bg)

XGBoost.predict <- predict(model_XGBoost, newdata= bg.norm,  type = "prob")[1]
head(XGBoost.predict)
rf.predict <- predict(model_rf, newdata= bg.norm,  type = "prob")[1]
head(rf.predict)
svmRadial.predict <- predict(model_svmRadial, newdata= bg.norm,  type = "prob")[1]
head(svmRadial.predict)
LogitBoost.predict <- predict(model_LogitBoost, newdata= bg.norm,  type = "prob")[1]
head(LogitBoost.predict)

result <- data.frame(m1 = c(round(XGBoost.predict,3)),
                     m2 = c(round(rf.predict,3)),
                     m3 = c(round(svmRadial.predict,3)),
                     m4 = c(round(LogitBoost.predict,3))) %>%
  rename(XGBoost = 1,
         RF = 2,
         SVM = 3,
         LogBoost = 4)

result
final <- cbind(result, geometry[1:389605,])
sf.final <- st_as_sf(final)
sf.final



write.csv(final, "E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/table/model_result.csv")
st_write(sf.final, "E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/shp/landslide_susceptibility/landslide_susceptibility.shp", append = FALSE)
