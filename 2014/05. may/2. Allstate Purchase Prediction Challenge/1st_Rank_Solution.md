# Winning approach by Prazaci

Team Members - [@maternaj](https://github.com/jirimaterna), [@Emil Skultety](https://github.com/skultemi), Nomindalai Naranbaatar, Perroquet, Lukáš Drápal

REF: https://www.kaggle.com/competitions/allstate-purchase-prediction-challenge/discussion/8218#44938

## Summary

For all the models, we used only gbm in R. We didn’t even seriously try anything else, so there may be a potential for more improvements with other methods.

## Details

The base of our idea was the same as for almost everybody here. We divided our data according to shopping_pt up to shopping_pt=6. The biggest value was of course for history 2 and we almost gained nothing for 6 as well as 5, but history 3 and 4 was still useful. As Breakfast Pirate posted the main idea was to find customers who have biggest potential that final purchase will be different from the current quote, i.e. for which it make sense to take a risk to change the last quote benchmark. We have trained few classifiers using adaboost metric (which seems to be a reasonable proxy to AUC), one classifier per each shopping point history.

Then we made three different models to predict the actual purchase record, all using multinomial metric in gbm.
First model was based on all available features in the provided data plus we added information from previous versions of ABCDEFG attributes and previous costs. This model consisted of 4 submodels – predicting together AF, BE, CD and G. These combinations were chosen based on the correlation matrix of these products. The second model was based on the same pairs of variables as the first model. It had all features as the first model and some more - a variable with mean cost in each state and each location was added. Moreover, after prediction of the first variable (G), a variable stating whether the model output is different from the LQB was added. The last pair (BE) was then modeled with information whether any other variable has changed. The last model was working with only three submodels (ABEF, CD, G) and had some more features relating to what was changed in the known customer history (e.g. ratios of current and previous costs, time differences, replacing of category variables with 1/0 feature vectors and feature subset vectors, etc.)

These three models were combined with corresponding classifier (models for history 2 with classifier for history 2, etc.) so we got the final predictions for each history. The algorithm used for the combining was based on the classifier prediction

- If the probability of the last quoted benchmark change was low, we kept the last quoted benchmark
- If the probability of the last quoted benchmark change was middle, we changed the last quoted benchmark only when all 3 models predicted the same value
- If the probability of the last quoted benchmark change was high, we changed the last quoted benchmark when at least 2 models predicted the same value

Our final solutions was putting together all predictions for all history (from 2 to 6). The most important parts of this blending was finding out the appropriate setting of the combining algorithm (i.e. which numbers to use for low/middle/high probabilities described above).

By the way, no specific handling for certain cases (such as Florida state) was done, however it looks from the feature importance that these specifics were found and used by the gbm trees.

Additionally, we didn’t use any specific cross validation within each gbm model, but we think the way the last step was done (kind of strict majority voting from the three models – about 2100 records was changed overall) is what kept as from overfitting the public leaderboard).
