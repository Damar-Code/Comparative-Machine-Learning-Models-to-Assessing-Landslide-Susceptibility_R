dataset <- read.csv("E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/table/train&test_dataset.csv")
dataset <- dataset[,-1]
names(dataset)[names(dataset) == "DTM"] <- "Elevation"


######################################
## Data Preparation and Preprocessing
#####################################

# impute missing value using Random Forest Algorithm
library(missForest)
impute <- missForest(dataset[,-1])$ximp
head(impute)

# Normalize Value expect the categorical variable (Landform)
names(impute)
library(dplyr)
process <- preProcess(select(impute, -"Landform"), method=c("range"))
norm_scale <- predict(process, dplyr::select(impute, -"Landform"))

# Join the target, categorical and predictor variable
dataset <- select(dataset, c("L.NL", "Landform"))
dataset <- cbind(dataset, norm_scale)


# Splitting the target and predictor variable
X = dataset[,-1]
y = dataset[,1]


# Splitting Training and Testing Dataset
library(caret)
set.seed(7)
part.index <- createDataPartition(dataset$L.NL,
                                 p = 0.7,
                                 list = FALSE)

# Store the X Y for later use for Imputation Purposes
X_train <- X[part.index,]
y_train <- y[part.index]


X_test <- X[-part.index,]
y_test <- y[-part.index]

# Compiling Train Data
X_train$L.NL <- y_train
str(X_train)

X_train

###########################################
## Create One-Hot Encoding (dummy variables)
###########################################
X_train$Landform <- as.factor(X_train$Landform)
dummies <- dummyVars(L.NL~., data=X_train)
dummies

# create the dummy variable using predict
trainData_dum <- predict(dummies, newdata = X_train)

trainData <- data.frame(trainData_dum)
str(trainData)

trainData$L.NL <- y_train
names(trainData)
##################
# Feature Selection
#################
## rfe
set.seed(100)
options(warn=-1)

subsets <- c(1:5, 10, 15, 18)

ctrl <- rfeControl(functions = rfFuncs,
                    method = "repeatedcv",
                   repeats = 5,
                   verbose = FALSE)


trainData$L.NL <- ifelse(trainData$L.NL == "Landslide", 1,0)
lmProfile <- rfe(x=trainData[,1:23], y=trainData$L.NL,
                 sizes = subsets,
                 rfeControl = ctrl)

# Variable Importance
lmProfile
varImp(lmProfile)


varimp_data <- data.frame(feature = row.names(varImp(lmProfile))[1:length(y_train)],
                          importance = varImp(lmProfile)[1:length(y_train), 1])

ggplot(data = varimp_data, 
       aes(x = reorder(feature, -importance), y = importance, fill = feature)) +
  geom_bar(stat="identity") + labs(x = "Features", y = "Variable Importance") + 
  geom_text(aes(label = round(importance, 2)), vjust=1.6, color="white", size=4) + 
  theme_bw() + theme(legend.position = "none")


## VIF to avoid Multicollinearity
library(car)
trainData.VIF <- trainData

lm.VIF <- lm(L.NL~Slope.Percent+Aspect+DtD+SPI+Elevation+
               TPI+RSP+CI+TWI+PlC,data=trainData.VIF)
lm.VIF

df.VIF <- data.frame(Factors = c(row.names(as.data.frame(vif(lm.VIF)))),
                     VIF = c(vif(lm.VIF)),
                     row.names = c(1:10))
str(df.VIF)
ggplot(data = df.VIF, 
       aes(x = Factors, y = VIF, fill = Factors)) +
  geom_bar(stat="identity") + labs(x = "Factors", y = "VIF") + 
  geom_text(aes(label = round(VIF, 2)), vjust=1.6, color="white", size=4) + 
  theme_bw() + theme(legend.position = "none")

# Landform are takeout because the significat value are less and slope as well
# because it has high Multicollinearity
######

#####
write.csv(varimp_data, "E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/table/variable_importance.csv")

################################
## Dataset with Selected Feature
################################
# Remove symbol inside Y variable
trainData$L.NL <- ifelse(trainData$L.NL == "Non-Landslide","Nonlandslide", "Landslide")
unique(trainData$L.NL)

trainData_selected <- trainData %>%
  dplyr::select(c("L.NL", "Slope.Percent","Aspect","DtD","SPI","Elevation",
                    "TPI","RSP","CI","TWI","PlC"))

write.csv(trainData_selected, "E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/table/trainData_selected.csv")

###############################
## Modeling
###############################
names(getModelInfo())

