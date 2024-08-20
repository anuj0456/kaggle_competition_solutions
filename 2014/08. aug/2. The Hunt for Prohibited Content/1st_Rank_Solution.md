# Winning approach by barisumog & Giulio

Team Members - [@barisumog](https://github.com/barisumog), [@Giulio](https://github.com/adjgiulio)

REF: https://www.kaggle.com/competitions/avito-prohibited-content/discussion/10178

## Giulio' Approach

My model was essentially a series of SGD on pieces of the text data (one for title, one for description, one for title+description, one for attrs). This alone gets you around .97 on the public LB. By adding to the tfidf matrices one-hot-encoded category and subcategory the models score well above .97.
The outputs from all the SGDs were then fed into a tree model (RF worked better than GBM) along with some other features, most importantly category and subcategory, but also email, url and phone number counts. This piece really helped the model re-learn the differences among categories and subcategories and re-sort the original SGD predictions. This added another .002-3ish and takes you in .983 territory.
Since plain accuracy was so high across the dataset, semi-supervised test data added in the order of .003 to the train data alone bringing my best model around .986.
All of this was built on the entire data minus real estate, which barisimug found out could be removed not only without any loss, but with a sizeable increase in performance.

I'll let barisumog describe his models but in his approach he modelled each category and subcategory independently, later stacking results.

Our winner model is a simple rank based weighed average of my best RF andGBM, and barisumog's ensemble of SVMs.

We used ranks to blend our models mostly because, from a practical perspective, our model outputs were on different scales (mine were probabilities, barisumog’s were distances from the SVM separating hyperplane). In reality I have observed that even amongst my models (who all produced probabilities) ranks were still as good as if not better than probabilities for blends.
My intuition, with no scientific evidence for it, is that when using semi-supervised learning you end up getting many extreme predictions for the test set, with lots of observations clustering around 1 and 0. That makes intuitive sense since you’re predicting observations the algorithm has already seen in training. With these big clusters of 1’s, .9995’s, .9993’s… ranking is introducing some (admittedly arbitrary) randomization, which might act as a good counterweight to the extreme decisiveness of semi-supervised approaches.

Another surprising thing for me was the fact I was getting much less than in other competitions out of ensembles. It really took two very distinct approaches to get decent value out of our team ensemble. And that was also, the key to our success. I'm really curious to see what other approaches folks have come up with, but essentially we had two very good models covering two very different approaches.

Things that did not work for me:
-is_proven added no value to our models
-feature engineering has provided little to no value. I tried a bunch of features derived from text (i.e. count of !, ?, mixed words, length of text,...) and none seemed to add much.
-for the attributes feature, anything more fancy that running it through a tfidf added nothing.
-I tried a second level model where I’d take the top 20% observations and re-model those alone to see if it could help further minimize false positives. Even at different cutoffs, that did not help.

Things that did work for me:
-no need to do anything fancy with the russian text. Just feed it into a tfidf vectorizer and you’re already in better shape than the benchmark code.
-simple semi-supervised learning performed the best. I tried using only portions of the scored test set (i.e. observation with predicted probabilities above .9 or below .1), tried many cutoffs, but nothing was better than using all test. I even tried to use all the test set but weighted its observations based on how close to 0 and 1 the probabilities were, but that also did not add value.

One part of the competition that was a first, and very interesting for someone like me who enjoys the competitive aspect of Kaggle, was the strategic aspect of managing a high LB rank. This is where machine learning becomes strategic/competitive machine learning. :-)

## barisumog's Approach

About my approach: I don't speak Russian, but running numerous data through Google translate, I could see that some categories used very different language than others. Also the ratio of illicit content varied widely between categories (and subcategories). So I decided to tackle the problem on a category / subcategory basis.

This is what I did, in steps:

separate the raw data into categories and subcategories
ignore the Real Estate category and related subcategories (vastly different language than other categories, and very tiny ratio of illicit content)
extract raw text from each post by concatenating the title, description and attributes sections (We tried many other features, some worked for Giulio, but none for me. I used only textual features)
for each category and subcategory, create 3 tf-idf matrices: one with raw text, one with stemming, and one with stop words (separately, they gave similar results, but I noticed they improved the score a bit and became more stable when combined)
for each category and subcategory, train 2 sets of SVCs with different C parameters on each tf-idf (again, similar results separately, but slightly better when combined)
so now I have 2 x 3 SVCs for every category, and 2 x 3 SVCs for every subcategory (12 models to use for every data point)
apply semi-supervised learning, which was Giulio's idea and worked quite well. Use the trained models on test data to predict classes. Concatenate train+test, and labels+prediction. Retrain all models on this new merged data set.
finally, use the models to make predictions on the test data. use the SVC output of distance from hyperplane to rank the individual posts
Then Giulio did some of his magic to combine my ranks with his own models. As he already pointed out, the difference of approach between our models resulted in a nice boost when ensembled.
