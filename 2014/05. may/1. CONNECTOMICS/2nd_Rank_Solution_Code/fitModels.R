###path
mypath<-"C:/Users/ildefons/vrije/ildefons"

require(randomForest)
require(gbm)

#####################################
#normal-1
#####################################
fname<-file.path(mypath,"n1norm.RData")
load(fname)

train.norm<-n1.norm

ycol<-ncol(train.norm)
range<-37:(ncol(train.norm)-2)

X.train<-cbind(train.norm[,range])

colnames(X.train)<-paste("v",as.character(1:ncol(X.train)),sep="")

myrows<-which(train.norm[,ycol]==1)
other<-which(train.norm[,ycol]==0)
set.seed(1234)
rows0<-sample(other,50000)
myrows<-c(myrows,rows0)

library(randomForest)
set.seed(1234)
rf1<-randomForest(x=X.train[myrows,],y=train.norm[myrows,ycol],importance=FALSE, ntree=400, do.trace=T,nodesize=450)

train.gbm<-data.frame(cbind(X.train[myrows,],y=train.norm[myrows,ycol]))

#Model: gbm
set.seed(1234)
GBM_NTREES = 400
GBM_SHRINKAGE = 0.05
GBM_DEPTH = 6
GBM_MINOBS = 400
#build the GBM model
library(gbm)
set.seed(1234)
gbm1 <- gbm(y~.,
	data=train.gbm,
	distribution = "gaussian",
	n.trees = GBM_NTREES,
	shrinkage = GBM_SHRINKAGE,
	interaction.depth = GBM_DEPTH,
	n.minobsinnode = GBM_MINOBS,
	verbose = TRUE,
	#cv.folds = 1,
	bag.fraction = 0.5,   # subsampling fraction, 0.5 is probably best
      train.fraction = 1)

#####################################
#normal-2
#####################################
fname<-file.path(mypath,"n2norm.RData")
load(fname)

train.norm<-n2.norm

ycol<-ncol(train.norm)
range<-37:(ncol(train.norm)-2)

X.train<-cbind(train.norm[,range])

colnames(X.train)<-paste("v",as.character(1:ncol(X.train)),sep="")

myrows<-which(train.norm[,ycol]==1)
other<-which(train.norm[,ycol]==0)
set.seed(1234)
rows0<-sample(other,50000)
myrows<-c(myrows,rows0)

library(randomForest)
set.seed(1234)
rf2<-randomForest(x=X.train[myrows,],y=train.norm[myrows,ycol],importance=FALSE, ntree=400, do.trace=T,nodesize=450)

train.gbm<-data.frame(cbind(X.train[myrows,],y=train.norm[myrows,ycol]))

#Model: gbm
set.seed(1234)
GBM_NTREES = 400
GBM_SHRINKAGE = 0.05
GBM_DEPTH = 6
GBM_MINOBS = 400
#build the GBM model
library(gbm)
set.seed(1234)
gbm2 <- gbm(y~.,
	data=train.gbm,
	distribution = "gaussian",
	n.trees = GBM_NTREES,
	shrinkage = GBM_SHRINKAGE,
	interaction.depth = GBM_DEPTH,
	n.minobsinnode = GBM_MINOBS,
	verbose = TRUE,
	#cv.folds = 1,
	bag.fraction = 0.5,   # subsampling fraction, 0.5 is probably best
      train.fraction = 1)

fname<-file.path(mypath,"mymodels.RData")
save(	rf1,
	gbm1,
	rf2,
	gbm2,
	file=fname)

