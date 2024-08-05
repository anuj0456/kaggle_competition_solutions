# Winning approach by flg

Team Members - flg

REF: https://www.kaggle.com/competitions/learning-agency-lab-automated-essay-scoring-2/discussion/516791

## TLDR:

1. Data analysis + experiments to find "new" data scoring patterns and get CV-LB-correlation.
2. Train Deberta ensemble reflecting these scores.
3. Two rounds of pseudo labelling to get "old" data with "new" scores.
4. Transform float predictions via thresholding to ints.
5. Ensemble without overfitting.

## Getting CV-LB-correlation

The dataset contained essays written by 8-12th graders from ~12 years ago. The competition used text-dependent essays, but most of the data was taken from the persuade corpus which included additional independent writing tasks. There are ~13k Persuade essays ("old") and 4.5k unseen ("new") essays in the competition data.

When comparing new and old data it was obvious there was quite a divide: two prompts were only present in "old" and the score distributions of same prompts were very different.
All texts seem to have been written at the same time (12-13 years ago), as even the "newer" texts didn't mention any recent events, politicians or billionaires when writing about exploring Venus/Mars and self-driving cars.

Some texts in persuade were written by students from different grades which could explain the score differences (maybe they were just worse?!). To test this (and other slight changes in scoring thresholds) I trained models on old or new data only and evaluated them on the other. I used ensembles of Debertas to rank the texts and calculated a "cheating" score that used the exact label distribution of the test data to turn the rankings into predictions. It helped close the gap but quite a sizeable difference remained.
This made me believe there were actual differences in the criteria that the raters used.

Since the new data was clearly using slightly different scoring criteria, I set up my training as a pre-train -> fine-tune, two-staged process. Pre-train on the old data (+ maybe aux data) and fine-tune on the new. This gave a boost of at least 0.015 on public LB and made CV-LB-correlation much better.
Within each stage I used stratified 5-fold split using prompt_id+score as labels.

## Train Deberta

With the two-staged approach training Deberta was fairly straightforward: find a decent baseline using Deberta base, find a set of working hyperparams for Deberta large and then generate a diverse set of models that can be used for creating ensembles. All models used regression and I evaluated the initial models mostly for MSE since I wanted to use them only for pseudo labelling (PL).

Best params:

| Param          |                       Value                       |
| -------------- | :-----------------------------------------------: |
| Base model     |                Deberta large, base                |
| Loss           | MSE, BinaryCrossEntropy (scale targets to [0, 1]) |
| Pooling        |                     CLS, Gem                      |
| Context length |                       1024                        |
| Batch size     |                         8                         |
| LR torso       |        1e-5, 5e-6 (pre-train / fine-tune)         |
| LR head        |                    2e-5, 1e-5                     |
| Epochs         |                         2                         |
| Warmup         |                 15% of pre-train                  |
| Decay          |                      cosine                       |
| Grad clip      |                        10                         |
| Weight decay   |                       0.01                        |
| Dropout        |                         0                         |
| Added tokens   |          "\n", " " (as @cdeotte shared)           |
| Init           |       normal\_(mean=0.0, std=0.02), bias=0        |

To create an ensemble with a bit of variety I mostly changed pooling, loss, context length and rarely LR. iirc shorter context length only ever made it into an ensemble if the weight was negative… But Deberta base was sometimes selected.

The fine-tuning dataset only contained ~4.5k samples. Spread over five prompts with six possible scores meant that data was quite scarce. Model performance varried a lot for different seeds, especially when using thresholding to get int predictions. To counteract this I 3-seed-averaged everything. This made a big difference in predictability.
Training three times as many models was very expensive but I found that only redoing the fine-tuning phase with a different seed made hardly any difference in performance and saved a lot of time. Still the model folder is around 2TB.

### Pseudo labelling

Since the criteria for scoring seemed to differ, I used an ensemble fine-tuned on the new data to get better scores for the old data. I did two rounds: the first used mean(score, ensemble_pred) and the second used the prediction exclusively (after retraining an ensemble on the first round data). I always used the exact float prediction, no rounding.

