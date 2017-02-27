################################################
#Project: Tracking Health And Body             #
#Author: Lander Bodyn                          #
#Date: September 2016                          #
################################################


###################################
#     Read in the data            #
###################################

library("reshape")
library("xlsx")
setwd("/home/lander/Dropbox/Tracking-health-and-body/data")
data.MFP <- read.csv("MyFitnessPal.csv")[,-2]          #MyFitnessPal
data.FN <- read.csv("FitNotes_Export.csv")[,c(1:5)]  #FitNotes
data.GF <- read.csv("Takeout/Fit/Daily Aggregations/Daily Summaries.csv")[,c(1,2,3)] #Google Fit
data.BM <- read.xlsx("body measurements.xlsx", sheetIndex=1)[,c(1:11)] #Body measurements


###################################
#     Transform the data          #
###################################

#### Body Measurements ####
#======================

data.BM <- data.BM[!is.na(data.BM$Date),]

data.BM$bodyfat..kg <- data.BM$weight..kg*data.BM$bodyfat..pct/100
data.BM$ffm..kg <- data.BM$weight..kg*(100 - data.BM$bodyfat..pct)/100

plot(data.BM$weight..kg,pch="*", xlab='Days', lwd=3, col="grey", ann=FALSE, las=2)
par(new=TRUE)
plot(data.BM$ffm..kg,pch="*",ann=FALSE, axes=FALSE,col='blue')
par(new=TRUE)
plot(data.BM$bodyfat..kg,pch="*",ann=FALSE, axes=FALSE,col='red')
#Putting dates in the right format
data.BM$Date <- as.Date(data.BM$Date)


plot(data.BM$weight..kg, data.BM$waterweight..pct,pch="*",col='red')

# MyFitnessPal ####
#======================

#Putting dates in the right format
data.MFP$Date <- as.Date(data.MFP$Date, "%d-%b-%y")

#Splitting myfitnesspal feature "Name" into "Product + ", "Quantity" and "Unit"
names.split <- strsplit(as.character(data.MFP$Name), ", ")
quantity.split <- strsplit(sapply(names.split, function (x) x[2]), " ")
data.MFP$Product <- paste(sapply(names.split, function (x) x[1]),'in',
                          sapply(quantity.split, function (x) x[2]))
data.MFP$Quantity <- as.numeric(sapply(quantity.split, function (x) x[1]))
data.MFP$Name <- NULL

#Restructuring data: Make foods features with values the consumed amount.
#->Putting all consumed foods to same the units?? #Not needed
data.foods <- cast(data.MFP[,c(1,10,11)],Date~Product,sum,value = 'Quantity')

#Later: more exact calculation of nutrients
data.nutrients <- aggregate(. ~ Date, data=data.MFP[,-c(10,11)], FUN=sum)

#Merge nutrients and foods features
data.MFP2 <- merge(data.nutrients,data.foods,by="Date")


#### Google Fit ####
#====================

#Putting dates in the right format
data.GF$Date <- as.Date(data.GF$Date)


#### FitNotes ####
#==================

#Transform data to two features for each training day: daily workload and mean intensity

#Fix date
data.FN$Date <- as.Date(data.FN$Date)

#Calculate workload per set
data.FN$workload <- data.FN$Weight..kgs.*data.FN$Reps

#set multiplier for 1RM calculation
data.FN$multiplier <- 0.86
data.FN[(data.FN$Reps == 1),]$multiplier <- 1
data.FN[(data.FN$Reps == 2),]$multiplier <- 0.96
data.FN[(data.FN$Reps == 3),]$multiplier <- 0.925
data.FN[(data.FN$Reps == 4),]$multiplier <- 0.90
data.FN[(data.FN$Reps == 5),]$multiplier <- 0.88

#Calculate 1RM 
data.FN$onerepmax <- data.FN$Weight..kgs./data.FN$multiplier

#Unique training days
days <- unique(data.FN$Date)

#Number of training days in the past to look for for max
ndays <- 12

#Create data frame with the the estimated one rep maxes for each training day
Date <- days[c(1:(ndays-1))]
Exercise <- rep("Squat",(ndays-1))
onerepmax <- rep(NA,(ndays-1))
data.liftmaxes <- data.frame(Date, Exercise, onerepmax)

