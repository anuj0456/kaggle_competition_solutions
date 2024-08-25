# Winning approach by Les Trois Mousquetaires

Team Members - [@Bibi Mining](https://github.com/bernat), [@Mattsco](https://github.com/mattsco), [@Romain Ayres](https://github.com/aromain)

REF: https://www.kaggle.com/competitions/tradeshift-text-classification/discussion/10901

## Summary

Our best submission is a blend of ~70 different models (online learning, two-stage sklearn and vowpal wabbit). Our best single model was the online one. Like beluga did, we added some tree features (non linear information) to the online learning process and this is what has helped the most. Finally, we ended up with 145 (base) + 115 (couples) + 100 (tree) = 360 features.

We failed in some way to correctly tune the two-stage sklearn script. The best score we had with this model was superior to 0.005. I guess it's because we only used RandomForestClassifier and SGDClassifier (next time we should try XGboost

Some things we tried but without success :

- sklearn GradientBoostingClassifier -> it didn't work at all, and we still don't really know why

- sort of semi-supervised learning -> we fixed a security threshold for which our predictions were 100% correct on a validation set, and added the correctly classified test examples to the train set (in fact, we helped the algorithm to learn better what he was already learning perfectly)

- post-processing -> we could detect some anomalies in our predictions (eg. y33>0.8 && y9>0.8), but we couldn't find a way to correct them by hand