fitControl <- trainControl(method = 'cv',                  
                           number = 5,                      
                           savePredictions = TRUE,       
                           classProbs = TRUE,                  
                           summaryFunction=twoClassSummary) 


# Target Variable as Factors
trainData_selected$L.NL <- ifelse(trainData_selected$L.NL == "Landslide", "Landslide","Nonlandslide")
trainData_selected$L.NL <- as.factor(trainData_selected$L.NL)

unique(trainData_selected$L.NL)
# Random Forest
model_rf = train(L.NL~., data=trainData_selected, method='rf', metric='ROC', tuneLength=5, verbose = FALSE, trControl = fitControl)
model_rf

# SVM
model_svmRadial = train(L.NL ~ ., data=trainData_selected, method='svmRadial', metric='ROC', tuneLength=5, verbose = FALSE, trControl = fitControl)
model_svmRadial

# XGBoost
turn_grid_xgb <- expand.grid(
  eta = 0.1,
  max_depth = 5,
  min_child_weight = 1,
  subsample = 0.8,
  colsample_bytree = 0.8,
  nrounds = c(1,5)*200,
  gamma = 0)

model_XGBoost = train(L.NL ~ ., data=trainData_selected, method='xgbTree', tuneGrid = turn_grid_xgb, metric='ROC', tuneLength=5, verbose = FALSE, trControl = fitControl)
model_XGBoost

# Boosted Logistic Regression
model_LogitBoost = train(L.NL ~ ., data=trainData_selected, method='LogitBoost', metric='ROC', tuneLength=5, verbose = FALSE, trControl = fitControl)
model_LogitBoost

#### COMPARE MODEL
# Compare model performances using resample()
models_compare <- resamples(list(RF=model_rf, SVM=model_svmRadial, XGBoost=model_XGBoost, LogitBoost=model_LogitBoost))

# Summary of the models performances
summary(models_compare)

scales <- list(x=list(relation="free"), y=list(relation="free"))
bwplot(models_compare, scales=scales)

#### VALIDATION
# Random Forest is the best methode for Landslide Susceptibility Mapping in this Research Area
# Validation using X_test data

X_test
y_test

Selected.features <- c("Slope.Percent","Aspect","DtD","SPI","Elevation",
                       "TPI","RSP","CI","TWI","PlC")

X_test <- X_test %>%
  dplyr::select(Selected.features)
X_test

## ROC CURVE
library(pROC)

## Create Prediction
rf.predict <- predict(model_rf, newdata=X_test,  type = "raw")
svm.predict <- predict(model_svmRadial, newdata=X_test,  type = "raw")
XGb.predict <- predict(model_XGBoost, newdata=X_test,  type = "raw")
Log.predict <- predict(model_LogitBoost, newdata=X_test,  type = "raw")

## as numeric
rf.ROC <- ifelse(rf.predict == "Landslide",1,0)
svm.ROC <- ifelse(svm.predict == "Landslide",1,0)
XGb.ROC <- ifelse(XGb.predict == "Landslide",1,0)
Log.ROC <- ifelse(Log.predict == "Landslide",1,0)


ROC_test <- ifelse(y_test == "Landslide", 1,0)

#define object to plot and calculate AUC
# RF
rf_roc <- roc(ROC_test, rf.ROC)
rf_auc <- round(auc(ROC_test, rf.ROC),2)
rf_auc
# SVM
svm_roc <- roc(ROC_test, svm.ROC)
svm_auc <- round(auc(ROC_test, svm.ROC),2)
svm_auc
# XGBoost
XGb_roc <- roc(ROC_test, XGb.ROC)
XGb_auc <- round(auc(ROC_test, XGb.ROC),2)
XGb_auc
# Boosted Logistic Regression
Log_roc <- roc(ROC_test, Log.ROC)
Log_auc <- round(auc(ROC_test, Log.ROC),2)
Log_auc

#create ROC plot
ggroc(list(RF = rf_roc, SVM = svm_roc, XGBoost = XGb_roc, Boosted_Logistic_Regession = Log_roc)
      ,size = .8) +
  ggtitle("ROC: Accuracy of Models Prediction") +
  theme_minimal() 

#### SAVE MACHINE LEARNING MODEL
output_model <- "E:/APRIL/Portofolio/Landslide Susceptibility Assesment using Machine Learning/R/models/" 

saveRDS(model_XGBoost, paste0(output_model, "XGBoost.rds"))
saveRDS(model_rf, paste0(output_model, "RandomForest.rds"))
saveRDS(model_svmRadial, paste0(output_model, "SVM.rds"))
saveRDS(model_LogitBoost, paste0(output_model, "LogitBoost.rds"))