#Iterate over all but the first "ndays" training days
for (i in c(ndays:length(days))){
  
  #Select last 10 training days leading up to trainings day i
  datalast10 <- data.FN[data.FN$Date %in% days[c((i-(ndays-1)):i)],c(1,2,8)]
  
  #Get the max for each exercise of last 10 training days
  data.tempmaxes <- aggregate(. ~ Exercise, data=datalast10, FUN= max)
  data.tempmaxes$Date <- days[i]
  
  #put in data frame
  data.liftmaxes = rbind(data.liftmaxes,data.tempmaxes)
}

#Make plot of squat maxes
plot(x = data.liftmaxes[data.liftmaxes$Exercise == "Squat",]$Date, 
     y = data.liftmaxes[data.liftmaxes$Exercise == "Squat",]$onerepmax)

#Sum over the sets of the day
data.FN2 <- aggregate(. ~ Date + Exercise, data=data.FN, FUN=sum)

data.FN3 <- aggregate(. ~ Date + Exercise, data=data.FN, FUN=max)

#Add the estimated 1 Rep maxes in the dataframe
data.FN4 <- merge(data.liftmaxes,data.FN3,by=c("Date","Exercise")) 

#Calculate intensity of each exercise
data.FN4$intensity <- data.FN4$Weight..kgs./data.FN4$onerepmax.x

#Merge dataframes 
data.FN5 <- merge(data.FN2,data.FN4,by=c("Date","Exercise"))

#Specific energy expenditure (joule to burned kcal)
data.FN5$spenex <- 150
data.FN5[data.FN5$Exercise == "Squat",]$spenex <-88.5
data.FN5[data.FN5$Exercise == "Bench Press",]$spenex <-215
data.FN5[data.FN5$Exercise == "Overhead Press",]$spenex <-214
data.FN5[data.FN5$Exercise == "Power Clean",]$spenex <- 78
#Estimations
data.FN5[data.FN5$Exercise == "Power Snatch",]$spenex <-82
data.FN5[data.FN5$Exercise == "Triceps Dips",]$spenex <-214
data.FN5[data.FN5$Exercise == "CG Bench Press",]$spenex <-214
data.FN5[data.FN5$Exercise == "Chin Up",]$spenex <-180
data.FN5[data.FN5$Exercise == "Deadlift",]$spenex <-100

#Range of motion
data.FN5$rom <- 0.5
data.FN5[data.FN5$Exercise == "Squat",]$rom <- 0.73
data.FN5[data.FN5$Exercise == "Deadlift",]$rom <- 0.5
data.FN5[data.FN5$Exercise == "Overhead Press",]$rom <- 0.64
data.FN5[data.FN5$Exercise == "Bench Press",]$rom <- 0.46
data.FN5[data.FN5$Exercise == "Power Clean",]$rom <- 1.25
data.FN5[data.FN5$Exercise == "Power Snatch",]$rom <- 1.67
data.FN5[data.FN5$Exercise == "Dumbbell Hammer Curl",]$rom <- 0.62
data.FN5[data.FN5$Exercise == "Chin Up",]$rom <- 0.63
data.FN5[data.FN5$Exercise == "Seated Calf Raise Machine",]$rom <- 0.045
data.FN5[data.FN5$Exercise == "Triceps Dips",]$rom <- 0.3
data.FN5[data.FN5$Exercise == "Speed DL",]$rom <- 0.5
data.FN5[data.FN5$Exercise == "CG Bench Press",]$rom <- 0.48

#burnedkcal
data.FN5$gym_burned..kcal <- data.FN5$rom*data.FN5$spenex*data.FN5$workload.x/1000

#weighted intensity
data.FN5$weightedintens <- data.FN5$gym_burned..kcal*data.FN5$intensity

#Combine exercises to one overal number for burnedkcal and mean intensity
data.FN6 <- aggregate(. ~ Date, data=data.FN5[,c(1,2,19,20)], FUN=sum)
data.FN6$gym_intensity..pct <-data.FN6$weightedintens/data.FN6$gym_burned..kcal*100
data.FN6$weightedintens <- NULL
data.FN6$Exercise <- NULL

