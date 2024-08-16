# Winning approach by Heikki Huttunen

Team Members - [@Heikki Huttunen](https://github.com/mahehu/decmeg), [@Oguzhan Gencoglu](https://github.com/ogencoglu), johannes,

REF: https://www.kaggle.com/competitions/decoding-the-human-brain/discussion/9913#51509

## Summary

The model is a hierarchical combination of logistic regression and random forest. The first layer consists of a collection of 337 logistic regression classifiers, each using data either from a single sensor (31 features) or data from a single time point (306 features). The resulting probability estimates are fed to a 1000-tree random forest, which makes the final decision.

The model is wrapped into the LrCollection class. The prediction is boosted in a semisupervised manner by iterated training with the test samples and their predicted classes only. This iteration is wrapped in the class IterativeTrainer.

Requires sklearn, scipy and numpy packages.

Platform: Tested on Scientific Linux release 6.5 and Ubuntu 14.04 LTS.

Example usage:

```
python train.py
python predict.py
```

Solution Code: https://github.com/mahehu/decmeg
