# Winning approach by Alexandre Barachant

Team Members - [@Alexandre Barachant](https://github.com/alexandrebarachant)

REF: https://www.kaggle.com/competitions/decoding-the-human-brain/discussion/9913#51715

## Summary

The general idea was to train a generic model on the 16 subjects, and use labels obtained with this model as an initialization of a unsupervised clustering algorithm, similar to a k-means.

This involves a special form of covariance matrices as feature, and Riemannian Geometry to classify them. This may appear odd, but it is based on my previous work dedicated to classification of EEG signals in the field of Brain Computer Interfaces.

The solution is composed by two classification steps. The first one is supervised and use data from the training subjects to build a generic model. This generic model will be applied on each test subjects to obtain a first estimation of the test labels. The second step is unsupervised and is applied independently on each test subjects. It will use the labels from the first step as an initialization of an iterative unsupervised algorithm, similar to a k-means clustering.
These two steps are build upon methods originally devoted to classification of P300 Evoked potential for EEG Brain-Computer Interfaces (BCI) :
• A dedicated Spatial filtering is applied on the data in order to increase the signal to noise ratio and reduce the dimensionality of the signal.
• Special form of the covariance matrices of the trials are used as features, and ma- nipulated with tools from Riemannian Geometry. Indeed, covariance matrices are Symmetric and Positive-Definite Matrices (SPD), and therefore belong to a Riemannian manifold. A dedicated metric should be used in order to take into account the structure of the manifold.

Solution Summary: [Summary](1st_Rank_Solution_Summary.pdf)

Solution Code: https://github.com/alexandrebarachant/DecMeg2014
