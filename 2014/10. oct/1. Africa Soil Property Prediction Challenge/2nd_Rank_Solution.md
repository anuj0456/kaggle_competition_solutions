# Winning approach by Charly B.

Team Members - [@Charly B.](https://github.com/CharlyBi)

REF: https://www.kaggle.com/competitions/afsis-soil-properties/discussion/10839

## Summary

This document describe the 2nd prize solution approach to Africa Soil Property Prediction Challenge. Soil-Prediction challenge. In this competition it is required to predict 5 target soil functional properties from diffuse reflectance infrared spectroscopy measurements. The solution consists of two steps: Data preprocessing and model prediction. For the preprocessing stage, we used 2 methods, one applied for target 1-4 (PIDN/Ca/P/pH/SOC ) and the other for target 5 (Sand). The second step was to feed the processed features to a neural network. In order to ensure that the CV error is stabilized, we had to average enough models. We ended up with 100 models to get reasonably stable error.

## Feature selection and extraction

In order to optimized the prediction results, the main effort concentrated on feature dilution and processing. We first decimated the features by 8, in a standard manner, we low pass with a 16-tap hamming window and then decimated by 8. This decimation is coarse and ignores data with different type (such as Topsoil/Subsoil etc.) We also skipped features 41-99 as they do not contains much information. We ended up with 391 features. For target 5 (Sand) this used as the input (after linear normalization) to a 2-layers neural networks with 1-4-4-1 architecture. For target 1-4 we did more processing. First, we calculate the derivative (difference sequence) resulting 390 features, then centering the results and the last stage is enhancing strong variance features. This is done by (point-wise) multilying the features by the data standard deviation vector (normalized to range 0-1).

## Modeling Techniques and Training

At the start of the competition we tried using few commonly used ML models such as SVM, KNN, neural networks etc. We quickly noted that in, all models, the cross validation creats a strong noise. Adding the fact that the training set and test set are relativly small in size (1158 data elements for the training and 727 elements for the test set) it was clear that overfitting is a big issue here. This make the LB results very problemtic.

Our model used matlab implementation of neural networks, trainlm. This uses the robust levenberg-marquet algorithm. The layer architecture was 1-4-4-1 (2 hidden layers). We trained the model with 5-fold cross validation and averaged 20 times. (overall 100 model average).

## Dependencies

The scripts requires MATLAB 2014 with Neural Network Toolbox and Statistics Toolbox.

Solution Code: [@Code](https://github.com/CharlyBi/Soil-Prediction)
