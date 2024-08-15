#***************************************************************************************
#
#	PAKDD-ASUS Kaggle Competition, By Shize Su, ss5vq@virginia.edu, 2014
#
#***************************************************************************************



#***************************************************************************************
#
#	Part I Code: generate monthly repair data in May 2009-Dec 2009 for 
#                  each module-component. Output as "trainForExcelAnalysis.csv" file.
#
#***************************************************************************************

library(plyr)

# Read Data
train <- read.csv("RepairTrain.csv", header=TRUE)

# Choose a better name for attribute "year/month(repair)"
names(train)[4] <- "year_month_repair"

# Convert year_month_repair variable
repair_train <- transform(train, 
                          year_repair  = as.integer(substr(year_month_repair, 1, 4)), 
                          month_repair = as.integer(substr(year_month_repair, 6, 7)))

repair_train <- transform(repair_train, 
                          year_month_repair = year_repair * 100 + month_repair)


# Only use May 2009-Dec 2009 monthly repair data
repair_train <- subset(repair_train, year_month_repair >= 200905)


# Aggragate individual repair logs to get monthly repair for each module_component
repair_agg <- aggregate(number_repair ~ module_category + component_category +
                                    year_month_repair, repair_train, sum)

# Add module-component ID variable
repair_agg$mcID<-paste0(repair_agg[,1],'_',repair_agg[,2],sep='')
repair_agg<-repair_agg[,c(5,1:4)]

#Sort
repair_agg.sort <- repair_agg[with(repair_agg, order(mcID,year_month_repair)), ]

repair_agg.sort[1,]

#Generate traincomp.csv file, basically, it transform those 8 months monthly repair data in repair_agg.sort into onw row 
#for each module-component, substitute 0 for missing monthly repair data, and compute the sum of 8 month repair data

traincomp<- repair_agg.sort[ !duplicated( repair_agg.sort$mcID, fromLast=FALSE ) , ]

traincomp$mon5Repair<-0*traincomp[,5]
traincomp$mon6Repair<-0*traincomp[,5]
traincomp$mon7Repair<-0*traincomp[,5]
traincomp$mon8Repair<-0*traincomp[,5]
traincomp$mon9Repair<-0*traincomp[,5]
traincomp$mon10Repair<-0*traincomp[,5]
traincomp$mon11Repair<-0*traincomp[,5]
traincomp$mon12Repair<-0*traincomp[,5]
traincomp$Repairsum<-0*traincomp[,5]
traincomp<-traincomp[,-5]

m=dim(repair_agg.sort)[1]
tempindex=1
for (i in 1:m)
{
if(repair_agg.sort[i,1]==traincomp[tempindex,1]){
      traincomp[tempindex,(repair_agg.sort[i,4]-200905+5)]<-repair_agg.sort[i,5]
   }
else{
      tempindex<-tempindex+1
      traincomp[tempindex,(repair_agg.sort[i,4]-200905+5)]<-repair_agg.sort[i,5]
   }

}

n=dim(traincomp)[1]
for (i in 1:n)
{
  traincomp[i,13]=sum(traincomp[i,5:12])
}

#Rename variable name to reduce confusing
names(traincomp)[4]<-"year_repair"
traincomp[,4]<-traincomp[,4]*0+2009

#Sort based on Repairsum for output file
traincomp.sort <- traincomp[with(traincomp, order(Repairsum,decreasing = TRUE)), ]

#This trainForExcelAnalysis.csv file is used for future repair data pattern analysis in Excel software
write.csv(traincomp.sort,"trainForExcelAnalysis.csv",row.names=FALSE)


#***************************************************************************************
#
#	Part II Code: generate prediction file "predsubmit.csv". 
#                   Basic idea is to use piecewise exponential decay function for prediction, 
#                   whose parameters are tuned based on "trainForExcelAnalysis.csv" file last 8 monthly repair 
#                   rate pattern analysis (for each module-component) as well as leaderboard feedback.                
#
#***************************************************************************************

trainfinal<-traincomp
pred <- read.csv("Output_TargetID_Mapping.csv", header=TRUE)

# Add variable module-component ID "mcID"
pred$mcID<-paste0(pred[,1],'_',pred[,2],sep='')

# Add variable id for submission file requirement
pred$id<-0*pred[,4]
m=dim(pred)[1]
for (i in 1:m)
{
  pred[i,6]=i
}

#Declare and initialize predsubmit
predsubmit<-pred[,c(6,4)]
predsubmit$target<-0*predsubmit[,2]
predsubmit<-predsubmit[,c(1,3)]
summary(predsubmit)



