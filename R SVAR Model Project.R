#Lyle Begbie
#BGBLYL001
#TS Project

#Replicting SVAR model for South Africa


rm(list = ls())
graphics.off()

# load package
library(tidyverse)
library(vars)
library(readxl)
library(tseries)
library(mFilter)


#Load dataset
dat <- read_excel("Data.xlsx")

#view(dat)

plot.ts(dat)
#Convert to timeseries object

OIL<-ts(dat$OIL,start=c(1994,1,1), freq=4)
FED<-ts(dat$FED,start=c(1994,1,1), freq=4)
GDP<-ts(dat$GDP,start=c(1994,1,1), freq=4)
CPI<-ts(dat$CPI,start=c(1994,1,1), freq=4)
M1<-ts(dat$M1,start=c(1994,1,1), freq=4)
r<-ts(dat$I,start=c(1994,1,1), freq=4)
EX<-ts(dat$EX,start=c(1994,1,1), freq=4)


#Plot the series

ts.plot(OIL)
ts.plot(FED)
ts.plot(GDP)
ts.plot(CPI)
ts.plot(M1)
ts.plot(r)
ts.plot(EX)


#Tests for unit root and structural breaks


#Breakpoint tests

datbp <- tibble(ylag0 = dat$I,
               ylag1 = lag(dat$I)) %>%
  drop_na()

cusum <- efp(ylag0 ~ ylag1, type = "OLS-CUSUM", data = datbp)
plot(cusum)

sa_bp <- breakpoints(ylag0 ~ ylag1, data = datbp, breaks = 5)
summary(sa_bp)
plot(sa_bp, breaks = 15)


datbp <- tibble(ylag0 = dat$OIL,
                ylag1 = lag(dat$OIL)) %>%
  drop_na()

cusum <- efp(ylag0 ~ ylag1, type = "OLS-CUSUM", data = datbp)
plot(cusum)

sa_bp <- breakpoints(ylag0 ~ ylag1, data = datbp, breaks = 5)
summary(sa_bp)
plot(sa_bp, breaks = 15)



datbp <- tibble(ylag0 = dat$EX,
                ylag1 = lag(dat$EX)) %>%
  drop_na()

cusum <- efp(ylag0 ~ ylag1, type = "OLS-CUSUM", data = datbp)
plot(cusum)

sa_bp <- breakpoints(ylag0 ~ ylag1, data = datbp, breaks = 5)
summary(sa_bp)
plot(sa_bp, breaks = 15)



#Dummy variables created to account for these breakpoints
# I need five dummies
# Have one for each variable
dumI<- rep(0, length(dat$I))
dumI[2] <- 1
dumI[17] <- 1
dumI[18] <- 1
dumI[19] <- 1
dumI[20] <- 1
dumI[29] <- 1
dumI[30] <- 1
dumI[36] <- 1
dumI[40] <- 1
dumI[51] <- 1
dumI[57] <- 1
dumI[66] <- 1
dumI[85] <- 1



dumEX<- rep(0, length(dat$EX))
dumEX[32] <- 1
dumEX[69] <- 1
dumEX[59] <- 1
dumEX[58] <- 1
dumEX[96] <- 1

dumM1<- rep(0, length(dat$M1))
dumM1[37] <- 1
dumM1[60] <- 1

dumOIL<- rep(0, length(dat$OIL))
dumOIL[59] <- 1
dumOIL[61] <- 1


dumCPI<- rep(0, length(dat$I))
dumCPI[31] <- 1
dumCPI[48] <- 1

dumGDP<- rep(0, length(dat$EX))
dumGDP[19] <- 1
dumGDP[47] <- 1
dumGDP[63] <- 1


dumFED<- rep(0, length(dat$EX))
dumFED[25] <- 1
dumFED[40] <- 1
dumFED[55] <- 1
dumFED[87] <- 1
dumFED[59] <- 1
dumFED[56] <- 1

dum <- tibble(
  dumI = dumI,
  dumEX = dumEX,
  dumCPI = dumCPI,
  dumGDP = dumGDP,
  dumFED = dumFED
)



#Build VAR model and conduct testing
#Bind the timeseries variables

sv<-cbind(OIL,FED,GDP,CPI,M1,r,EX)

#Lag order selection

lagselect<-VARselect(sv,lag.max = 8,type="both")
lagselect$selection


#Make use of HQ lag length suggestion of 2



