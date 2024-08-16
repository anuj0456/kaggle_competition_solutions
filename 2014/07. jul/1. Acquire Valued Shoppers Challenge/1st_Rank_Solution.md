# Winning approach by Marios & Gert

Team Members - Gert Jacobusse, yeticrab, [@Μαριος Μιχαηλιδης KazAnova](https://github.com/kaz-Anova)

REF: https://www.kaggle.com/competitions/acquire-valued-shoppers-challenge/discussion/9756

## Summary

Generally speaking, what was really important in this one was to find a way to cross validate(1st problem!) and retain features (or interactions of them ) and then again there was the big difference between the offers in the training and test set (2nd problem!).

For the first one we generally used a 1-vs-rest offers' approach to test the AUC and sometimes even derivatives of that. For the second (problem) we tried to maximize the with-in offers' auc (how well the offers score individually irrespective of the rest) and the total AUC (e.g. how the different offers blend together) as separate objectives.

We used 3 (conceptually) different approaches (and some other minor blends):

1. Train with similar offers
2. Train with whether the customer would have bought the product anyway
3. Assume that some features work for all offers in the same way

About the size of the data what really helped was to make a separate .csv file for each customer and put all their transactions in it. That way we could manipulate it at will. I will post a code for that, although it was really straight forward since the file was sorted by customer and date. All you had to do was:

1. open a reader,
2. stream each line
3. paste the new line in a file (named as customer_id.csv) for as long as the customer was the same.
4. switch to new file once the customer is different and so on.

That way you have kind of done the indexing yourself and it is very easy to aggregate a file with 200-300 lines of transactions!
