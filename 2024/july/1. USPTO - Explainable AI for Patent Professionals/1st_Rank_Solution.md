# Winning approach by tk & T0m

Team Members - tk,T0m
REF: https://www.kaggle.com/competitions/uspto-explainable-ai/discussion/522233

## summary

1. Simulated Annealing
2. Only AND, OR
3. Omission of AND using -

## Query

The format of the query is as follows:
(ti:word1-ti:word2-detd:word3-…-cpc:wordN) OR …

1. The query is composed only of AND, OR
2. By connecting words with -, the AND token can be omitted
3. cpc cannot be omitted with -, so cpc is placed last
4. Use all words for cpc, title, abstract
5. Delete words with high frequency (100,000 or more) for claim, description

## Candidate generation

Define a sequence of words connected by AND as a subquery.
Generate candidates for subqueries to be used in the query through the following steps:

1. Generate a set of words to be used in subqueries
   - All words possessed by a single target
   - Common set of words possessed by two targets
2. Sort words by the number of elements
3. Add words until the patent set consists only of targets, and make it a subquery
   - The patent set is obtained by taking the common set of each word
   - If there are non-targets after combining all the words, that subquery is not a candidate

## Tips for improvement

1. Reduce computational complexity by adding words in ascending order of elements
   - The complexity of calculating the common set of two sets s, t is min(len(s), len(t))
2. Speed up the calculation of the common set using cupy
   - 2-3 times faster compared to using set(a) & set(b)
   - cp.intersect1d(array1, array2)
   - On the final day, speeding up with this allowed using all cpc, title, abstract, and the rank improved from 3rd to 1st
3. Reduce memory usage by placing only patents appearing in test.csv (2500\*50) and the words those patents possess in memory

## Simulated Annealing

1. Combine subqueries with OR
2. Neighborhood
   - 50% chance to add one unused subquery
   - 50% chance to remove one used subquery
3. Score function
   - The number of targets included in the search results of the query
   - Consider only the number of targets as candidates are subqueries with zero non-targets
4. Duplicate removal
   - Reduce the number of candidates by removing duplicates, as subqueries with the same target set do not need multiple candidates

Solution: ![1st_Rank_Solution_Code.ipynb](1st_Rank_Solution_Code.ipynb)
