# Winning approach by Victor Shlepov

Team Members - victorshlepov

REF: https://www.kaggle.com/competitions/leash-BELKA/discussion/519020

1. Here is the dataset with the (i) code - model and data processing utils (ii) SMILES encoder vocabulary. I will upload processed training data too (just to save ones time). Once I recover the the trained weights I will add them as well - I have only the light version of the model left (tf.keras.export), so I will likely retrain it from scratch. For those of you who prefer Kaggle notebooks - here is one (but I would not really process data here - it should take close to infinity).

2. The architecture is fairly simple and model is very flat - just 4 encoder layers with 8 heads. With a vocabulary size of just 43 tokens I end-up with a fixed dimensionality of 32. I've tried 64 and 16 too - they do not perform.

3. I guess I used atomInSmiles in a somewhat incorrect way and end up with a schema where separate tokens are either, atom (C, H, S, etc) or digits, or anything in square brackets, like [C@@] are distinct tokens. I leave it to chemistry practitioners to decide what this mess really means :)

4. Pre-training. I pre-trained model from scratch in two stages:

   - MLM - the standard prediction of masked tokens (15% of which 80% are masked, 10% are replaced with random token and 10% are retained - classics from "BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding"). I used dynamic mini-batch alpha weights for CategoricalFocalCrossEntropy, but it was just for fun. Not sure it contributed much. II've trained for about 100 epochs 10K steps each with 2028 samples per batch - the model processed dataset for about 20 times. Note that I've combined all the data here - train, test and external data (reference is in the original text below).

   * SMILES-to-ECFP (size=2048, include_chirality=True). Same model, just a different head (Dense layer with sigmoid activation) and locked embeddings. Some 20-50 epochs, if I recall correctly. The model did not performed great (there's many papers saying that SMILES encoders generally have a difficult time to predict topological fingerprints, and it was exactly the case) with MAP around 0.4, however, I guess that's exactly where it learned some useful representations.

   * My motivation here was to train model on some general task without taking a major overfitting risk. I picked ECFP for 2 reasons (a) performance - they were fast enough to compute, especially with scikit-fingerprints library, and (b) predicting fingerprints with no predefined meanings for each bit position (unlike MACCS or PubChem) is a challenging task for SMILES transformer, which is good - "no pain - no gain", as they say…

And, yes, I still wonder what "chirality" is :)

5. Training. Combined BELKA train set and external data. Masked loss and metrics since external data has labels just for sEH protein.

6. Validation. I put aside 3% of blocks from train set so my validation set included molecules with one ore more non-shared blocks - some 9 million of samples.

7. Tech - A100 on google collab.

That's it. As being said - no magic, just a pure luck and randomness…

Frankly speaking, the final LB results came as a bit of a surprise to me. The winning model is a very basic encoder: Self-Attention -> FeedForward with 4 layers and 8 heads per layer and key/value dimension of 32. The classics from the Transformers chapter of Tensorflow tutorials :)

I used the atomInSmiles tokenizer, but I did it incorrectly, so my tokenization scheme was almost character-based. I have not used any pre-trained models like ChemBERTa or similar.

The difference might have come from a two-stage pre-training schedule: (a) MLM - with 15% masking rate (b) SMILES to ECFP prediction. I'm not good at chemistry, to tell the truth, but I guess the second stage is where the encoder "learned" to extract some meaningful results from the SMILES.

Oh, last but not least: I used the data provided by the competition host and the dataset from "Building Block-Based Binding Predictions for DNA-Encoded Libraries", sited by @hengck23 and preprocessed by @chemdatafarmer early in the competition.

Now, the list of things that didn't work out as expected:

1. Complex tokenization schemes: bi- and tri-grams, atomInSmiles
2. Any model with a depth above 32 and more than 6 encoder layers
3. Multi-input models (SMILES + fingerprints)
4. Pre-training on a larger dataset—I spent about a month experimenting with ZINC…
5. Custom loss functions—BinaryFocusLoss was just fine
6. Gated fusion of building blocks
7. And many more—I will update the list.
