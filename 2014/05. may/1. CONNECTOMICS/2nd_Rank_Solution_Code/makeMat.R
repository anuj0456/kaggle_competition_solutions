###libraries
require(R.matlab)

###Here goes your path
mypath<-"C:/Users/ildefons/vrije/ildefons"

###generate .mat files
fname<-file.path(mypath,"fluorescence_normal-1.txt")
data.org<-read.csv(fname)
fname<-file.path(mypath,"orgn1.mat")
writeMat(fname, org=as.matrix(data.org))

fname<-file.path(mypath,"fluorescence_normal-2.txt")
data.org<-read.csv(fname)
fname<-file.path(mypath,"orgn2.mat")
writeMat(fname, org=as.matrix(data.org)) 

fname<-file.path(mypath,"fluorescence_valid.txt")
data.org<-read.csv(fname)
fname<-file.path(mypath,"orgvalid.mat")
writeMat(fname, org=as.matrix(data.org)) 

fname<-file.path(mypath,"fluorescence_test.txt")
data.org<-read.csv(fname)
fname<-file.path(mypath,"orgtest.mat")
writeMat(fname, org=as.matrix(data.org))  