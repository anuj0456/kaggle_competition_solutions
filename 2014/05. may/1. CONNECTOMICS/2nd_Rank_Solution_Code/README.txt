Follow the following steps to create the solution:

Requirements:
------------
*OS: Windows 7
*R and matlab installed
*R packages: R.matlab, gbm, randomForest
*matlab open source packages: oopsi, ND (included in the zip)

Steps:
-----
0)uncompress ildefons.zip. This will create a folder "ildefons". 
*You must update all R files included in this zip according to this path. 
E.g.:
###path
mypath<-"C:/Users/ildefons/vrije/ildefons"
*The file "makeFeatures.R" has a second place to update:
evaluate(matlab, "addpath(genpath('C:/Users/ildefons/vrije/ildefons'))") 

1)Copy sampleSubmission, fluorescense and connection files to the same folder that contain the scripts and this file(README.txt) "YOURPATH/ildefons"
*files to copy: "sampleSubmission", "fluorescence_normal-1", "fluorescence_normal-2", "fluorescence_valid", "fluorescence_test", "network_normal-1", "network_normal-2"

2)Execute "makeMat.R". This R script will generate .mat files with fluorescense data from normal-1, normal-2, valid and test files 

3)Execute "makeoo.m". This matlab script will read each .mat file generated in step 2 and return for each case a csv file with 1000 spike trains.
*Pre-consitions: make sure that the folder and sub-folders "oopsi-master" is in your matlab path
*input: .mat files computed in step 2)
*output: 4 csv files: "diff2n1a40b15csv.csv","diff2n2a40b15csv.csv","diff2valida40b15csv.csv","diff2testa40b15csv.csv"
*Note 1:this script runs in about 4 hours

4)Execute "makeFeatures.R". This R script builds unnormalized features. Each feature correspond to a correlation between 2 spike trains as computed in step 3. Before applying the correlation operator we filter out spikes below a threshold1 and we filter out rows that has more valid spikes than threshold2. the Correlation matrix for each combination of (threshold1, threshold2) is then transformed using the ND algorithm. We store both the original correlation and ND. We do that for many combinations of (threshold1, threshold2). 
*input: spike train files computed in step 3).
*output: 4 RData files: "featuresn1plus22.RData","featuresn2plus22.RData","featuresvalidplus22.RData","featurestestplus22.RData"
*Note 1: after running line 9 (matlab$startServer() ), please wait 1 or 2 minutes untill the matlab server is running.
*Note 2: this step requires a fast computer with >32Gbyte RAM
*Note 3: this is the most time consumming script (~ 24 to 48 h)

5)Execute "normalizeFeatures.R". This R scripts Z-normalize all features. 
*input: feature files computed in step 4) 
*output: 4 RData files: "n1norm.RData","n2norm.RData","validnorm.RData","testnorm.RData"

6)Execute "fitModels.R". This R script fits 4 supervised models: random forest with normal-1 data, gbm with normal-1 data, random forest with normal-2 data and gbm with normal-2 data.
*input: "n1norm.RData","n2norm.RData"
*output: "mymodels.RData"

7)Execute "createSolution.R". This R script builds the solution file.
*input: "mymodels.RData","validnorm.RData","testnorm.RData"
*output: "submissionref.csv"




