library("reshape")
library("xlsx")
setwd("/home/lander/Dropbox/Tracking-health-and-body/data")
library("lattice")
#read in
data.FN <- read.csv("FitNotes_Export.csv")[,c(1:5)]  #FitNotes

#String to date
data.FN$Date <- as.Date(data.FN$Date)

# Calculate 1RM
data.FN$multiplier <- 0.86
data.FN[(data.FN$Reps == 1),]$multiplier <- 1
data.FN[(data.FN$Reps == 2),]$multiplier <- 0.96
data.FN[(data.FN$Reps == 3),]$multiplier <- 0.925
data.FN[(data.FN$Reps == 4),]$multiplier <- 0.90
data.FN[(data.FN$Reps == 5),]$multiplier <- 0.88
data.FN$onerepmax <- data.FN$Weight..kgs./data.FN$multiplier

# Collapse all exercises to one a day
data.FN2 <- aggregate(. ~ Date + Exercise, data=data.FN, FUN=max)

# Select time range
data.FN2$weekday <- format(data.FN2$Date,format="%u") 
data.FN2 = data.FN2[as.Date('2016-04-01') < data.FN2$Date,]
data.FN2 = data.FN2[data.FN2$Date< as.Date('2017-02-04'),]
data.FN2 = data.FN2[data.FN2$weekday == 5,]

as.Date('2016-04-08')


squat = data.FN2[data.FN2$Exercise == 'Squat',]
squat = squat[squat$onerepmax > 132,]

press = data.FN2[data.FN2$Exercise == 'Overhead Press',]
press = press[press$onerepmax > 57.5,]

bench_p = data.FN2[data.FN2$Exercise == 'Bench Press',]
bench_t = data.FN2[data.FN2$Exercise == 'Bench Press (Touch and Go)',]
bench_t$onerepmax = bench_t$onerepmax * 0.948
bench = rbind(bench_t, bench_p)
bench = bench[bench$onerepmax > 91,]

xlim = c(as.Date('2016-04-08'),as.Date('2017-02-03'))
par(mar=c(5, 8, 2, 2) + 0.1)
plot(x = all_lifts$Date, y = all_lifts$onerepmax.x, type= 'l', col='red', xlim=xlim, ylim=c(135,163),xlab='Date', ylab='')
axis(2,lwd=2,line=0,col = "red")
par(new=TRUE)
plot(x=bench$Date, y =bench$onerepmax,yaxt='n', type= 'l', col='blue', xlim=xlim, ylim=c(92,105),xlab = '',ylab = '')
axis(2,lwd=2,line=2,col = "blue")
par(new=TRUE)
plot(x=press$Date, y =press$onerepmax,axes=F, type= 'l', col='green', xlim=xlim, xlab = '', ylab = '')
axis(2,lwd=2,line=4,col = "green")
mtext(2,text="Estimated 1RM",line=6)
abline(v=as.Date('2016-11-21'))
legend(as.Date('2016-11-25'), 62,  c('squat', 'bench', 'press'), lty=c(1,1),  lwd=c(2.5,2.5),col=c("red",'blue','green'))
