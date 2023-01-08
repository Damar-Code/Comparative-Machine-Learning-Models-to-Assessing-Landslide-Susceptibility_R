# Comparative-Machine-Learning-Models-to-Assessing-Landslide-Susceptibility_R



## INTRODUCTION
Landslide be able to defined as geological and hydrometeorological phenomena. Mountainous area with combined with high rainfall intensity and soil with poor structure will have higher landslide probability.  Under the dual background of human activities and natural transmutations, the occurrence rate of landslides are increased rapidly (Sun et al. 2021). The last Indonesian government report from 2018 East Java is considered as one of region with high landslide occurrence and cause of death (Figure 1). 

![landslide history](https://user-images.githubusercontent.com/60123331/211179850-b4110380-361d-47db-9923-526c6e871086.png)

Figure 1. Diagram of Total Fatalities and People Lost Caused by Landslide (Irawan et al. 2021).

Providing the landslide susceptibility map is an example of increasing disaster preparedness to decrease the fatalities. This study is order to produce the high accuracy landslide susceptibility map using comparative machine learning models based on morphological feature. Instead of using single models, it is recommended to apply comparative models to increase the success rate of our predictions.  Based on similar study on landslide susceptibility assessment using machine learning, certain models are frequently use, such as, random forest (Shahzad et al. 2022), logistic regression (Sun et al. 2021; Trigila et al. 2015). Extreme Gradient Boosting (Shahzad et al. 2022), support vector machine (Merghadi et al. 2018; Shahzad et al. 2022; Wang et al. 2020), extreme gradient boosting (Sahin 2020).

Morphological feature is the one of important factor to predict the landslide susceptibility, besides of the climate, geological, and anthropogenic aspect.  Previous study using many features, such as slope, elevation, aspect, distance to drainage, profile curvature, topographic wetness index, stream power index and others. Therefor this study try to identify which morphological feature that becomes significant factors.

## STUDY AREA
Study area in this study area have mountainous terrain cover different tree mountains in the middle east of Java Island there is, Anjasmoro-Arjuno-Welirang. Developing machine learning is required the training data for the learning and validation purposes. Along 2017-2022 all of landslide data as a training data have been compiled 650 landslide data occurrences from Google Earth Imagery, field observation, and from government data. Beside that 650 non-landslide also compiled as training data, considering the geomorphological feature.
 
![Trainingdataset_bar chart](https://user-images.githubusercontent.com/60123331/211179341-66efbfde-51e3-4995-b411-b93191aadcfc.png)

Figure 2. Training and Testing Dataset


Landslide and non-landslide training dataset are shown on this pictures below.  Landslide data in this study are obtained from field observations, government data and manual interpretations from Google Earth Imagery.
  
![Research Area _resize](https://user-images.githubusercontent.com/60123331/211156933-9ec1cc56-5e8f-4e40-b262-0923b74c22ea.png)

Figure 3. Landslides and Non-landslide data Distribution

## METHOD
This study using morphological feature as a predictor, such as, Elevation, Aspect, Distant to Drainage, Topographic Position Index, Slope, Slope Length, Topographic Position Index, Stream Power Index, Profile Curvature, Plan Curvature, Relative Slope Position, Slope Length, Convergence Index, and Landform (Figure 4). All those morphological features are compute through “RSAGA” package which is only need variable there is Elevation. ALOS World 3D (AW3D30) DEM with 30x30 resolution using here as an Elevation model, considering the quality of the data that keep corrected every years by JAXA/EORC as an Aerospace Exploration Agency from Japan.

![Spatial Parameters_smallsize](https://user-images.githubusercontent.com/60123331/211157275-a1b4590a-5b9e-424e-9ab9-2f9aa8246980.png)
Figure 4 . Morphological Features

Mostly the process in Exploratory Data Analytics into Machine Learning Modeling is using “caret” package, however for some step like imputation and feature selection also applied another packages, like “missForest” and “VIF”. The whole steps on this study is shown by this figure below.

![Flow Chart-Comparative Machine Learning Methode](https://user-images.githubusercontent.com/60123331/211157308-828cd597-e331-4850-8f9a-d89e4cc92c1e.png)
Figure 5 . Image of workflow

### Data Preparation and Preprocess
Before performing feature selection there is tree steps that commonly use in Machine Learning modeling work flow, such as, 1) imputation, 2) preprocess, and 3) splitting the dataset. Imputation in this study using Random Forest algorithm by “missForest”.  Preprocess using normalization method and for splitting dataset with 70 % training dataset and 30% for testing dataset.
Normalization is data preprocessing step to produce standard features value. It is crucial steps in before conducted the machine learning models. At the There are view method for produce normalized value, this study using Min-Max Normalization method. The value of each factors standardized trough the range of minimum to maximum by 0 to 1 from its feature. 

### Feature Selection
The objective of feature selection includes: 1) simplification of models, 2) reduce the time of processing, 3) avoid the curve of dimensionality, and 4) reducing overfitting. In this study using two method for feature selection, involve Recursive Feature Elimination (RFE) and Variance Inflation Factor (VIF). Those two method is necessary to know the significant variable to predict landslide and to avoid the multicollinearity.

