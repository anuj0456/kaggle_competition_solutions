# Winning approach by Herra Huu

Team Members - Herra Huu

REF: https://www.kaggle.com/competitions/pakdd-cup-2014/discussion/7668#42271

## Introduction

The goal of this competition was to predict future malfunctional components of ASUS notebooks from historical data. The number of repairs was heavenly dependent not just from the particular module-component pair but sales dates as well. This lead to the model where prediction were made for each triple module-component-sale date separately and then aggregated for final predictions.
The data was modelled using binomial regression model. The chosen approach could be thought as a distribution free method in terms of that underlying hazard function was not assumed to follow any particular distri- bution (like Weibull, Gompertz, log-Normal, etc). Some key aspects of the model were combining information from different levels of hierarchical struc- tures of the data and assuming certain kind of constraints for some of the parameters of the model.

## Data

For the beginning a couple of notes about missing data. Firstly, sales in- formation was missing for the module M7 and month 2006/5. As it was only this one module and one month I didn’t apply any complex imputa- tion schemes but instead just added hand picked value based on the previous monthly sales figures. Given the model parametrization described in the next

section this should have only quite limited impact on the predictions. Sec- ondly, if repair information was missing for any given month it was assumed that it indicated zero repairs and this information was added to the original dataset.
The following list of variables were derived for all unique module-component- sale time combinations and for all of their possible repair months

| Name                |                            Description                             |
| ------------------- | :----------------------------------------------------------------: |
| component           |             Unique integer ID value for each component             |
| moduleComponent     |       Unique integer ID value for each Module-Component pair       |
| moduleComponentTime | Unique integer ID value for each Module-Component-Sale time triple |
| saleCount           |                   How many components were sold                    |
| repairCount         |                 How many components were repaired                  |
| age                 |               Time between sale and repair in months               |
| repairMonth         |           Month of the repair, 1 =January, 12 =December            |

In addition to these, in the code there is a couple of helper data objects like maps between different ID values (e.g. mapping from moduleComponent ID to component ID) and length variables (e.g. how many different components exists).

## Model

The problem we would like to solve can be stated as following: given that we know how many components were sold, how many of those will be repaired in any given month? One possible way to approach this problem is binomial regression model. The problem can be written as
`repairCount ∼ binomial(saleCount, p)`
, where p is the probability of repair. As the probability p has to be in the
interval [0, 1] it’s often modelled using logistic link function, ie.
`p = inv.logit(θ)`
, where θ is now unrestricted parameter. The parameter θ was then modelled as a linear combination of three major components:

- βmct−scale, scale parameters for each moduleComponentTime
- βmc−age, time dependent parameters (one for each possible age) shared by all moduleComponentTime with same moduleComponent. Ie. it’s assumed that sale time of the moduleComponent doesn’t have an effect to the ”time distribution” of the repairs.
- βall−month, parameters for different repair months (January, February, etc) shared by all
  To take the hierarchical structure of the data in consideration Bayesian modelling techniques (though, not full Bayesian inference) were used and the parameters were given hierarchical prior distributions. As an example of such hierarchical structure is the relationship between component and moduleComponent. Let’s say that the component which we are interested is a battery. It does seem quite reasonable to assume that different batteries do behave more similarly to each other (in terms of repair counts) than say batteries and processors. A bit different kind of hierarchy would be in terms of time. E.g. module sold at time T should behave more similarly to the same module sold at time T + 1 than T + 2, if there is any difference at all.
  Parameters βmc−age were modelled in three parts as following for all mod- uleComponents separately (in total 80 parameters for each moduleCompo- nent):

1.  age ∈ [0, 26], there is training data for all of the moduleComponents
2.  age ∈ [27,59], training data for just some of the moduleComponents
    and age (but at least some amount of pooled data for components)
3.  age ∈ [59, 80], no training data
    For the first set of parameters the prior distribution was selected to be mul- tivariate normal where the mean vector is given by the component and the variance matrix is linear combination of squared exponential and Gaussian noise variances and is the same for all components. (see for example [3], also in the code mv-normal is calculated using Cholesky decomposition, de- tails: [2]) For the second set of parameters there is additional monotonically decreasing constraint. This constraint was included in the following way for all age ∈ [27, 59]:
    βmc−age[age] = βmc−age[age − 1] − exp(decaymc−age[age − 26])
    , where the vector decaymc−age follows same kind of multivariate normal prior as in the first set of parameters. And finally for the remaining parameters, the decay term was just assumed to be the same as the last value in the second set of parameters.

    Each moduleComponent has a varying number of sales months, denote by N, and therefore different number of βmct−scale parameters, usually around 10-15. The first selling month was given a distribution
    `βmct−scale[1] ∼ normal(μ, σ) and then for the rest T ∈ [2,N]`
    `βmct−scale[T ] ∼ normal(βmct−scale[T − 1], σchange)`
    Finally, one of 12 βall−month parameters was fixed to be zero and the rest followed normal distributions.
    For inference, a maximum a posteriori probability (MAP) estimates of the parameters were learned using BFGS-optimization algorithm. After learn- ing the parameters then the prediction were simply calculated as means of binomial distributions, ie
    `y = saleCount × p`
    These are predictions for all possible repair months and moduleComponent- Times. So to get the asked repair counts for the moduleComponents these predictions were then aggregated over different sale times.

    #### Additional Comments and Observations

    The model presented in this document could be improved in many ways. For example, the following list of ideas were considered, but not implemented due the time, computing power, memory etc. limits during the competition.

    - Let time dependent parameters to vary for each moduleComponent- Time, not just for moduleComponent. For example, this could be done using same kind of hierarchical structure of the parameters as in the original model and by just adding one more layer. Though, it would probably be a better idea to find a way to reduce the number of pa- rameters before doing so.
    - Repair counts of components are correlated. So it would make sense to use multivariate model instead of modelling them independently as was done here
    - Full Bayesian treatment instead of point estimates using MCMC (or variational etc) methods. Better parametrization should make this eas- ier, now the chain in the MCMC sampling didn’t seem to mix that well (or in the test run the number of warm up/burn-in iterations wasn’t high enough).
    - Monotonically decreasing constraint might be a bit too strict (at least one module might have > 24 months warranty period?).
    - Improving the prior distribution structures / selection of hyperparam- eters. E.g. in the current implementation the covariance matrices for the time dependent parameters are not that great (too much noise etc).

## Code

### Dependencies

Data processing and some parts of the prediction process were done with programming language R (version 3.0.1). Actual model specification and parameter learning on the other hand were carried out with probabilistic programming language Stan [1] through RStan (version 2.2) interface. De- tailed installation instructions for RStan are given in the website: https: //github.com/stan-dev/rstan/wiki/RStan-Getting-Started. In addi- tion R package rjson was used to load json files to R.
How To Generate the Solution Training the model
Run train.R script, which will

1. Load dataset custom train.csv, if that file exists using functions from data generation.R. Otherwise first generates the dataset (using original datasets from Kaggle and functions from data generation.R) and then save to the file.
2. Load stan model code (text specification of the model following some- what similar syntax as in BUGS/JAGS) and compile the model using stan model() function from RStan library
3. Learn model parameters using optimizing() function from RStan li- brary
4. Save parameters to the file

### Making predictions

Run predict.R script, which will

1. Load dataset custom test.csv following similar logic as in the 1. training
2. Load learned parameters from the disk
3. Calculate predictions for module-component-sale times
4. Aggregate predictions for module-components
5. Merge predictions with Output TargetID Mapping.csv to make sub- mission file
6. Save submission to the disk

Solution: https://github.com/edwin7758/Kaggle-PAKDD2014