#Add warm up calories
data.FN6$weekday <- format(data.FN6$Date,format="%u") 
data.FN6$warmupcal..kcal <- 0
data.FN6[data.FN6$weekday == 1,]$warmupcal..kcal <- 100
data.FN6[data.FN6$weekday == 3,]$warmupcal..kcal <- 50
data.FN6[data.FN6$weekday == 5,]$warmupcal..kcal <- 150

### Combine the data ###

total1 <- merge(data.GF,data.FN6,by="Date",all.x=TRUE)
total2 <- merge(data.BM,total1,by="Date",all.y=TRUE)
total3 <- merge(total2,data.MFP2,by="Date")

### Calorie 
total3[is.na(total3)] <- 0
total3$weight..kg_yesterday <- c(total3$weight..kg[-1], NA)
total3$weight..kg_diff <- total3$weight..kg - total3$weight..kg_yesterday
total3$weight..kg_diff[total3$weight..kg_diff > 5] <- 0
total3$weight..kg_diff[total3$weight..kg_diff < -5] <- 0
total3$burned_total..kcal <- total3$Calories..kcal. + total3$gym_burned..kcal + total3$warmupcal..kcal
total3$Calories_diff <- total3$Calories - total3$burned_total..kcal
plot(total3$Calories_diff, total3$weight..kg_diff )

#################################
#     DATA EXPLORATION          #
#################################
total3$fart_2delay <- c(total3$smellyfarts...0..4.rating.[-2], 0)

df <- tail(total3, -36)
df$Fat = df$Fat/100
df$Carbs = df$Carbs/100
df$Protein = df$Protein/100

df$weekday <- format(df$Date,format="%u") 
df$is_trainingday <- 0
df$is_weekend <- 0
df[df$weekday == 1,]$is_trainingday <- 1
df[df$weekday == 3,]$is_trainingday <- 1
df[df$weekday == 5,]$is_trainingday <- 1
df[df$weekday == 6,]$is_weekend <- 1
df[df$weekday == 7,]$is_weekend <- 1


#masturbation
model <- lm(df$mastrubation...[-c(1)] ~ df$Carbs[-c(1)] + df$Fat[-c(1)] + df$Protein[-c(1)] + df$Carbs[-c(85)] + df$Fat[-c(85)] + df$Protein[-c(85)] +  df$is_weekend[-c(1)] +df$is_trainingday[-c(1)])
summary(model)

#farts
model <- lm(df$smellyfarts...0..4.rating.[-c(1,2)] ~ df$Carbs[-c(1,85)] + df$Fat[-c(1,85)] + df$Protein[-c(1,85)] + df$Carbs[-c(84,85)] + df$Fat[-c(84,85)] + df$Protein[-c(84,85)])
summary(model)

#acne
model <- lm(df$acnebody...pimpels[-c(1,2,3,4)] ~ df$`rice cracker in g`[-c(1,2,84,85)] + df$`rice cracker in g`[-c(1,83,84,85)] + df$`rice cracker in g`[-c(82,83,84,85)]

model <- lm(df$acnebody...pimpels[-c(1,2,3,4)] ~ df$`chocolate 85% in g`[-c(1,2,84,85)] + df$`chocolate 85% in g`[-c(1,83,84,85)] + df$`chocolate 85% in g`[-c(82,83,84,85)])
summary(model)

df$`chocolate 85% in g`


plot(jitter(df$acnebody...pimpels[-c(1,2,3,4)]), jitter(df$`rice cracker in g`[-c(1,83,84,85)]))

plot(df$mastrubation...,pch="*")
par(new=TRUE)
plot(df$Fat, col='red',pch="*")


plot(data.BM$ffm..kg,pch="*", ann=FALSE, axes=FALSE, col='blue')
par(new=TRUE)
plot(data.BM$bodyfat..kg,pch="*", ann=FALSE, axes=FALSE, col='red')


total3$mastrubation...
total3$`Quaker Oats (Net Carbs) - Quick Oats Oatmeal in cup`
total3$`Oat - Oat in g`

#################################
#     MODEL BUILDING            #
#################################
