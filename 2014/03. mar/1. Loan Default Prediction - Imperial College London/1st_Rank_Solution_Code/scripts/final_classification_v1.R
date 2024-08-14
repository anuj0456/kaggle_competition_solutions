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
source("scripts/crossValidateParallel.R")
mae = function(x,y) { mean(abs(x-y)) }

load("final_data_full.RData")
load("final_golden_features.RData")
load("min_of_golden_features_per_group.RData")


## add group id to data##
data$group.id = paste(as.character(data$f67), as.character(data$f597), sep = "_")


#########################################################
## create feature set for first classification task
#########################################################


## take ids, loss, categorical features and the golden features ##
feature.set = cbind(data[,c("id", "group.id", "loss","f776", "f777", "f778", "f2", "f4", "f5")], golden.features)

## add the first 200 columns from data ##
feature.set = cbind(feature.set, data[,!((colnames(data) %in% c("id","loss","f776", "f777", "f778", "f2", "f4", "f5")))][,1:200])

## add the aggregated minima of the golden features ##
feature.set = merge(feature.set, min.of.golden.features.per.group, by = "group.id", all.x = T)

## turn to binary ##
for(i in colnames(golden.features)){ 
  feature.set[,paste(i, "min", sep = "_")] = (feature.set[,i] == feature.set[,paste(i, "min", sep = "_")])*1 
}

## create train and test sets for the classification task ##
train = feature.set[is.na(feature.set$loss) == F,]
test = feature.set[is.na(feature.set$loss) == T,]


##########################
## classification model ##
##########################


model.fit = function(Input, Target, run){   
  fit = gbm.fit(x = Input, y = Target,
                distribution ="bernoulli",
                n.trees = 250,
                shrinkage = 0.05,
                interaction.depth = 8,
                n.minobsinnode = 100,
                verbose = F,
                bag.fraction = 0.8,
                keep.data = F)
}

model.predict = function(fit, Input, run){
  predict.gbm(object = fit, newdata = Input, fit$n.trees, type="response")
}


######################################################################
## create the probability of default for every sample in the train set
######################################################################


## compute 3 12-fold-cross-validation runs and save the results ##
## each sample in the train set gets predicted exactly 3 times ##

all.forecasts = foreach(i = 1:3, .combine = cbind) %do% {
  crossValidate(train[,4:length(train)], ifelse(train[,"loss"]>0, 1, 0), model.fit, model.predict, 12, F, "gbm", 3)$forecast
}

## final cv forecast is the mean of the 3 cross-validation runs ##
classes.train = rowMeans(all.forecasts)

## compute auc - should be about 0.9985 ##
roc.area(ifelse(train[,"loss"]>0, 1, 0), classes.train)

## save cv results ##
write.table(data.frame(id = train$id, pd = classes.train), "train_classes_gbm.csv", sep = ";", col.names = F, row.names = F, quote = F)


#####################################################################
## create the probability of default for every sample in the test set
#####################################################################


cl = makeCluster(rep("localhost",2), type="SOCK")
registerDoSNOW(cl)

all.forecasts = foreach(i = 1:3, .combine = cbind, .packages = "gbm") %dopar% {
  
  temp.fit = model.fit(train[,4:length(train)], ifelse(train[,"loss"]>0, 1, 0), i)
  temp.forecast = model.predict(temp.fit, test[,4:length(test)], i)
  
}

stopCluster(cl)

classes.test = rowMeans(all.forecasts)
write.table(data.frame(id = test$id, pd = classes.test), "test_classes_gbm.csv", sep = ";", col.names = F, row.names = F, quote = F)