#predfinal is intermediate data which will finally be used to compute predsubmit
predfinal<- pred[ !duplicated( pred$mcID, fromLast=FALSE ) , ]
predfinal<-predfinal[,c(5,1:2,6,3)]
predfinal[1,]
summary(predfinal)

#Initialize 0 for Jan 2010-Jul 2011 (19 months) monthly repair prediction
predfinal$p1<-0*predfinal[,4]
predfinal$p2<-0*predfinal[,4]
predfinal$p3<-0*predfinal[,4]
predfinal$p4<-0*predfinal[,4]
predfinal$p5<-0*predfinal[,4]
predfinal$p6<-0*predfinal[,4]
predfinal$p7<-0*predfinal[,4]
predfinal$p8<-0*predfinal[,4]
predfinal$p9<-0*predfinal[,4]
predfinal$p10<-0*predfinal[,4]
predfinal$p11<-0*predfinal[,4]
predfinal$p12<-0*predfinal[,4]
predfinal$p13<-0*predfinal[,4]
predfinal$p14<-0*predfinal[,4]
predfinal$p15<-0*predfinal[,4]
predfinal$p16<-0*predfinal[,4]
predfinal$p17<-0*predfinal[,4]
predfinal$p18<-0*predfinal[,4]
predfinal$p19<-0*predfinal[,4]

# Add a new variable "tag" to denote whether this module-component was observed in the 8 months training data, if yes tag=1, otherwise tag=0
names(predfinal)[5]="tag"
#Initialize tag to be 0
predfinal[,5]=0*predfinal[,5]

#Figure out the value of tag for each module component
m=dim(trainfinal)[1]
tempfirst=1;
for (i in 1:m)
{
for (j in 0:20){
   if(trainfinal[i,1]==predfinal[tempfirst+j,1])
      {predfinal[tempfirst+j,5]<-1#set tag=1
       tempfirst=tempfirst+j
       break;}
}
}


#Sort predfinal based on tag value, such that module-component order in predfinal and trainfinal will match
predfinal <- predfinal[with(predfinal, order(tag,decreasing = TRUE)), ]


#Now we can look at the structure of predfinal,trainfinal and predsubmit
predfinal[20,]
trainfinal[20,]
predsubmit[20,]
 
