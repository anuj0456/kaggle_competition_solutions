# Winning approach by Medrr

Team Members - [@Medrr](https://github.com/medrr2)

REF: https://www.kaggle.com/competitions/seizure-prediction/discussion/11024

## Sumary

All the code that I developed for this competition was developed from scratch, written in native C, on Visual C++ environment using my general generic experience in ML and signal-processing.
From a relatively short time period after I joined the competition (I joined almost a month after it started), I realized that this competition is "very small data" big data competition. For example, for dog 1 there are only 4 independent cases of seizures.
Since this was the case, my intuition was that the algorithm should be super regulated against over fitting, and that KNN or tree-based algorithms couldn't work good enough.
I chose to use my "special", highly regulated, iterative LS Ensemble, and made a one-out LS Ensemble environment for finding the features and improving the algorithm. The fact that the algorithm was developed by me from scratch in native C, enabled me to put many “tricks” and regulations into it, and to put as many features as I want (something like 900-1500 features, depending on number of channels).
The features that I found were based on:

- General energy average and energy STDV over time (15 seconds bands), for each channel.
- FFT, Log of energy in different frequency bands for each channel.
- FFT, Log of energy, and total energy (without log) in different frequency bands for the average of all the channels.
- Correlation of energy in frequency bands between channels.
- SQRT or POW for each feature, in order to exploit nonlinear behavior of each feature.
  One more “trick” was the post processing (I believe that I could have won the competition even without this) - I found pairs of 10 minutes that are most likely to be together in time, and generally I did a MAX function of this pair scores.
  We are really in a great dilemma as to whether to apply for the prize, I am very proud to have won this competition but the concept of the generic part of our algorithms, which implemented by me from scratch for this competition, is currently being used by some of our works and may be used in the furture in other medical applications, so we may eventually decide not to take the prize money (maybe it could be used for future competitions), in order not to publish the exact source code of it.
