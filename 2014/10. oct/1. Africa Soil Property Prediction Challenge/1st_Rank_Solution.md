# Winning approach by Yasser Tabandeh

Team Members - [@Yasser Tabandeh](https://github.com/Yasssser)

REF: https://www.kaggle.com/competitions/afsis-soil-properties/discussion/10825

## Summary

This document describes winning solution for African Soil Property Challenge Problem (AFSIS) hosted by
Kaggle. Several models such as Multilayer Perceptron, Support Vector Machines, Gaussian Process, and
Multivariate Regression were combined to produce a stable framework to overcome overfitting. Each model
used a different set of transformed features with different setup parameters.

## Preprocessing

Different types of preprocessing were done to transform features into more relevant forms. Some of them
reduce dimensionality of data and some others reduce noises.

1. Savitzky-Golay filter: this filter is used for smoothing the data
2. Continuum Removal: for normalization and handling outliers
3. Discrete wavelet transforms: for discrete sampling and data reduction
4. First Derivatives: in some cases increases prediction quality
5. Unsupervised Feature Selection: standard deviation was used to select top features for some
   algorithms.
6. Log transform: "P" target was transformed into log(P+1)

## Modeling algorithms

1. Neural Networks: two types of neural network algorithms were used for training:
   - Simple layer neural network (nnet package in R)
   - Monotonic Multilayer Perceptron (monmlp package in R)
2. Support Vector Machines(SVM): svm function in e1071 package in R was used for SVM training
3. Multivariate Regression: mvr function in pls package in R was used for multivariate regression
4. Gaussian Process: gausspr function in kernlab package in R was used for Gaussian Process

For each target different algorithms were used for training. Table 1 shows detailed information for
preprocessing and modeling.

Final predictions for each target were calculated using weighted averages of models as detailed in Table 1.
Number of training rows was small in compare to number of features, so overfitting could occur.
For handling overfitting risk, the value of C parameter in SVM was set to a large number to increase
regularization. Also combining different models significantly reduced drawbacks of single models. R 3.1.0 was
used for overall process. This method won the competition with MCRMSE score of 0.46892.

Solution Code: [@Code](https://github.com/Yasssser/AFSIS2014)
