###path
mypath<-"C:/Users/ildefons/vrije/ildefons"

###INIT MATLAB SERVER

require(R.matlab)

matlab <- Matlab()
matlab$startServer()                ### wait until the matlab server is up (you will see a matlab window popping up)
isOpen <- open(matlab)
if (!isOpen)
  throw("MATLAB server is not running: waited 30 seconds.")

evaluate(matlab, "addpath(genpath('C:/Users/ildefons/vrije/ildefons'))")           ####this adds the path of the ND code



##############Features for normal-1

###load connection matrix
fname.con<-file.path(mypath,"network_normal-1.txt")
data.con<-read.csv(fname.con)

###build connection matrix
M<-1000
con.matrix<-matrix(nrow=M,ncol=M)
con.matrix[]<-0
for(i in 1:M) {
	for(j in 1:M) {
		posi<-which(data.con[,1]==i)
		posj<-which(data.con[,2]==j)
		pos<-intersect(posi,posj)
		if(length(pos)>0 && data.con[pos[1],3]==1) {
			con.matrix[i,j]<-1
		}
	}
}
con.matrix.n1<-con.matrix

###build features
fname<-file.path(mypath,"diff2n1a40b15csv.csv")
data.diff2<-read.csv(fname,header=F)

th1v<-c(0.060, 0.065, 0.070, 0.075, 0.080, 0.085, 0.090, 0.100, 0.110, 0.120, 0.130, 0.140, 0.150, 0.160, 0.170, 0.180)
th2v<-c(25,50,75,100,150,200,250,300,350,400,450, 500,550,600,650,700,750, 800)
NN<-length(th1v)*length(th2v)
score2.extended<-list()
pp<-1
for(th1 in th1v) {

	for(th2 in th2v) {

		data.diff2<-as.matrix(data.diff2)
		data.diff3<-data.diff2

		data.diff3[data.diff3<th1]<-0
		datax<-data.diff3
		datax[datax>0]<-1

		v2<-rowSums(datax)
		
		posnots<-which(v2>th2)
		aux<-data.diff3[-posnots,]

		score2<-cor(aux)
		diag(score2)<-0

		setVariable(matlab, score2=score2)
		evaluate(matlab, "out=ND(score2)")
		ret <- getVariable(matlab, c("out"))
		score2nd<-ret[[1]]
		
		score2.extended[[pp]]<-score2
		pp<-pp+1
		score2.extended[[pp]]<-score2nd
		pp<-pp+1
		print(th2)
	}
	print(th1)
}

score2.extended.n1<-score2.extended

fname<-file.path(mypath,"featuresn1plus22.RData")
save(	score2.extended.n1,
	con.matrix.n1,
	th1v,th2v,
	file=fname)

###################### normal-2

###load connection matrix
fname.con<-file.path(mypath,"network_normal-2.txt")
data.con<-read.csv(fname.con)

###build connection matrix
M<-1000
con.matrix<-matrix(nrow=M,ncol=M)
con.matrix[]<-0
for(i in 1:M) {
	for(j in 1:M) {
		posi<-which(data.con[,1]==i)
		posj<-which(data.con[,2]==j)
		pos<-intersect(posi,posj)
		if(length(pos)>0 && data.con[pos[1],3]==1) {
			con.matrix[i,j]<-1
		}
	}
}
con.matrix.n2<-con.matrix

fname<-file.path(mypath,"diff2n2a40b15csv.csv")
data.diff2<-read.csv(fname,header=F)

