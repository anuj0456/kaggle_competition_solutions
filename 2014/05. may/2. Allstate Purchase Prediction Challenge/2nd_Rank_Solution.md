# Winning approach by Alessandro & BreakfastPirate

Team Members - [@Santiago Castro](https://github.com/bryant1410), [@Alessandro Mariani](https://github.com/alzmcr)

REF: https://www.kaggle.com/competitions/allstate-purchase-prediction-challenge/discussion/8218

## Summary

One key to this competition was choosing what _not_ to change from the baseline. We didn’t change B or E at all. We only changed a small percentage of ACDF – usually only ones with shopping_pt=2. Before teaming up about a week ago, Alessandro had a top 10 score only changing G. We basically used his G and my ACDF. I think our solution only had about 2,500 rows that differed from the baseline (so less than 5% difference).

Something else that helped was finding the “Georgia/Florida tricks.” No customers in Georgia had C=1 or D=1 in their final purchase. But some customers had C=1 or D=1 as part of their last quoted plan in the test set. Changing these to 2 gave improvement. Similarly, no customers in Florida had G=2 in their final purchase. Did anyone find any other situations like these?

In addition to the base features, features I found useful were the A, B, C, D, E, F, and G from the previous shopping_pt. Also cost change from the previous shopping_pt.

I used GBM to predict individual ACDF values. Something that made this challenge difficult was that customers who could be safely predicted to change one product also had a high propensity to change multiple products – and getting multiple changes correct for one customer was difficult. So the customers that were easiest to predict for individual products turned out to be difficult to predict overall.

## Details

The main idea is that we don't know at what shopping_pt the purchase will be made. We know which plans fit more each profiles, so basically I'm training the model on the whole dataset using the purchased plan as target at each shopping_pt during the transaction history for all the customers. Even though purchases never happen at shopping_pt #1, it is included in the training data. The main reason is because patterns which occur at shopping_pt #1 for some customer can occur at different shopping_pt for others customers, leading to the same plan purchased.

I’m using is a Random Forest (scikit-learn implementation) as base model, which by itself only can give quite good results. To produce a robust model, I’ve ensemble 9 Random Forest out of other 50. If five out nine models agree on the same plan then this change is made, otherwise the last quote is used (majority vote).

The final ensemble, which led our team to place 2nd in the private leader board, is the combination of my predicted G and Steve’s ABCEDF.

## Extra Features

I’ve used all the features provided, at exception of date & time. To help tree interaction and improve the accuracy I’ve also included the following features, group by category for your convenience.

Category Interactions (2-way)

G & shopping_pt ** 1st most important
G & state ** 7th most important
state & shopping_pt
Category & Interaction mapped at arithmetic mean of the cost

mean of cost grouped by G \*\* 3rd most important
mean of cost grouped by State & G
mean of cost grouped by State
Average of target variable

Average of purchased G plus some randomness, grouped by location ** 5th most important
Average of purchased G plus some randomness, grouped by state ** 6th most important
Continuous Interactions

cost / group_size
cost / car_age
Naming Convention
Product: A, B, C, D, E, F and G are all products.
Plan: Combination of A, B, C, D, E, F and G.
Baseline: Is the last plan or product quoted at the latest shopping_pt available.

Metric
The score I’ve used to determine how good a model is defined as follow. The difference between the baseline accuracy and the model accuracy measured at each single shopping_pt, times the number of samples in the test set at that shopping_pt. For example, the difference between the model and the baseline for shopping_pt #2 is 0.4160-0.4116=0.0044 times the count of the test samples where the latest shopping_pt available is #2 is 0.0044x18,943=58.5. I’ll be addressing to score at the sum product of these differences and the test set distribution.

## Modelling Techniques & Training

A Random Forest is by itself an ensemble of decision trees. Each decision tree in a Random Forest is trained on different subset of data, leading to many different trees. The Random Forest predictive power comes with the ensemble of all these trees, stacking the class probabilities.

The higher is the number of tree we’ll build, the more accurate and more stable the prediction will be. This is what happens usually, but not in this problem since the gain over the baseline is very low. Making this more sensible to randomness and harder to fix only increasing the number of tree!

Instead of keep stacking the class probabilities and increasing the number of tree, we can keep the number of tree in the Random Forest lower and look at the output at a number of Random Forests. If the majority of these agree on the same outcome, then is quite likely that change is actually occurring. If the majority have the same outcome, then chose this as final prediction. Otherwise use the safest option: the baseline. Making this strategy is less prone to randomness.

I’ve trained several Random Forest using the same data but using different seed, which approximately lead to ~300 different predictions out of 55,716. Is quite a low number, but in this particular competition one more accurate prediction is the difference between the 2nd and 3rd place! Hence here comes the need to have not just a good model, but a very stable model which will generalize as much constantly as it could on unseen data.

Using the majority vote ideas gave a quite stable prediction (and more accurate). What helped a little bit further was selecting a subset of all the Random Forests which are expected to have a better accuracy. How? While looking for a way to identify more accurate Random Forest I’ve noticed that for higher train set scores, usually there is an higher cross validation score. Following this intuition I could discard model whom their train set score was worse than the others as they are more likely to be not good as the others. Do a majority vote on the best 9 Random Forests instead of using all the 50 improved the results too!

Solution: https://github.com/alzmcr/allstate