This is where it got a bit messy, the first round improved CV quite a bit but LB only slightly. The second round, however, improved CV even more, making a huge jump, but LB went down. The CV seemed not to correlated very well - I feared there was a leak that I missed (I didn't change the fine-tuning stage, only used the original labels) and didn't use the second round much. However one of the "bad" models scored 0.839 on private, single model, single seed (it was also the one with best CV). Maybe I could have trusted CV even more here but it seemed too risky.

### Thresholding (float -> int)

Many people found that rounding at custom values (1.67 instead of 1.5) could improve results a lot. From my testing it seemed to do a couple of things at once:

1. (over-) fit the targets
2. correct errors caused by impalanced score labels
3. Optimize quadratic weighted cohen's kappa (QWK).

1 is obvious and 2 is caused by regression loss and imbalanced data - errors of true_label==2 are always biased towards the majority class 3 instead of 1, causing the latter to be underrepresented. The last point, 3, is important because Cohen's Kappa can often be increased by moving predictions around (often towards minority classes) even if it decreases accuracy / MSE, see example. Typical thresholds for 1/2 were 1.7 and for 5/6 even 4.9 (there were very few 6s and some prompts had none!)

Data at the tails was very sparse and rounding thresholds could vary a lot between model seeds. I always used three seeds to calculate thresholds, without this it was too much gambling.

All my submissions are full-fits (train model on all data), which meant they always behaved somewhat differently from the OOFs even when using the same seed. Averaging probably helped because of this too.

To find the thresholds, I used minimize from scikit.optimize with "Powell", evaluating on 1 - qwk. Results seemed more reliable and much faster than guessing methods like Optuna. The found thresholds vary a bit based on the starting point of optimization, I average 15 different starting points.

### Ensemble

From trained models I created ensembles via simple averaging, Nelder-Mead and a Hill-climbing method (first seen from @cdeotte iirc). With PL, thresholding and fitted ensemble weights with just 4.5k samples, there was a huge chance of overfitting. Especially when fitting thresholds and weights independently even small ensembles fit the data way too well. I counteracted this by pre-calculating each model's thresholds individually (3-seeds) and using the ensemble weights for the thresholds too.

On top of this many subs were simple averages, squeezing out another 0.001 didn't seem as important as preventing overfitting.

### Submissions and luck

Almost all models I submitted were 3-seed-average at inference too. My largest chosen ensemble therefore was 7 models with 3 seeds each (21 Deberta large).

My three submissions were:

| Models          | Pseudo labelling |       Weights        |
| --------------- | ---------------- | :------------------: |
| 4 large, 1 base | no PL            | fitted, non-negative |
| 7 large         | 1st round        |   fitted, negative   |
| 4 large         | 1st + 2nd round  |    simple average    |

Only the last one (which came in at 0.841) was chosen by best CV, the others were selected for diversity (no model overlap, not using PL …). They did much worse: 0.838 and 0.837 on private.

Some of the best CV models:

| Models                                       | Pseudo labeling | Weights | CV    | Public LB | Private LB |
| -------------------------------------------- | --------------- | ------- | ----- | --------- | :--------: |
| Best ensemble, 4x large                      | 3x1st, 1x2nd    | average | 0.832 | 0.824     |   0.841    |
| Only 1st round PL models from best, 3x large | 1st             | average | 0.831 | 0.823     |   0.840    |
| Only 2nd round PL model, 1x large            | 2nd             | -       | 0.830 | 0.820     |   0.836    |
| Best single model                            | 2nd             | -       | 0.833 | 0.814     |   0.839    |

The second round of PL gave a couple of models like the last one, very good CV (like an ensemble) but LB went down. I feared a leak but they did fine on Private LB, so maybe just bad luck on Public ¯*(ツ)*/¯

### What worked

**Worked (rough order of importance)**

1. Trust CV when you're rank 619
2. Pretrain -> finetune on new data (+0.015)
3. Pseudo-label old data (+0.004-0.007)
4. 3-seed-average everything (mostly reduced variance, lucky seeds could still work well)
5. Spend a lot of time analysing score dists and sensitivity (esp. for thresholding)
6. Limit overfitting in ensembling (simple average, don't post-fit thresholds…)
7. Deberta large (base was ok on public but CV and private was 98% large)

**Neutral / unsure**

1. Additional data (Persuade, Ellipse) - non-text-dependent essays seemed to make little difference
2. Differential LR - tiny difference

**Did not work**

1. GBDT, weak as a model by itself for me, 2nd stage seemed not to add anything over ensemble + thresholding (didn't spend that much time though).
2. Adding prompt to input
3. Backtranslation
4. Classification with Deberta
5. Attention pooling
6. Rushing efficiency solution in the last 48 hours -> even half layer xsmall ONNX was too slow here, and it was the only thing I could produce quickly
