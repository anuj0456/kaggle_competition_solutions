# Winning approach by Dataiku Data Science Studio

Team Members - Paul Masurel, Kenji Lefèvre, Matthieu Scordia, Christophe Bourguignat

REF: https://blog.dataiku.com/2014/01/14/winning-kaggle

**Disclaimer**: The contents of these blog posts will not contain all the information required to reproduce our solution; however, the ACM workshop paper will.

## Pertinence

Let's assume we are in charge of a search engine. If it is a web search engine, we want to improve our user satisfaction. If it is powering an e-commerce website we might want to optimize our margin. In any case, how can we measure our engine's effectiveness? How can we improve it?

The key to these questions is log analysis. One can just take a look at the rank of the URLs which have been clicked in the past. A good search engine is expected to put the URLs most likely to be clicked at the top of the search result page. Kaggle's contest used a formula called Normalized Discounted Cumulative Gain or NDCG, that have been crafted precisely to capture this idea.

As an extra refinement, it is possible to put some hierarchy on the quality of those clicks.

For instance, in e-commerce, one could give a greater score to clicks that eventually got converted into a sale. In the case of Web search, a common trick is to use the so-called dwell-time as a measure of conversion. The idea is simple: if a user performs a new query a couple of seconds after having clicked on a URL, he was probably not satisfied by the result. Yandex's contest took the dwell-time in account to associate a score of 0, 1 or 2 to each clicks.

## The Data

For this contest, Yandex provided around 16 GB of log-like data. The log contains the search history of 5,736,333 users for a period of 27 days. That's 21,073,569 queries, with for each query :

1. A user id
2. A list of the terms that forms the query
3. The 10 URLs that have been displayed and their domains
4. The URLs on which the user clicked
5. The timing of all of these actions

In addition to this historical data, test sessions were picked within Day 28 to Day 30 and supplied in a separate file. The goal of the contest was to fix the order of the URLs in the test sessions to obtain the greatest NDCG possible.

All of this data was anonymized by replacing all piece of information (users, urls, terms, domains, queries) by an id. While contestants may have felt this obfuscation was frustrating and counterproductive, it was not an option for Yandex to do differently. In 2006, for research purposes, AOL disclosed such a web search log, except that only usernames were replaced by IDs. The websphere rapidly started identifying some of the users appearing in the log, just by looking at the queries they performed. The story ended up with a class action against AOL.

### Re-Ranking Traps

The baseline of this contest was the score obtained when the results were returned in the same order as primarily served by Yandex. Interestingly enough, half of the contestants failed beating the baseline. The reason for that is that there is a trap in learning-to-rank.

Actually some of these solutions might still have been an improvement over Yandex initial ranking. The problem is that the scoring metric was done with regard to the clicks obtained using Yandex initial ranking... And users tend to click on URLs appearing at the top of the page.

Ideally computing the actual score of a solution would have consisted of deploying the new solution, and computing the score with the clicks obtained with the new ordering. This is however not feasible in practice.

In the end, computing the score against the clicks observed with your former ranking is the only way to go. This introduces a bias, as user tend to click on URLs that appear at the top of the result list. For this reason, in order to get a high score, it is crucial to detect when a result should or should not be re-ranked.

For the same reasons, the score announced is just a lower bound of the score to expect in production. When Yandex engineers actually put such an algorithm into production, they most likely observe a greater improvement of the NDCG.

Now that we avoided the booby trap, let's see how to

- learn a simple model that improve the current NDCG of your search engine
- put the model into production

## Point-Wise Learning to Rank

The problem of learning how to sort elements to maximize some given metric is usually called Learning-to-rank in Machine Learning. A simple approach (called point-wise approach) consists of transforming the problem of ranking into a problem of classification.

Problem: supervised learning requires labeled data. The first step for us was to split the historical dataset into two parts.

- Day 1 to Day 24 will be used as our "history", to gain information about the user.
- Day 25 to Day 27 will be our labeled "training dataset".
  We cherry-picked sessions for our training dataset using the instructions described by Yandex to make it as similar as possible to Yandex test dataset, except that the URL of our test sessions were now labelled with their respective satisfaction, making the usage of supervised learning techniques possible.

Given a search result page, we built up for each result URL a long list of features. While we will describe in detail the features that we tested in the workshop paper, let me just present a few features we had:

- The rank of the URL. The rank of the URL is very important for two reasons. First, independently of the quality of the sort order, users will tend to click on one of the first few links, because they read linearly. Second, because the rank has been computed with information we otherwise don't have access to (PageRank, tf-idf).
- Informative feature (e.g. Number of times the user clicked on the URL in the past, etc ...)
- Inhibiting/Promoting features helping soften or harden the importance of the initial rank. (e.g. Query click entropy, User click ranks, ...). These features help us know whether we should or should not rerank.

A classification algorithm will be trained to predict whether URLs will be clicked or not. With a binary satisfaction framework (clicked or not clicked), we then just have to sort the URLs depending on their respective predicted click probability.

An important detail here is that the parameter of the classifier (in our case Random Tree Forests) should be tuned to optimize the NDCG score on the cross validation set.

We used this simple point-wise approach up to the last week of the contest. The classification itself was done using scikit-learn implementation of Random Forests. Hadn't we switched to a more sophisticated algorithm called LambdaMart, this simple approach would still have ranked 5th on the leaderboard. Not bad uh?

## Production

**How should one go with putting such an algorithm into production?**

A first solution is to compute the features, inject them into the model and sort the URL accordingly.

But something sounds wrong doesn't it? Our new sort is greatly influenced by the initial sort. One improvement could be to wait a month to rebuild some log information and iterate the process.

In some other learning-to-rank application (typically online advertising, or to some extent e-commerce search), the initial sort can probably be considered as not holding much pertinent information. In that case, a practical solution is to ditch the rank information by zeroing all your rank feature before prediction.

This latter approach is however a very bad idea in the case of web search, as un-personalized rank contains a lot of precious information.
