# Competition Details

## Goal

The objective of this competition is to o re-rank URLs of each SERP returned by the search engine according to the personal preferences of the users. In other words, participants need to personalize search using the long-term (user history based) and short-term (session-based) user context.

## Evaluation

Submissions will be evaluated using NDCG (Normalized Discounted Cumulative Gain) measure, which will be calculated using the ranking of URLs provided by participants for each query, and then averaged over queries.

The URLs are labeled using 3 grades of relevance: 0 (irrelevant), 1 (relevant), 2 (highly relevant). The labeling is done automatically, based on dwell-time and, hence, user-specific:

- 0 (irrelevant) grade corresponds to documents with no clicks and clicks with dwell time strictly less than 50 time units
- 1 (relevant) grade corresponds to documents with clicks and dwell time between 50 and 399 time units (inclusively)
- 2 (highly relevant) grade corresponds to the documents with clicks and dwell time not shorter than 400 time units. In addition, the relevance grade of 2 assigned to the documents associated with clicks which are the last actions in the corresponding sessions.

## Timeline

11th October 2013 - Competition begins
20th December 2013 - Registration of new participants stops
10th January 2014 - Final submission deadline
14th January 2014 - Preliminary winners notified
28th February, 2014 - Winners finalized.

## Prizes

1st place: $5,000
2nd place: $3,000
3rd place: $1,000

## Winners

| id  | Team                        |  Score  |
| --- | --------------------------- | :-----: |
| 1   | pampampampam (ooc)          | 0.80724 |
| 1   | Dataiku Data Science Studio | 0.80714 |
| 2   | LR                          | 0.80636 |
| 3   | learner                     | 0.80475 |
| 4   | DenXX                       | 0.80425 |
| 5   | YS-L                        | 0.80390 |

Note: The first place is held by the organizer team, which is out-of-the-competition.
