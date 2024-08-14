library("plyr")
library("foreach")
library("gbm")
library("snow")
library("doSNOW")
library("verification")
library("reshape2")
library("ROCR")
library("caret")

setwd("../LoanDefault")

mae = function(x,y) { mean(abs(x-y)) }

train = read.csv("data/train_v2.csv", stringsAsFactors = F, header = T)

test = read.csv("data/test_v2.csv", stringsAsFactors = F, header = T)
test$loss = NA

## combine train and test set to one complete table for easier handling ##
data = rbind(train, test)

## remove duplicate columns based on the first 25000 rows ##
data = data[!duplicated(as.list(data[1:25000,]))]

## correct f4 ##
data$f4 = data$f4/100

## save copy for faster loading ##
save(data, file = "final_data_full.RData")



#####################################################################################
## create all golden features
## golden features are the difference of two highly correlated columns
## for example f527 - f528
## see https://www.kaggle.com/c/loan-default-prediction/forums/t/7115/golden-features
#####################################################################################



## build a correlation matrix based on the first 100000 rows ##
corr.matrix = cor(data[1:100000, 2:679], use = "pairwise.complete.obs")
corr.matrix[is.na(corr.matrix)] = 0

## create sets of features that are very highly correlated ##
corr.list = foreach(i = 1:nrow(corr.matrix)) %do% {
  rownames(corr.matrix[corr.matrix[,i] > 0.996,])
}

## remove empty sets ##
corr.list = corr.list[sapply(corr.list, function(x) length(x) > 0 )]

## remove duplicated sets ##
corr.list = unique(corr.list)

## create dataframe of correlated pairs of features ##
corr.pairs = foreach(i = 1:length(corr.list), .combine = rbind) %do% {
  
  temp.feats = corr.list[[i]]
  
  t(combn(temp.feats,2))
  
}

## remove duplicated pairs ##
corr.pairs = unique(corr.pairs)

## compute difference of each feature pair and save as dataframe ##
golden.features = foreach(i = 1:length(corr.pairs[,1]), .combine = cbind) %do% {  
  temp.feats = corr.pairs[i,]
  new.feat.temp = data[,temp.feats[1]] - data[,temp.feats[2]]
}
golden.features = as.data.frame(golden.features)

## create useful column names ##
colnames(golden.features) = apply(corr.pairs, 1, function(x) paste("diff", x[1], x[2], sep = "_"))


## lots of these golden features are very highly correlated and can be removed to save space and time ## 
## remove correlated features based on the first 100000 rows ##

## create correlation matrix
corr.matrix = cor(golden.features[1:100000,], use = "pairwise.complete.obs")
corr.matrix[is.na(corr.matrix) == T] = 0

## find highly correlated features ##
useless.features = colnames(corr.matrix)[findCorrelation(corr.matrix, cutoff = 0.99, verbose = F)]

## remove highly correlated features ##
for(i in useless.features) {golden.features[,i] = NULL}
#golden.features = golden.features[,!(colnames(golden.features) %in% useless.features)]

## save golden features ##
save(golden.features, file = "final_golden_features.RData")


##############################################
## create basis for the aggregated feature set
##############################################


## create an id for each group ##
group.identifier = paste(as.character(data$f67), as.character(data$f597), sep = "_")

## compute the minimum of each golden feature per group id ##
min.of.golden.features.per.group = foreach(i = colnames(golden.features), .combine = cbind) %do% {
  aggregate(golden.features[,i], by = list(group.identifier), min)[,2]  
}

## create column names ##
colnames(min.of.golden.features.per.group) = paste(colnames(golden.features), "min", sep = "_")

## add group id ##
min.of.golden.features.per.group = data.frame(group.id = unique(group.identifier)[order(unique(group.identifier))],
                                              min.of.golden.features.per.group)

## save for easier reuse##
save(min.of.golden.features.per.group, file = "min_of_golden_features_per_group.RData")
