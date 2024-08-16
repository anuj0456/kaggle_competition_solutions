# Winning approach by AAAGV

Team Members - [@Gilles Louppe](https://github.com/glouppe), [@Arnaud Joly](https://github.com/arjoly), [@Aaron](https://github.com/qiuz), [@Antonio Sutera](https://github.com/asutera), [@Vincent François](https://github.com/vinf/)

REF: https://www.kaggle.com/competitions/connectomics/discussion/8149

## Solution

### Method

The core principle of our approach is to recover an undirected network by estimating partial correlations [1] for every pair of neurons. In particular, this approach is well-known for identifying first-order interactions (i.e.,
direct connections in the network) from higher-order interactions (i.e., indirect connections).

In order to increase the performance, the raw data is preprocessed by i) filtering the time series and ii) re-weighting the samples to take into account the number (and the intensity) of burst peaks [2].

As a last step, and to obtain slightly better results, we asymmetrize our score matrix by trying to determine (heuristically) the causality.

### Feature Selection / Extraction

The data were filtered using a low-pass filter, a high-pass filter and a hard tresholding filter (see `model/PCA.py:_preprocess`).

For the partial correlation method, we apply one more non-linear filter based on the overall neuron activity
(`model/PCA.py:_weights_fast`): for each sample, i.e. each time interval, we weight the samples depending on the global neuron activity at current and previous time steps, thereby lowering the effect of the end of high global burst periods in the correlation calculation.

Parameters of those filters have been optimized on normal-1 and normal-4 datasets.

### Modeling Techniques and Training

`model/PCA.py`: Once preprocessing is done, partial correlations are estimated
by computing the inverse of the correlation matrix (also known as the precision
matrix). To filter out noise, the inverse of the correlation matrix is recovered
from Principal Component Analysis (PCA) using the 800 first components (out
of 1000).

`model/directivity.py`: Some causal information (directivity of the links) were retrieved from the data by comparing activity of each couple of neurons between two subsequent time steps. The directivity method tries to detect variation of fluorescence signal of a neuron `j` due to a neuron `i`. Let us denote the fluorescence signal of a neuron `l` at time `t` by `x_l[t]`, this method counts the number of time that `x_j[t+1] - x_i[t]` is in `[f_1, f_2]` where `f_1` and `f_2` are parameters of the method.

## Dependencies

The following programs and packages were used for the contest:

    - Python 2.7
    - NumPy >= 1.6.2
    - SciPy >= 0.11
    - scikit-learn == master branch (last update, the hash commit was `8d04380d474723467b5a717328efd0c9fc5bd898`)

with appropriate blas and lapack binding such as MKL, accelerate or ATLAS.
In order to test the code, we recommend you to use the Anaconda python
distribution (https://store.continuum.io/cshop/anaconda/).

Code ran on MacOsx 10.9.2 and Linux (version 2.6.18-194.26.1.el5
(brewbuilder@norob.fnal.gov) (gcc version 4.1.2 20080704 (Red Hat 4.1.2-48))
1 SMP Tue Nov 9 12:46:16 EST 2010).

### How to train your model

No model is learnt to produce the connectivity score matrix.

### How to make predictions on a new test set

In order to reproduce the result, you can launch the main.py file.
The usage is the following:

    usage: main.py [-h] -f FLUORESCENCE [-p POSITION] -o OUTPUT -n NETWORK

    optional arguments:
      -h, --help            show this help message and exit
      -f FLUORESCENCE, --fluorescence FLUORESCENCE
                            Path to the fluorescence file
      -p POSITION, --position POSITION
                            Path to the network position file
      -o OUTPUT, --output OUTPUT
                            Path of the output/prediction file
      -n NETWORK, --network NETWORK
                            Network name

For example on the "test" dataset, you would use the following command:

    python main.py -f fluorescence_test.txt -p networkPositions_test.txt -o score_test.csv -n test

To run the script, you will need a machine with at least 8GB RAM, a fast
processor (> 2.5 GHz), 4 cores and sufficient disk space. On our last
test, it took around 10 hours (with 7 process) on normal-1 and +-2 hours on small-1.

The performance obtained on normal-1 and small-1 are the following:

    On normal-1: 0.94356018640593564
    On small-1: 0.71027913026472989

Note that all parameters have been optimized for a big dataset, i.e. 1000 neurons, and it explains the poor result on small-1.

Both solutions are combined together through averaging.

Solution: https://github.com/asutera/kaggle-connectomics/tree/master/code
