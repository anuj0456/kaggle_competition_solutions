###path
mypath<-"C:/Users/ildefons/vrije/ildefons"

require(randomForest)
require(gbm)

###load models
fname<-file.path(mypath,"mymodels.RData")
load(fname)

###load valid and test normalized features
fname<-file.path(mypath,"validnorm.RData")
load(fname)
fname<-file.path(mypath,"testnorm.RData")
load(fname)

ycol<-ncol(valid.norm)
range<-37:(ncol(valid.norm)-2)

X.valid<-cbind(valid.norm[,range])
X.test<-cbind(test.norm[,range])

colnames(X.valid)<-paste("v",as.character(1:ncol(X.valid)),sep="")
colnames(X.test)<-colnames(X.valid)

valid.gbm<-data.frame(cbind(X.valid,y=valid.norm[,ycol]))
test.gbm<-data.frame(cbind(X.test,y=test.norm[,ycol]))

fname<-file.path(mypath,"mymodels.RData")
load(fname)

###rf

M<-1000

prf1.valid<-predict(rf1,data.frame(X.valid))
mprf1.valid<-matrix(as.vector(prf1.valid),ncol=M,nrow=M)
diag(mprf1.valid)<-0

prf2.valid<-predict(rf2,data.frame(X.valid))
mprf2.valid<-matrix(as.vector(prf2.valid),ncol=M,nrow=M)
diag(mprf2.valid)<-0

prf1.test<-predict(rf1,data.frame(X.test))
mprf1.test<-matrix(as.vector(prf1.test),ncol=M,nrow=M)
diag(mprf1.test)<-0

prf2.test<-predict(rf2,data.frame(X.test))
mprf2.test<-matrix(as.vector(prf2.test),ncol=M,nrow=M)
diag(mprf2.test)<-0

###gbm

pgbm1.valid <- predict.gbm(object=gbm1,newdata=valid.gbm,300)
mpgbm1.valid<-matrix(as.vector(pgbm1.valid),ncol=M,nrow=M)
diag(mpgbm1.valid)<-0

pgbm2.valid <- predict.gbm(object=gbm2,newdata=valid.gbm,300)
mpgbm2.valid<-matrix(as.vector(pgbm2.valid),ncol=M,nrow=M)
diag(mpgbm2.valid)<-0

pgbm1.test <- predict.gbm(object=gbm1,newdata=test.gbm,300)
mpgbm1.test<-matrix(as.vector(pgbm1.test),ncol=M,nrow=M)
diag(mpgbm1.test)<-0

pgbm2.test <- predict.gbm(object=gbm2,newdata=test.gbm,300)
mpgbm2.test<-matrix(as.vector(pgbm2.test),ncol=M,nrow=M)
diag(mpgbm2.test)<-0

####create solutions

fname<-file.path(mypath,"sampleSubmission.csv")
bk<-read.csv(fname,header=TRUE)

myvalid<-(mprf1.valid+mprf2.valid+mpgbm1.valid+mpgbm2.valid)/4
mytest<-(mprf1.test+mprf2.test+mpgbm1.test+mpgbm2.test)/4

myvalid<-abs(min(myvalid))+myvalid
myvalid<-myvalid/max(myvalid)
mytest<-abs(min(mytest))+mytest
mytest<-mytest/max(mytest)

scores<-c(as.vector(t(as.matrix(myvalid))),as.vector(t(as.matrix(mytest))))
bk[,2]<-scores

fname<-file.path(mypath,"submissionref.csv")
write.csv(bk, file=fname, quote = FALSE, sep = ",",row.names = FALSE)

