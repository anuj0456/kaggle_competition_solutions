# Winning approach by Manuel Díaz

Team Members - Manuel Díaz

REF: https://www.kaggle.com/competitions/random-number-grand-challenge/discussion/7565

Lets assume target values are sampled from a uniform distribution on the interval (0, 1)
If you make a prediction of 0.5, you're going to end up with an average error of 0.25. In fact, an average error of 0.25 is the best case for constant valued submissions, the further you deviate from 0.5 in your constant submission, the larger your average error.
Now lets say that the current 37th has an error of 0.45, and 36th has an error of 0.43. We would want to generate a submission that has an average error bounded by 0.43 and 0.45. Therefore making a constant prediction of 0.06 or 0.94 will give an expected error of 0.44, placing you in 37th place.
