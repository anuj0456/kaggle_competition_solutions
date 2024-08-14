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

## ignore certain defaulter --> very low pd ##
classes.train = read.csv("train_classes_gbm.csv", stringsAsFactors = F, header = F, sep = ";")
colnames(classes.train) = c("id", "pd")

classes.test = read.csv("test_classes_gbm.csv", stringsAsFactors = F, header = F, sep = ";")
colnames(classes.test) = c("id", "pd")

## identify ids with a very low probability of default --> those can be ignored ##
train.id.certain.default = classes.train[classes.train$pd <= 0.00074,]
test.id.certain.default = classes.test[classes.test$pd <= 0.00074,]


#########################################################
## create feature set for first classification task
#########################################################


## take ids, loss, categorical features and the golden features ##
feature.set = cbind(data[,c("id", "group.id", "loss","f776", "f777", "f778", "f2", "f4", "f5")], golden.features)

## add all remaining columns from data ##
feature.set = cbind(feature.set, data[,!((colnames(data) %in% c("id","group.id","loss","f776", "f777", "f778", "f2", "f4", "f5")))])

## add the aggregated minima of the golden features ##
feature.set = merge(feature.set, min.of.golden.features.per.group, by = "group.id", all.x = T)

## turn to binary ##
for(i in colnames(golden.features)){ 
  feature.set[,paste(i, "min", sep = "_")] = (feature.set[,i] == feature.set[,paste(i, "min", sep = "_")])*1 
}

## create train and test sets for the classification task ##
train = feature.set[is.na(feature.set$loss) == F & !(feature.set$id %in% train.id.certain.default$id),]
test = feature.set[is.na(feature.set$loss) == T & !(feature.set$id %in% test.id.certain.default$id),]

##########################
## classification model ##
##########################


## model ##
model.fit = function(Input, Target, run){
  
  settings = read.table("../LoanDefault/rgf1.2/test/sample/train_classification.inp", stringsAsFactors = F)
  settings[1,1] = paste("train_x_fn=sample/train.data.x.", run, sep = "")
  settings[2,1] = paste("train_y_fn=sample/train.data.y.", run, sep = "")
  settings[3,1] = paste("model_fn_prefix=output/model.run.", run, sep = "")
  write.table(settings, paste(getwd(), "/rgf1.2/test/sample/train.", run, ".inp", sep = ""), col.names = F, row.names = F, quote = F)
  
  write.table(Input, paste(getwd(), "/rgf1.2/test/sample/train.data.x.", run, sep=""), row.names = F, col.names = F, na = "-10")
  write.table(Target, paste(getwd(), "/rgf1.2/test/sample/train.data.y.", run, sep=""), row.names = F, col.names = F, na = "-10")
  
  setwd("../LoanDefault/rgf1.2/test")
  
  cmd.rgf = paste("perl call_exe.pl ../bin/rgf train sample/train.", run, sep = "")
  
  system(cmd.rgf)
  
  setwd("../LoanDefault")
  
  return(1)
}

model.predict = function(fit, Input, run){ 
  
  settings = read.table("../LoanDefault/rgf1.2/test/sample/predict.inp", stringsAsFactors = F)
  settings[1,1] = paste("test_x_fn=sample/test.data.x.", run, sep = "")
  settings[2,1] = paste("model_fn=output/model.run.", run, "-01", sep = "")
  settings[3,1] = paste("prediction_fn=output/sample.pred.", run, sep = "")
  write.table(settings, paste(getwd(), "/rgf1.2/test/sample/predict.", run, ".inp", sep = ""), col.names = F, row.names = F, quote = F)
  
  write.table(Input, paste(getwd(), "/rgf1.2/test/sample/test.data.x.", run, sep=""), row.names = F, col.names = F, na = "-10")
  
  setwd("../LoanDefault/rgf1.2/test")
  
  cmd.rgf = paste("perl call_exe.pl ../bin/rgf predict sample/predict.", run, sep = "")
  
  system(cmd.rgf)
  
  setwd("../LoanDefault")
  
  prediction = read.table(paste(getwd(),"/rgf1.2/test/output/sample.pred.", run, sep=""))$V1
  
  return(prediction)
}


######################################################################
## create the probability of default for every sample in the train set
######################################################################


## compute 2 10-fold-cross-validation runs and save the results ##
## each sample in the train set gets predicted exactly 2 times ##

all.forecasts = foreach(i = 1:2, .combine = cbind) %do% {
  crossValidate(train[,4:length(train)], ifelse(train[,"loss"]>0, 1, -1), model.fit, model.predict, 10, F, "gbm", 5)$forecast
}

## final cv forecast is the mean of the 2 cross-validation runs ##
classes.train = rowMeans(all.forecasts)

## rescale them into [0,1] ##
classes.train = (classes.train+1)/2

## save cv results ##
write.table(data.frame(id = train$id, pd = classes.train), "train_classes_rgf.csv", sep = ";", col.names = F, row.names = F, quote = F)

## add ids with very low pd ##
classes.train.full = rbind(train.id.certain.default,
                           data.frame(id = train$id, pd = classes.train))
write.table(classes.train.full, "train_classes_full.csv", sep = ";", col.names = F, row.names = F, quote = F)


#####################################################################
## create the probability of default for every sample in the test set
#####################################################################


fit = model.fit(train[,4:length(train)], ifelse(train[,"loss"]>0, 1, -1), 1)
classes.test = model.predict(fit, test[,4:length(test)], 1)

## rescale them into [0,1] ##
classes.test = (classes.test+1)/2

write.table(data.frame(id = test$id, pd = classes.test), "test_classes_rgf.csv", sep = ";", col.names = F, row.names = F, quote = F)

## add ids with very low pd ##
classes.test.full = rbind(test.id.certain.default,
                          data.frame(id = test$id, pd = classes.test))
write.table(classes.test.full, "test_classes_full.csv", sep = ";", col.names = F, row.names = F, quote = F)
