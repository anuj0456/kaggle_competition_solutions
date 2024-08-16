###path
mypath<-"C:/Users/ildefons/vrije/ildefons"

###############normal-1

fname<-file.path(mypath,"featuresn1plus22.RData")
load(fname)

myl<-score2.extended.n1
mym<-con.matrix.n1

feas<-cbind(as.vector(myl[[2]]) )

myseq<-seq(4,length(myl),2)
for(i in myseq) {
	feas<-cbind( 	feas, 
				as.vector(myl[[i]]) )

}

M<-1000

mym.sim<-mym
for(i in 1:(M-1)){
	for(j in (i+1):M) {
		if(	mym.sim[i,j]==1 ||
			mym.sim[j,i]==1) {
			mym.sim[i,j]=1
			mym.sim[j,i]=1
		} 
	}
}

feas<-cbind( feas, as.vector(mym),as.vector(mym.sim) )

all<-feas

train.norm<-(all[,1]-mean(all[,1]))/sd(all[,1])

for(i in 2:(ncol(all)-2)) {
	train.norm<-cbind(train.norm,	(all[,i]-mean(all[,i]))/sd(all[,i]))
}

train.norm<-cbind(train.norm,	all[,ncol(all)-1],all[,ncol(all)])

n1.norm<-train.norm

fname<-file.path(mypath,"n1norm.RData")
save(n1.norm,file=fname)

###############normal-2

fname<-file.path(mypath,"featuresn2plus22.RData")
load(fname)

myl<-score2.extended.n1
mym<-con.matrix.n1

feas<-cbind(as.vector(myl[[2]]) )

myseq<-seq(4,length(myl),2)
for(i in myseq) {
	feas<-cbind( 	feas, 
				as.vector(myl[[i]]) )

}

M<-1000

mym.sim<-mym
for(i in 1:(M-1)){
	for(j in (i+1):M) {
		if(	mym.sim[i,j]==1 ||
			mym.sim[j,i]==1) {
			mym.sim[i,j]=1
			mym.sim[j,i]=1
		} 
	}
}

feas<-cbind( feas, as.vector(mym),as.vector(mym.sim) )

all<-feas

train.norm<-(all[,1]-mean(all[,1]))/sd(all[,1])

for(i in 2:(ncol(all)-2)) {
	train.norm<-cbind(train.norm,	(all[,i]-mean(all[,i]))/sd(all[,i]))
}

train.norm<-cbind(train.norm,	all[,ncol(all)-1],all[,ncol(all)])

n2.norm<-train.norm

fname<-file.path(mypath,"n2norm.RData")
save(n2.norm,file=fname)

###################valid

fname<-file.path(mypath,"featuresvalidplus22.RData")
load(fname)

myl<-score2.extended.valid
con.matrix.valid<-matrix(nrow=1000,ncol=1000)
con.matrix.valid[]<-0
mym<-con.matrix.valid

feas<-cbind(as.vector(myl[[2]]) )

myseq<-seq(4,length(myl),2)
for(i in myseq) {
	feas<-cbind( 	feas, 
				as.vector(myl[[i]]) )

}

M<-1000

mym.sim<-mym
for(i in 1:(M-1)){
	for(j in (i+1):M) {
		if(	mym.sim[i,j]==1 ||
			mym.sim[j,i]==1) {
			mym.sim[i,j]=1
			mym.sim[j,i]=1
		} 
	}
}


feas<-cbind( feas, as.vector(mym),as.vector(mym.sim) )

all<-feas

train.norm<-(all[,1]-mean(all[,1]))/sd(all[,1])

for(i in 2:(ncol(all)-2)) {
	train.norm<-cbind(train.norm,	(all[,i]-mean(all[,i]))/sd(all[,i]))
}

train.norm<-cbind(train.norm,	all[,ncol(all)-1],all[,ncol(all)])

valid.norm<-train.norm

fname<-file.path(mypath,"validnorm.RData")
save(valid.norm,file=fname)

###################test

fname<-file.path(mypath,"featurestestplus22.RData")
load(fname)

myl<-score2.extended.test
con.matrix.test<-matrix(nrow=1000,ncol=1000)
con.matrix.test[]<-0
mym<-con.matrix.test

feas<-cbind(as.vector(myl[[2]]) )

myseq<-seq(4,length(myl),2)
for(i in myseq) {
	feas<-cbind( 	feas, 
				as.vector(myl[[i]]) )

}

M<-1000

mym.sim<-mym
for(i in 1:(M-1)){
	for(j in (i+1):M) {
		if(	mym.sim[i,j]==1 ||
			mym.sim[j,i]==1) {
			mym.sim[i,j]=1
			mym.sim[j,i]=1
		} 
	}
}


feas<-cbind( feas, as.vector(mym),as.vector(mym.sim) )

all<-feas

train.norm<-(all[,1]-mean(all[,1]))/sd(all[,1])

for(i in 2:(ncol(all)-2)) {
	train.norm<-cbind(train.norm,	(all[,i]-mean(all[,i]))/sd(all[,i]))
}

train.norm<-cbind(train.norm,	all[,ncol(all)-1],all[,ncol(all)])

test.norm<-train.norm

fname<-file.path(mypath,"testnorm.RData")
save(test.norm,file=fname)




