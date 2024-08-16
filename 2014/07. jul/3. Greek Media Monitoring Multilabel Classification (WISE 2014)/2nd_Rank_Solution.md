# Winning approach by anttip

Team Members - [@Antti Puurula](https://github.com/anttttti), jread

REF: https://www.kaggle.com/competitions/wise-2014/discussion/9773

## Summary

Our approach had a lot in common. We built on our winning LSHTC4 system.

We used mainly Liblinear LR and SVM classifiers for each label, aka. binary relevance multi-label classification. In addition we had extensions of MNB classifiers, and tree-based classifiers. The trees were very difficult to train on the task, so they did not contribute much in the end. I also considered coding up scalable random forests from scratch, but I tested with Weka RandomForests, and it seemed difficult to get much out of tree-based methods. Depending on the base-classifier, we used the binary relevance, label powerset, classifier chain, and random labelset methods for multi-label classification.

For features we reversed the TF-IDF to get the original counts, and then used customized feature transforms. We also used 5 different LDA feature sets with GibbsLDA++, but these were difficult to optimize with this much data. At the end we came up with word pair features, these were useful as well, but tricky to optimize, and we probably could have got a lot more out of these with more time.

Ensemble combination was done with the feature-weighted linear stacking used in LSHTC4, with some new meta-features: since the data was time-ordered, we used the predicted labels for neighboring documents as meta-features.
