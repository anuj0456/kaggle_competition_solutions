# Winning approach by QMSDP

Team Members - hillip Chilton Adkins, Simone, [@Drew Abbot](https://github.com/drewabbot), Min Chen, quang tieng

REF: https://www.kaggle.com/competitions/seizure-prediction/discussion/11129

## Sumarry

Our winning submission was a weighted average of three separate models: a Generalized Linear Model regression with Lasso or elastic net regularization (via MATLAB's lassoglm function), a Random Forest (via MATLAB's TreeBagger implementation), and a bagged set of linear Support Vector Machines (via Python's scikit-learn toolkit).

Before merging as a team, we developed different feature sets for our models, but both sets were a combination of time- and frequency-domain information.

Solution Code: [Code](https://github.com/drewabbot/kaggle-seizure-prediction/tree/master)
