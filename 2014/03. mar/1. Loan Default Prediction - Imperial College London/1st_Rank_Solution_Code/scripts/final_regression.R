library("plyr")
library("foreach")
library("gbm")
library("snow")
library("doSNOW")
library("verification")
library("reshape2")
library("caret")
library("ROCR")

setwd("../LoanDefault")
mae = function(x,y) { mean(abs(x-y)) }

load("final_data_full.RData")
load("final_golden_features.RData")

## load probability of default for the train and test set ##
classes.train = read.csv("train_classes_full.csv", stringsAsFactors = F, header = F, sep = ";")
classes.test = read.csv("test_classes_full.csv", stringsAsFactors = F, header = F, sep = ";")

colnames(classes.train) = c("id", "pd")
colnames(classes.test) = c("id", "pd")

## create full feature set for regression task ##
## it consists of all golden features and all features of the full data table ##
feature.set = cbind(data[,c("id", "loss","f776", "f777", "f778", "f2", "f4", "f5")], golden.features)
feature.set = cbind(feature.set, data[,!((colnames(data) %in% c("id","loss","f776", "f777", "f778", "f2", "f4", "f5")))])


#######################################################
## find optimal cutoff point for probability of default 
#######################################################



t = merge(classes.train, feature.set[,c("id", "loss")], by = "id", all.x = T)
pred = prediction(t$pd, ifelse(t[,"loss"]>0, 1, 0))
f = performance(pred, 'f')
f1_score = f@y.values[[1]]
cutoff = f@x.values[[1]]

## compute f1 score - should be around 0.958 ##
max(f1_score,na.rm=T)

## get best cutoff point ##
best_cutoff = cutoff[which.max(f1_score)]


## get ids based on the cutoff value ##
## the loss will only be predicted for samples with a probability of default > best_cutoff ##
ids.train.default = classes.train[classes.train$pd > best_cutoff, "id"]

ids.test.default = classes.test[classes.test$pd > best_cutoff, "id"]
ids.test.nodefault = classes.test[classes.test$pd <= best_cutoff, "id"]

## keep only the defaulter ##
train = feature.set[is.na(feature.set$loss) == F & feature.set$id %in% ids.train.default,]
test = feature.set[is.na(feature.set$loss) == T & feature.set$id %in% ids.test.default,]


###############
## predict loss
###############


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


######################
## results for test ##
######################


## model with reg_L2=0.25 ##
model.fit = function(Input, Target, run){
  
  settings = read.table("../LoanDefault/rgf1.2/test/sample/train_regression_025.inp", stringsAsFactors = F)
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


## fit model ##
temp.fit = model.fit(train[,3:length(train)], log1p(train[,"loss"]), 1)

## predict loss for test set ##
forecast_025 = expm1(model.predict(temp.fit, test[,3:length(test)], 1))


## model with reg_L2=0.5 ##
model.fit = function(Input, Target, run){
  
  settings = read.table("../LoanDefault/rgf1.2/test/sample/train_regression_05.inp", stringsAsFactors = F)
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


## fit model ##
temp.fit = model.fit(train[,3:length(train)], log1p(train[,"loss"]), 1)

## predict loss for test set ##
forecast_05 = expm1(model.predict(temp.fit, test[,3:length(test)], 1))


## model with reg_L2=0.75 ##
model.fit = function(Input, Target, run){
  
  settings = read.table("../LoanDefault/rgf1.2/test/sample/train_regression_075.inp", stringsAsFactors = F)
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


## fit model ##
temp.fit = model.fit(train[,3:length(train)], log1p(train[,"loss"]), 1)

## predict loss for test set ##
forecast_075 = expm1(model.predict(temp.fit, test[,3:length(test)], 1))


######################
## combine all results
######################


all.forecasts = rowMeans(cbind(forecast_025, forecast_05, forecast_075))
all.forecasts[all.forecasts<0] = 0
all.forecasts[all.forecasts>100] = 100

result = rbind(data.frame(id = test[,"id"], loss = round(all.forecasts)),
               data.frame(id = ids.test.nodefault, loss = 0))

write.table(result, "final_submission.csv", sep = ",", col.names = T, row.names = F, quote = F)