VARModelS<- VAR(sv,p=2, season=4,exogen=dum, type= "both")
summary(VARModelS)
#Seasonal variables are significant
#However the system is not stable as not all eigenvalues are below 1.



bv_serial <-
  serial.test(VARModelS, lags.pt = 12, type = "PT.asymptotic")
bv_serial
#p value of 0.1084 means no serial correlation

view(bv_serial)
plot(bv_serial, names = "OIL")
plot(bv_serial, names = "FED")
plot(bv_serial, names = "GDP")
plot(bv_serial, names = "CPI")
plot(bv_serial, names = "M1")
plot(bv_serial, names = "r")
plot(bv_serial, names = "EX")

#Testing for Arch Effects
bv_arch <-
  arch.test(VARModelS, lags.multi = 12, multivariate.only = TRUE)
bv_arch
#p value =1 means no heteroskedasticity

bv_norm <- normality.test(VARModelS, multivariate.only = TRUE)
bv_norm
#All normality tests failed as p-value close to zero




# find outliers
resid <- residuals(VARModelS)
par(mfrow = c(1, 1))

plot.ts(resid[, 1])
plot.ts(resid[, 2])
plot.ts(resid[, 3])
plot.ts(resid[, 4])
plot.ts(resid[, 5])
plot.ts(resid[, 6])
plot.ts(resid[, 7])



plot.ts(resid[, 1]) # somewhere between obs 60 and 80
plot.ts(resid[55:65, 1])
#observation 59 61

resid[, 2] # observation 68 and 69
plot.ts(resid[, 2]) # somewhere between obs 60 and 80
plot.ts(resid[50:60, 2])
#Observation 59 and 56

plot.ts(resid[, 3])
#All ok

plot.ts(resid[, 4])
#All ok

plot.ts(resid[, 5])
plot.ts(resid[30:40, 5])
plot.ts(resid[50:60, 5])
# Observation 60 and 37

plot.ts(resid[, 6])
plot.ts(resid[0:10, 6])
plot.ts(resid[10:20, 6])
plot.ts(resid[20:30, 6])
plot.ts(resid[30:40, 6])
plot.ts(resid[50:60, 6])

#Observation 2,17, 19,20,29,30,40, 57


plot.ts(resid[, 7])
plot.ts(resid[50:60, 7])
plot.ts(resid[80:90, 7])
plot.ts(resid[90:100, 7])
#Observation 59, 88, 96



# testing for structural stability
bv_cusum <- stability(VARModelS, type = "OLS-CUSUM")
plot(bv_cusum)
#System seems stable




#Setting Restrictions for SVAR model

# Matrix for structural restrictions

mat<- diag(7)
mat[2,1]<-NA
mat[3,1]<-NA
mat[4,1]<-NA
mat[6,1]<-NA
mat[7,1]<-NA
mat[7,2]<-NA
mat[4,3]<-NA
mat[5,3]<-NA
mat[5,4]<-NA
mat[5,6]<-NA
mat[6,5]<-NA
mat[6,7]<-NA
mat[7,3]<-NA
mat[7,4]<-NA
mat[7,5]<-NA
mat[7,6]<-NA
mat



#Matrix for lagged relationships

b.mat <- diag(7)
diag(b.mat) <- NA
print(b.mat)



SVAR.1<-SVAR(VARModelS,Amat = mat,Bmat =b.mat,hessian = TRUE,esmethod=c("scoring","direct"))
SVAR.1

SVAR.3<-SVAR(VARModelS,Amat = mat,Bmat =NULL,hessian = TRUE,esmethod=c("scoring","direct"))
SVAR.3



#Impulse Response Functions

one.r <-
  irf(
    SVAR.3,
    response = "r",
    impulse = "r",
    n.ahead = 25,
    ortho = TRUE,
    boot = TRUE
  )

plot(one.r)


one.EX <-
  irf(
    SVAR.3,
    response = "EX",
    impulse = "r",
    n.ahead = 25,
    ortho = TRUE,
    boot = TRUE
  )

plot(one.EX)


one.CPI <-
  irf(
    SVAR.3,
    response = "CPI",
    impulse = "r",
    n.ahead = 25,
    ortho = TRUE,
    boot = TRUE
  )

plot(one.CPI)


one.GDP <-
  irf(
    SVAR.1,
    response = "GDP",
    impulse = "r",
    n.ahead = 25,
    ortho = TRUE,
    boot = TRUE
  )
plot(one.GDP)


# generate variance decompositions
bv_vardec <- fevd(SVAR.1, n.ahead = 24)
view(bv_vardec)


