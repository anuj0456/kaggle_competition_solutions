# Winning approach by Mikhail & Dmitry

Team Members - [@Dmitry Dryomov](https://github.com/dremovd), [@Mikhail Trofimov](https://github.com/geffy)

REF: https://www.kaggle.com/competitions/avito-prohibited-content/discussion/10178

## Summary

Our approach is quite similar to discribed by Giulio. We use different pieces of data (title, title+description, title+description+attrs, title+attrs) and made 3 levels of details for each (top100k word, all word, all pair of words). For all of this features-sets was trained SVM, for some - additional LibFM models. Solely they give 0.97 - 0.983.

All this models was blended by RF, so it gave 0.986.