![Variable Importance](https://user-images.githubusercontent.com/60123331/211179316-ab9f79f2-f1f6-41ba-af72-0712b884fc89.png)

Figure 4 . Variable Importance

Selected features from RFE need to be check whether it is has multicollinearity or not. Figure 5 below show how VIF able to detect the multicollinearity of the predictors. A VIF value greater than 10 considered to have a serious multicollinearity problem.

![VIF_Multicolinearility](https://user-images.githubusercontent.com/60123331/211179329-c7f1f5a9-fcda-479b-8692-034bd6aecf47.png)

Figure 5 . Multicollinearity Detection

## RESULT AND DISCUSSIONE
 “caret” provide us the comprehensive framework to directly using multiple Machine Learning model in R. In this case Random Forest, XGBoost, Support Vector Machine, and Logit Boosting Machine are selected. The result shows that Random Forest have a highest accuracy in term of ROC.  But in this case predict the landslide need high sensitivity as well. Either way, the validation step in the end of this workflow will determine which model have the highest accuracy and sensitivity. 


![Comparative result_resize](https://user-images.githubusercontent.com/60123331/211158839-3ac9f56b-1de5-456d-a0af-bd9e9700f229.png)
Figure 7 . Landslide Susceptibility Map

## VALIDATION
In this study ROC used to measure the accuracy of landslide susceptibility  prediction model.  ROC is widely use to evaluate the evaluate the machine learning model performance. The AUC value of ROC quantitatively represent the accuracy in range 0 until 1 which is higher value mean the model is has high accuracy and reliability. Higher AUC value than 0.7 is considered the model is reliable. 
All of Machine Learning models in this study  produced AUC values above 0.7 it means all those model are reliable for landslide susceptibility assessment. However, the variation in AUC values of the model was relatively high, AUCs of 0.86 XGBoost, 0.85 in Random Forest, 0.84 in SVM, and 0.82 in Boosted Logistic Regression (Figure 8). This validation step using 30% (390 samples) from the dataset proportion. Using “pROC” library in R the AUC value directly able to extract from models that run in “caret”.

![prediction_ROC](https://user-images.githubusercontent.com/60123331/211158187-675202f0-a987-4f36-a78b-114670a6774b.png)

Figure 8. ROC curves of modeled result using validation data

Based on AUC value, XGboost found as the best model rather than the other. Therefore, it is mandatory to know which morphological features are the most significant predictors. “caret” provide the function to extract the rank of variable importance. Slope and Stream Power Index are found as a most significant morphological features to predict landslide susceptibility (Figure 9). 

![Variablr Importance - XGBoost](https://user-images.githubusercontent.com/60123331/211179363-9372ee2c-038a-42fa-9686-8f949217d0aa.png)

Figure 9. Variable Importance from XGBoost Model

## CONCLUSION
Comparative models using ROC to shows that XGBoost found as the best models with 0.86 AUC value, rather than Random Forest,  SVM, and in Boosted Logistic Regression. While for the morphological features  the importance variable to predict landslide susceptibility level respectively are, Slope, Stream Power Index, Distance to Drainage, Aspect, Elevation, Topographic Position Index, Relative Slope Position, Topographic Wetness Index, and Profile Curvature.  

## REFERENCES 
- Irawan, L. Y., Sumarmi, S. Bachri, D. Panoto, I. H. Pradana, and R. Faizal. 2021. “Landslides Susceptibility Mapping Based on Geospatial Data and Geomorphic 	Attributes (a Case Study: Pacet, Mojokerto, East Java).” in IOP Conference Series: Earth and Environmental Science. [doi:10.1088/1755-1315/884/1/012006] ((https://www.mendeley.com/catalogue/a1d54525-5cac-3843-bab9-efb0eece6d0f/?utm_source=desktop&utm_medium=1.19.4&utm_campaign=open_catalog&userDocumentId=%7B1515c14c-a2de-4994-9d01-f4502d65147c%7D))
- Merghadi, Abdelaziz, Boumezbeur Abderrahmane, and Dieu Tien Bui. 2018. “Landslide Susceptibility Assessment at Mila Basin (Algeria): A Comparative Assessment of Prediction Capability of Advanced Machine Learning Methods.” ISPRS International Journal of Geo-Information. [doi: 10.3390/ijgi7070268]((https://www.mendeley.com/catalogue/09023765-1507-3f48-bba9-b809f06c9626/?utm_source=desktop&utm_medium=1.19.4&utm_campaign=open_catalog&userDocumentId=%7Be3576f7a-5a97-4260-80d3-e3571ccb63ad%7D))
- Sahin, Emrehan Kutlug. 2020. “Assessing the Predictive Capability of Ensemble Tree Methods for Landslide Susceptibility Mapping Using XGBoost, Gradient Boosting Machine, and Random Forest.” SN Applied Sciences. [doi: 10.1007/s42452-020-3060-1] ((https://www.mendeley.com/catalogue/cc5fa842-45d1-39ea-aab5-53d64f4c54eb/?utm_source=desktop&utm_medium=1.19.4&utm_campaign=open_catalog&userDocumentId=%7Bbcc7a913-bc49-4c5b-9cde-d2cb2a9c295e%7D))
- Shahzad, Naeem, Xiaoli Ding, and Sawaid Abbas. 2022. “A Comparative Assessment of Machine Learning Models for Landslide Susceptibility Mapping in the Rugged Terrain of Northern Pakistan.” Applied Sciences (Switzerland). [doi: 10.3390/app12052280] ((https://www.mendeley.com/catalogue/526a8c03-419c-32c0-94e0-6a592cfd767d/?utm_source=desktop&utm_medium=1.19.4&utm_campaign=open_catalog&userDocumentId=%7Bec50b86c-d454-42a1-aad7-fa41a5ec3580%7D))
- Sun, Deliang, Jiahui Xu, Haijia Wen, and Danzhou Wang. 2021. “Assessment of Landslide Susceptibility Mapping Based on Bayesian Hyperparameter Optimization: A Comparison between Logistic Regression and Random Forest.” Engineering Geology 281(May 2020):105972. [doi: 10.1016/j.enggeo.2020.105972] ((https://www.mendeley.com/catalogue/1520c8d2-d6fc-3cf3-b001-a1e13aee46bf/?utm_source=desktop&utm_medium=1.19.4&utm_campaign=open_catalog&userDocumentId=%7Be9a5be73-ce72-4db0-a35d-297a31d5c5c4%7D))
- Trigila, Alessandro, Carla Iadanza, Carlo Esposito, and Gabriele Scarascia-Mugnozza. 2015. “Comparison of Logistic Regression and Random Forests Techniques for Shallow Landslide Susceptibility Assessment in Giampilieri (NE Sicily, Italy).” Geomorphology 249(August 2018):119–36. [doi: 10.1016/j.geomorph.2015.06.001] (https://www.mendeley.com/catalogue/541d96b6-b7ee-39c9-a994-a444a9279273/?utm_source=desktop&utm_medium=1.19.4&utm_campaign=open_catalog&userDocumentId=%7B3e060a69-6997-40c6-b3a0-f3c33fe42eb8%7D)
- Wang, Yue, Deliang Sun, Haijia Wen, Hong Zhang, and Fengtai Zhang. 2020. “Comparison of Random Forest Model and Frequency Ratio Model for Landslide Susceptibility Mapping (LSM) in Yunyang County (Chongqing, China).” International Journal of Environmental Research and Public Health. [doi: 10.3390/ijerph17124206] ((https://www.mendeley.com/catalogue/4ac8a7be-7f70-3937-a80a-2fc4aef67130/?utm_source=desktop&utm_medium=1.19.4&utm_campaign=open_catalog&userDocumentId=%7B700b0d11-35eb-43b4-89fc-cd9979b36b20%7D))