#Piecewise exponential decay function for repair rate prediction
m<-dim(trainfinal)[1]
for(i in 1:m)
 {
   #for those module-components whose sum of repair amount <=5 in May 2009-Dec 2009,
   #I just predict repair amount=0 in Jan 2010-Jul 2011
   if(trainfinal[i,13]>5&trainfinal[i,13]<10){
     decay1=0.9
     for(j in 6:24){
        predfinal[i,j]<-(1/3.0*(trainfinal[i,10]+trainfinal[i,11]+trainfinal[i,12])*decay1^(j-5))
     }
   }
   
   else if(trainfinal[i,13]>3000){
      if(trainfinal[i,13]==11788){
          decay=(0.7*trainfinal[i,12]/trainfinal[i,11]+0.3*trainfinal[i,11]/trainfinal[i,10])
          for(j in 6:24){
           if(j==6){
             predfinal[i,j]<-trainfinal[i,12]*decay  
            }
           else if(j==7){
             decay=0.85
             predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))}
           else if(j<13)
           {decay=0.995
             predfinal[i,j]<-(predfinal[i,j-1]*decay)}
           else if(j<17)
           {decay=0.885
            predfinal[i,j]<-(predfinal[i,j-1]*decay)}
            else if(j<20)
           {decay=0.84
            predfinal[i,j]<-(predfinal[i,j-1]*decay)}
           else
           {decay=0.87
             predfinal[i,j]<-(predfinal[i,j-1]*decay)}
          }
       }
        else if(trainfinal[i,13]==10044){
           decay=(0.7*trainfinal[i,12]/trainfinal[i,11]+0.3*trainfinal[i,11]/trainfinal[i,10])
           for(j in 6:24){
             if(j==6){
               predfinal[i,j]<-trainfinal[i,12]*decay  
             }
             if(j==7){
               predfinal[i,j]<-predfinal[i,j-1]*min(max(decay,0.75),decay+0.05)
             }
             if(j>7)
             {decay=0.68
              predfinal[i,j]<-(predfinal[i,j-1]*decay)}
             if(j>9)
             {decay=0.72
              predfinal[i,j]<-(predfinal[i,j-1]*decay)}
            }
        }


     else if(trainfinal[i,13]==8471){
          decay=0.96 
          for(j in 6:24){
             if(j==6){
             predfinal[i,j]<-trainfinal[i,12]*decay  
             }
           else if(j<14)
            {decay=0.965
             predfinal[i,j]<-(predfinal[i,j-1]*decay)}
           else if(j<15)
            {decay=0.94
             predfinal[i,j]<-(predfinal[i,j-1]*decay)}
           else if(j<18)
            {decay=0.9
             predfinal[i,j]<-(predfinal[i,j-1]*decay)}
           else if(j<20)
            {decay=0.85
             predfinal[i,j]<-(predfinal[i,j-1]*decay)}
           else
            {decay=0.83
             predfinal[i,j]<-(predfinal[i,j-1]*decay)}
          }
        }
    else if(trainfinal[i,13]==6239){
        decay=(0.7*trainfinal[i,12]/trainfinal[i,11]+0.3*trainfinal[i,11]/trainfinal[i,10])
        for(j in 6:24){
         if(j==6){
         predfinal[i,j]<-trainfinal[i,12]*decay  
         }
         else if(j<10){
         decay=0.62
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else{
         decay=0.55
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
       }
     }

    else if(trainfinal[i,13]==4526){
        decay=(0.7*trainfinal[i,12]/trainfinal[i,11]+0.3*trainfinal[i,11]/trainfinal[i,10])
        for(j in 6:24){
         if(j==6){
         predfinal[i,j]<-trainfinal[i,12]*decay  
         }
         else if(j<9)
         {decay=0.75
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<12)
         {decay=0.8
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<14)
         {decay=0.92
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<18)
         {decay=0.96
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<20)
         {decay=0.9
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else
         {decay=0.88
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
       }
     }
    else if(trainfinal[i,13]==4167){
        decay=0.9 
        for(j in 6:24){
         if(j==6){
         predfinal[i,j]<-trainfinal[i,12]*decay  
         }
         else if(j==7)
         {decay=0.96
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<18)
         {decay=0.965
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<20)
         {decay=0.92
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else
         {decay=0.885
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
       }
     }
    else if(trainfinal[i,13]==3380){
       decay=(0.7*trainfinal[i,12]/trainfinal[i,11]+0.3*trainfinal[i,11]/trainfinal[i,10])
       for(j in 6:24){
         if(j==6){
         predfinal[i,j]<-trainfinal[i,12]*decay  
         }
         else if(j<9)
         {decay=0.75
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<11)
         {decay=0.8
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<18)
         {decay=0.82
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else
         {decay=0.85
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
       }
     }

    else if(trainfinal[i,13]==3120){
        decay=0.75 
        for(j in 6:24){
         if(j==6){
         predfinal[i,j]<-trainfinal[i,12]*decay  
         }
         else if(j==7)
         {decay=0.85
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<10)
         {decay=0.9
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<12) 
         {decay=0.93
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else
         {decay=0.94
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
       }
     }

   }
 
   else if(trainfinal[i,13]>1370){
     if(trainfinal[i,13]==1733){
       decay=0.96   
       for(j in 6:24){
         if(j<12){
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))}
         else if(j<18){
         decay=0.92
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else {
         decay=0.89
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
       }
     }
     if(trainfinal[i,13]==1380){
        decay=0.983   
        for(j in 6:24){
         if(j<17){
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))}
         else if(j<20) {
         decay=0.93
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else {
         decay=0.85
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
       }
     }
   }
 
   else if(trainfinal[i,13]>=142){
     if(trainfinal[i,13]==1360){
       decay=0.975   
       for(j in 6:24){
         if(j<16){
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))}
         else if(j<18){
         decay=0.95
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<21){
         decay=0.92
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else {
         decay=0.88
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
      }
    }
     else if(trainfinal[i,13]==1060){
       decay=0.72   
       for(j in 6:24){
         if(j<8){
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))}
         else {
         decay=0.74
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
      }
    }
     else if(trainfinal[i,13]==885){
       decay=0.8   
       for(j in 6:24){
         if(j<7){
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))}
         else if(j<10){
         decay=0.9
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<18){
         decay=0.93
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else {
         decay=0.88
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
      }
    }
     else if(trainfinal[i,13]==685){
       decay=0.985   
       for(j in 6:24){
         if(j<15){
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))}
         else if(j<18){
         decay=0.92
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else {
         decay=0.84
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
      }
    }

     else if(trainfinal[i,13]==609){
       decay=0.8   
       for(j in 6:24){
         if(j<8){
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))}
         else if(j<10){
         decay=0.7
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else {
         decay=0.65
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
      }
    }
     else if(trainfinal[i,13]==569){
       decay=0.75   
       for(j in 6:24){
         if(j<7){
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))}
         else if(j<8){
         decay=0.8
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<10){
         decay=0.85
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else if(j<18){
         decay=0.9
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else {
         decay=0.85
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
      }
    }
     else if(trainfinal[i,13]==508){
       decay=0.94   
       for(j in 6:24){
         if(j<8){
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))}
         else if(j<18){
         decay=0.95
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
         else {
         decay=0.9#0.92
         predfinal[i,j]<-(predfinal[i,j-1]*decay)}
      }
    }

     else{
       decay=min(0.9,0.7*trainfinal[i,12]/trainfinal[i,11]+0.3*trainfinal[i,11]/trainfinal[i,10])
       for(j in 6:24){
         if(j>7)
         {decay=max(decay,0.8)}
         if(j>9)
         {decay=0.85}
         if(j>11)
         {decay=max(decay,0.90)}
         if(j>18)
         {decay=max(decay,0.91)}
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))
       }
     }  
   }


   else if(trainfinal[i,13]>=64){
     if(trainfinal[i,12]<8){
       decay=min(0.9,0.7*trainfinal[i,12]/trainfinal[i,11]+0.3*trainfinal[i,11]/trainfinal[i,10])
       for(j in 6:24){
         if(j>7)
         {decay=max(decay,0.8)}
         if(j>9)
         {decay=0.85}
         if(j>11)
         {decay=max(decay,0.90)}
         predfinal[i,j]<-(trainfinal[i,12]*decay^(j-5))
         }
     }
     else{
      decay=min(0.95,0.7*trainfinal[i,12]/trainfinal[i,11]+0.3*trainfinal[i,11]/trainfinal[i,10])
       for(j in 6:24){
         if(j>8)
         {decay=max(decay,0.9)}
         predfinal[i,j]<-(1/3.0*(trainfinal[i,10]+trainfinal[i,11]+trainfinal[i,12]))*decay^(j-5)
         }
     }
   }
 
   else if(trainfinal[i,13]>=42){
     {
     decay=min(0.95,0.5*trainfinal[i,12]/trainfinal[i,11]+0.5*trainfinal[i,11]/trainfinal[i,10])
     for(j in 6:24){
         if(j>7)
         {decay=max(decay,0.9)}
          predfinal[i,j]<-trainfinal[i,12]*decay^(j-5)
        }
    }
   }
 
   else if(trainfinal[i,13]>=10){
     {
     decay=0.9
     for(j in 6:24){
        predfinal[i,j]<-(1/3.0*(trainfinal[i,10]+trainfinal[i,11]+trainfinal[i,12]))*decay^(j-5)
        }
      }
     }


   if(trainfinal[i,13]==885||trainfinal[i,13]==289||trainfinal[i,13]==220||trainfinal[i,13]==209||trainfinal[i,13]==442){
      decay=0.85
      for(j in 18:24){
         if(j==18){
         predfinal[i,j]<-predfinal[i,j-1]*decay*0.7}
         else{
         predfinal[i,j]<-predfinal[i,j-1]*decay}
      }
   }

   if(trainfinal[i,13]==115||trainfinal[i,13]==103||trainfinal[i,13]==78||trainfinal[i,13]==60||trainfinal[i,13]==88||trainfinal[i,13]==133||trainfinal[i,13]==50){
      decay=0.85
      for(j in 18:24){
         if(j==18){
         predfinal[i,j]<-predfinal[i,j-1]*decay*0.7}
         else{
         predfinal[i,j]<-predfinal[i,j-1]*decay}
      }
   }
    
    #Zero out the prediction if computed predicted repair by exponential decay function is small
    for(j in 6:24){
        if((predfinal[i,j]<0.7&j>10)||predfinal[i,j]<0.3){
            predfinal[i,j]<-0}
    }
   
}

m=dim(trainfinal)[1]
m
for(i in 1:m)
{
   for(j in 0:18){
      predsubmit[(predfinal[i,4]+j),2]<-predfinal[i,6+j]}
}

#This "predsubmit.csv" file is the prediction output file which can be submitted to Kaggle 
#directly without future processing
write.csv(predsubmit,"predsubmit.csv",row.names=FALSE)