th1v<-c(0.060, 0.065, 0.070, 0.075, 0.080, 0.085, 0.090, 0.100, 0.110, 0.120, 0.130, 0.140, 0.150, 0.160, 0.170, 0.180)
th2v<-c(25,50,75,100,150,200,250,300,350,400,450, 500,550,600,650,700,750, 800)
NN<-length(th1v)*length(th2v)
score2.extended<-list()
pp<-1
for(th1 in th1v) {

	for(th2 in th2v) {

		data.diff2<-as.matrix(data.diff2)
		data.diff3<-data.diff2

		data.diff3[data.diff3<th1]<-0
		datax<-data.diff3
		datax[datax>0]<-1

		v2<-rowSums(datax)
		
		posnots<-which(v2>th2)
		aux<-data.diff3[-posnots,]

		score2<-cor(aux)
		diag(score2)<-0

		setVariable(matlab, score2=score2)
		evaluate(matlab, "out=ND(score2)")
		ret <- getVariable(matlab, c("out"))
		score2nd<-ret[[1]]
		
		score2.extended[[pp]]<-score2
		pp<-pp+1
		score2.extended[[pp]]<-score2nd
		pp<-pp+1
		print(th2)
	}
	print(th1)
}

score2.extended.n2<-score2.extended

fname<-file.path(mypath,"featuresn2plus22.RData")
save(	score2.extended.n2,
	con.matrix.n2,
	th1v,
	th2v,
	file=fname)

#########################################valid

fname<-file.path(mypath,"diff2valida40b15csv.csv")
data.diff2<-read.csv(fname,header=F)

th1v<-c(0.060, 0.065, 0.070, 0.075, 0.080, 0.085, 0.090, 0.100, 0.110, 0.120, 0.130, 0.140, 0.150, 0.160, 0.170, 0.180)
th2v<-c(25,50,75,100,150,200,250,300,350,400,450, 500,550,600,650,700,750, 800)
NN<-length(th1v)*length(th2v)
score2.extended<-list()
pp<-1
for(th1 in th1v) {

	for(th2 in th2v) {

		data.diff2<-as.matrix(data.diff2)
		data.diff3<-data.diff2

		data.diff3[data.diff3<th1]<-0
		datax<-data.diff3
		datax[datax>0]<-1

		v2<-rowSums(datax)
		
		posnots<-which(v2>th2)
		aux<-data.diff3[-posnots,]

		score2<-cor(aux)
		diag(score2)<-0

		setVariable(matlab, score2=score2)
		evaluate(matlab, "out=ND(score2)")
		ret <- getVariable(matlab, c("out"))
		score2nd<-ret[[1]]
		
		score2.extended[[pp]]<-score2
		pp<-pp+1
		score2.extended[[pp]]<-score2nd
		pp<-pp+1
		print(th2)
	}
	print(th1)
}

score2.extended.valid<-score2.extended

fname<-file.path(mypath,"featuresvalidplus22.RData")
save(	score2.extended.valid,
	file=fname)

##############################test

fname<-file.path(mypath,"diff2testa40b15csv.csv")
data.diff2<-read.csv(fname,header=F)

th1v<-c(0.060, 0.065, 0.070, 0.075, 0.080, 0.085, 0.090, 0.100, 0.110, 0.120, 0.130, 0.140, 0.150, 0.160, 0.170, 0.180)
th2v<-c(25,50,75,100,150,200,250,300,350,400,450, 500,550,600,650,700,750, 800)
NN<-length(th1v)*length(th2v)
score2.extended<-list()
pp<-1
for(th1 in th1v) {

	for(th2 in th2v) {

		data.diff2<-as.matrix(data.diff2)
		data.diff3<-data.diff2

		data.diff3[data.diff3<th1]<-0
		datax<-data.diff3
		datax[datax>0]<-1

		v2<-rowSums(datax)
		
		posnots<-which(v2>th2)
		aux<-data.diff3[-posnots,]

		score2<-cor(aux)
		diag(score2)<-0

		setVariable(matlab, score2=score2)
		evaluate(matlab, "out=ND(score2)")
		ret <- getVariable(matlab, c("out"))
		score2nd<-ret[[1]]
		
		score2.extended[[pp]]<-score2
		pp<-pp+1
		score2.extended[[pp]]<-score2nd
		pp<-pp+1
		print(th2)
	}
	print(th1)
}

score2.extended.test<-score2.extended

fname<-file.path(mypath,"featurestestplus22.RData")
save(	score2.extended.test,
	file=fname)


