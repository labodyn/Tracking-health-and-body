
library("reshape")

### Read in data
#================

setwd("/home/lander/Dropbox/Tracking-health-and-body/data")
data.MFP <- read.csv("MyFitnessPal.csv")             #MyFitnessPal
data.FN <- read.csv("FitNotes_Export.csv")[,c(1:5)]  #FitNotes
data.GF <- read.csv("Takeout/Fit/Daily Aggregations/Daily Summaries.csv")[,c(1,2,3)] #Google Fit

### Transform data
#==================

#Remove some bad data (temporal solution)
data.MFP <- data.MFP[-c(11,31),]

#Calculating burned calories
data.GF$burnedkcal <- data.GF$Calories..kcal.-18.39323*24*4

#Splitting myfitnesspal feature "Name" into "Product", "Quantity" and "Unit"
names.split <- strsplit(as.character(data.MFP$Name), ", ")
quantity.split <- strsplit(sapply(names.split, function (x) x[2]), " ")
data.MFP$Product <- paste(sapply(names.split, function (x) x[1]),'in',
                          sapply(quantity.split, function (x) x[2]))
data.MFP$Quantity <- as.numeric(sapply(quantity.split, function (x) x[1]))
data.MFP$Name <- NULL

#Restructuring data: Make foods features with values the consumed amount.
#->Putting all consumed foods to same the units?? 

test <- data.MFP[,c(1,11,12)]

test2 <- cast(test,Date~Product,sum)

#Putting dates in the right format
data.MFP$Date <- as.Date(data.MFP$Date, "%d-%b-%y")
data.GF$Date <- as.Date(data.GF$Date)
data.FN$Date <- as.Date(data.FN$Date)

#Combine data
total <- merge(data.MFP,data.GF,by="Date")

