# Winning approach by carl and snow

Team Members - [@Jiwei Liu](https://github.com/daxiongshu), [@Xueer Chen](https://github.com/xuerchen)

REF: https://www.kaggle.com/competitions/tradeshift-text-classification/discussion/10901

## Summary

Our winning solution ensembles 14 two-stage xgb models and 7 online models. Our best single xgb model gets 0.0043835/0.0044595 for public and private LB. It is generated as follows:

1. Use the second half training data as base and the first half training data as meta, instead of random split. (this is key!)

2. we use four base classifiers: random forest for numerical features, SGDClassifier for sparse features, online logistic for all features and xgb for all features.

3. For meta classifier, we use xgb with depth 18, 120 trees and 0.09 eta.

The xgb models could be memory intensive. We use a 8-core 32 GB memory server for most of our submissions. Thank my boss for the machine :P

Something we tried but it didn't work

1. bagging trees of different sub-sampling of columns of xgb trees by tuning "colsample_bytree". This trick is shown to work well in higgs contest but we have no luck. It only gives a very little improvement.

2. Add a third layer to Dmitry's benchmark. The score is not that bad but it just doesn't blend well with our existing submissions.

3. structured learning. We try to use pystruct, https://pystruct.github.io/, to predict a sequence rather than each label separately. This is our problem. we could find a way to make it work.

4. predict sequences rather labels. there are only 141 unique combinations of 33 labels in training sets, which means we can encode the 33 labels to 141 new labels and predict them. The score is really bad when we translate them back..
