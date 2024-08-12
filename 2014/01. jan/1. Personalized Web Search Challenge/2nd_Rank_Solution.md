# Winning approach by LR

Team Members - Guocong Song

REF: https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/wsdm233-song.pdf

## Abstract

RankNet is one of the widely adopted ranking models for web search tasks. However, adapting a generic RankNet for personalized search is little studied. In this paper, we first trained a variety of RankNets with different number of hidden layers and network structures on a per-user basis, and observed that a deep neural network with five hidden layers gives the best performance. To further improve the performance of adaptation, we propose a set of novel methods categorized into two groups. In the first group, three methods are proposed to properly assess the usefulness of each adaptation instance and only leverage the most informative instances to adapt a user-specific RankNet model. These assessments are based on KL-divergence, click entropy or a heuristic to ignore top clicks in adaptation queries. In the second group, two methods are proposed to regularize the training of the neural network in RankNet: one of these methods regularize the error back-propagation via a truncated gradient approach, while the other method limits the depth of the back propagation when adapting the neural network. We empirically evaluate our approaches using a large-scale real-world data set. Experimental results exhibit that our methods all give significant improvements over a strong baseline ranking system, and the truncated gradient approach gives the best performance, significantly better than all others.
