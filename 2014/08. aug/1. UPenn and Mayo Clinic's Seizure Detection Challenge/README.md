# Competition Details

## Goal

The objective of this competition is to:

1. High sensitivity & specificity applications. Potential applications of this algorithm would be for automated seizure diaries, where latency to seizure onset is not critical. Here the goal is to optimize the accuracy of detection.

2. For responsive stimulation application the latency of onset is of particular importance. The key to successful therapy is the ability to rapidly detect the onset of seizures. Often a highly sensitive detector is created, and high false positive rates are tolerated as the stimulation is below patient perception.

## Evaluation

Submissions are evaluated using area under the ROC curve (AUC) of two predictions. Firstly, you must predict the probability that a given clip is a seizure. Secondly, you must predict the probability that the clip is within the first 15 seconds its respective seizure (the technical term for time into the seizure is "latency").

## Timeline

Start Date - May 19, 2014
Entry Deadline - August 12, 2014
Team Merger Deadline - August 12, 2014
Final Submission Deadline - August 19, 2014

## Prizes

1st Place - $5000
2nd Place - $2000
3rd Place - $1000

## Winners

| id  | Team             |  Score  |
| --- | ---------------- | :-----: |
| 1   | Michael Hills    | 0.96287 |
| 2   | Olson and Mingle | 0.95655 |
| 3   | cdipsters        | 0.95643 |
| 4   | alap             | 0.95599 |
| 5   | Fusion           | 0.95436 |

## Organizers

@misc{seizure-detection,
author = {bbrinkm, sbaldassano, Will Cukierski},
title = {UPenn and Mayo Clinic's Seizure Detection Challenge},
publisher = {Kaggle},
year = {2014},
url = {https://kaggle.com/competitions/seizure-detection}
}
