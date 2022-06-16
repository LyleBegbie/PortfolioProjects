 

*Micrometrics Project
*Lyle Begbie
*BGBLYL001
 
*Analysis do file
 
clear all
cap log close		
log using "\\technet.wf.uct.ac.za\profiledata$\BGBLYL001\Downloads\Project\Analysis.log", replace
local datafolder="\\technet.wf.uct.ac.za\profiledata$\BGBLYL001\Downloads\Project\Data"
set maxvar 32767
 
*ssc install ivreg2
*ssc install ranktest
 
 
 
use "\\technet.wf.uct.ac.za\profiledata$\BGBLYL001\Downloads\Project\Data\Waves\w1w2w3w4w5.dta", replace

*Accounting for clusters	
replace cluster=w1_cluster if year==2008
label var cluster "Cluster variable, to be used to correctly estimate standard errors"

gen weight=w1_wgt 
replace weight=w2_pweight if weight==.
replace weight=w3_pweight if weight==.
replace weight=w4_pweight if weight==.
replace weight=w5_pweight if weight==.




label var weight "Weight variable, to be used in regressions and descriptive stats"
*NIDs uses cluster sampling hence these weights accounts for that
		
gen stratum2008=w1_dc2001
sort pid
by pid: egen stratum=min(stratum2008)
replace stratum=w2_dc2001 if stratum==.
replace stratum=w3_dc2001 if stratum==.
replace stratum=w4_dc2001 if stratum==.
replace stratum=w5_dc2001 if stratum==.
count if stratum==.
			






*Years of education variable created
tab w1_a_edschgrd 
tab w1_a_edterlev

gen yrs_educ = w1_a_edschgrd  if w1_a_edschgrd >=0 & w1_a_edschgrd <=12
replace yrs_educ = w2_a_edschgrd if w2_a_edschgrd>=0 & w2_a_edschgrd<=12
replace yrs_educ = w3_a_edschgrd if w3_a_edschgrd>=0 & w3_a_edschgrd<=12
replace yrs_educ = w4_a_edschgrd if w4_a_edschgrd>=0 & w4_a_edschgrd<=12
replace yrs_educ = w5_a_edschgrd if w5_a_edschgrd>=0 & w5_a_edschgrd<=12

replace yrs_educ =0 if w1_a_edschgrd ==25 | w2_a_edschgrd==25 | w3_a_edschgrd==25| w4_a_edschgrd==25 | w5_a_edschgrd==25
replace yrs_educ =10 if w1_a_edschgrd ==13 | w2_a_edschgrd==13 | w3_a_edschgrd==13| w4_a_edschgrd==13 | w5_a_edschgrd==13
replace yrs_educ =11 if w1_a_edschgrd ==14 | w2_a_edschgrd==14 | w3_a_edschgrd==14 | w4_a_edschgrd==14 | w5_a_edschgrd==14
replace yrs_educ =12 if w1_a_edschgrd ==15 | w2_a_edschgrd==15 | w3_a_edschgrd==15 | w4_a_edschgrd==15 | w5_a_edschgrd==15
replace yrs_educ =10 if (w1_a_edterlev ==13 & yrs_educ<10) | (w2_a_edterlev ==13 & yrs_educ<10) | (w3_a_edterlev ==13 & yrs_educ<10)| (w4_a_edterlev ==13 & yrs_educ<10) | (w5_a_edterlev ==13 & yrs_educ<10)
replace yrs_educ =11 if (w1_a_edterlev ==14 & yrs_educ<11) | (w2_a_edterlev ==14 & yrs_educ<11) | (w3_a_edterlev ==14 & yrs_educ<11) | (w4_a_edterlev ==14 & yrs_educ<11) | (w5_a_edterlev ==14 & yrs_educ<11)
replace yrs_educ =12 if (w1_a_edterlev ==15 & yrs_educ<12) | (w2_a_edterlev ==15 & yrs_educ<12) | (w3_a_edterlev ==15 & yrs_educ<12)| (w4_a_edterlev ==15 & yrs_educ<12) | (w5_a_edterlev ==15 & yrs_educ<12)
		



replace yrs_educ =11 if ( w1_a_edterlev ==16 |w2_a_edterlev==16 |w3_a_edterlev==16|w4_a_edterlev==16 |w5_a_edterlev==16) & yrs_educ<11 
replace yrs_educ =14 if w1_a_edterlev ==17 | w2_a_edterlev==17 | w3_a_edterlev==17| w4_a_edterlev==17 | w5_a_edterlev==17
replace yrs_educ =13 if w1_a_edterlev ==18 | w2_a_edterlev==18 | w3_a_edterlev==18| w4_a_edterlev==18 | w5_a_edterlev==18
replace yrs_educ =14 if w1_a_edterlev ==19 | w2_a_edterlev==19 | w3_a_edterlev==19| w4_a_edterlev==19 | w5_a_edterlev==19
replace yrs_educ =15 if w1_a_edterlev ==20 | w2_a_edterlev==20 | w3_a_edterlev==20| w4_a_edterlev==20 | w5_a_edterlev==20
replace yrs_educ =16 if w1_a_edterlev ==21 | w2_a_edterlev==21 | w3_a_edterlev==21| w4_a_edterlev==21 | w5_a_edterlev==21
replace yrs_educ =16 if w1_a_edterlev ==22 | w2_a_edterlev==22 | w3_a_edterlev==22| w4_a_edterlev==22 | w5_a_edterlev==22
replace yrs_educ =17 if w1_a_edterlev ==23 | w2_a_edterlev==23 | w3_a_edterlev==23| w4_a_edterlev==23 | w5_a_edterlev==23


*create dependent variable

*log hours worked variable created
*Comes from weekly hours worked

* need to sum up multiple hours
*Sum of hours worked of primary job, secondary job, self employed and casual work

egen hrs1= rowtotal(w1_a_em1hrs w1_a_em2hrs w1_a_emshrs w1_a_emchrs)
replace hrs1=. if hrs1==0
egen hrs2= rowtotal(w2_a_em1hrs w2_a_em2hrs w2_a_emshrs w2_a_emchrs)
replace hrs2=. if hrs2==0
egen hrs3= rowtotal(w3_a_em1hrs w3_a_em2hrs w3_a_emshrs w3_a_emchrs)
replace hrs3=. if hrs3==0
egen hrs4= rowtotal(w4_a_em1hrs w4_a_em2hrs w4_a_emshrs w4_a_emchrs)
replace hrs4=. if hrs4==0
egen hrs5= rowtotal(w5_a_em1hrs w5_a_em2hrs w5_a_emshrs w5_a_emchrs)
replace hrs5=. if hrs5==0


gen hours_worked=hrs1
replace hours_worked= hrs2 if hours_worked==.
replace hours_worked= hrs3 if hours_worked==.
replace hours_worked= hrs4 if hours_worked==.
replace hours_worked= hrs5 if hours_worked==.
replace hours_worked=. if hours_worked<0
gen loghours=log(hours_worked)
		
	
	
*This is the dependent variables
*This is monthly earnings divided by monthy hours worked to get daily wage

*Wage represents the sum of earnings different sources

egen wage1= rowtotal(w1_swag w1_cwag w1_fwag)
replace wage1=. if wage1==0
egen wage2= rowtotal(w2_swag w2_cwag w2_fwag)
replace wage2=. if wage2==0
egen wage3= rowtotal(w3_swag w3_cwag w3_fwag)
replace wage3=. if wage3==0
egen wage4= rowtotal(w4_swag w4_cwag w4_fwag)
replace wage4=. if wage4==0
egen wage5= rowtotal(w5_swag w5_cwag w5_fwag)
replace wage5=. if wage5==0


		
gen earnings=wage1
replace earnings= wage2 if earnings==.
replace earnings=wage3 if earnings==.	
replace earnings=wage4 if earnings==.	
replace earnings=wage5 if earnings==.	



*Present value by July of each year to get real value
* http://www.statssa.gov.za/publications/P0141/CPIHistory.pdf used for the price level.

gen realearnings= earnings*100/103.2 if year==2017
replace realearnings= earnings*100/88.7 if year==2014
replace realearnings= earnings*100/78.4 if year==2012
replace realearnings= earnings*100/71.1 if year==2010
replace realearnings= earnings*100/65.1 if year==2008


gen realwage=realearnings/(4.3*hours_worked)
gen logrealwage=log(realwage)
label var logrealwage "Log(real wage) -Dependent variable to be used in the regressions"
		
*This is monthly real earnings divided by monthy hours worked to get daily real wage	
		

*female dummy
	
gen femaledummy=w1_a_gen==2	
replace femaledummy= 1 if w2_a_gen==2.	
replace femaledummy= 1 if w3_a_gen==2.	
replace femaledummy= 1 if w4_a_gen==2.
replace femaledummy= 1 if w5_a_gen==2.
label var femaledummy "Femaledummy -Dummy to represent Females"
			
		

*black dummy
gen blackdummy =w1_a_popgrp==1
replace blackdummy= 1 if w2_a_popgrp==1.	
replace blackdummy= 1 if w3_a_popgrp==1.
replace blackdummy= 1 if w4_a_popgrp==1.
replace blackdummy= 1 if w5_a_popgrp==1.
label var blackdummy "Blackdummy -Dummy to represent black African"
*blackdummy in african=1 and other is = o is created


*married dummy

gen marrieddummy = w1_a_marstt==1
replace marrieddummy= 1 if w2_a_marstt==1.	
replace marrieddummy= 1 if w3_a_marstt==1.
replace marrieddummy= 1 if w4_a_mar==1.
replace marrieddummy= 1 if w5_a_mar==1.
label var marrieddummy "Married dummy -Dummy to represent those who are married"



*Union dummy

gen uniondummy=0 if w1_a_em1tru==2
replace uniondummy=1 if w1_a_em1tru==1.
replace uniondummy=0 if w2_a_em1tru==2.
replace uniondummy=1 if w2_a_em1tru==1.
replace uniondummy=0 if w3_a_em1tru==2.
replace uniondummy=1 if w3_a_em1tru==1.
replace uniondummy=0 if w4_a_em1tru==2.
replace uniondummy=1 if w4_a_em1tru==1.
replace uniondummy=0 if w5_a_em1tru==2.
replace uniondummy=1 if w5_a_em1tru==1.



*Age

gen age=2008- w1_a_dob_y
replace age=2010- w2_a_dob_y if age==.
replace age=2012- w3_a_dob_y if age==.
replace age=2014- w4_a_dob_y if age==.
replace age=2017- w5_a_dob_y if age==.


replace age=. if age<0

gen age2=age*age

label var age "Age in years"





*District which is a proxy for geography



gen city= w1_dc2011
replace city=w2_dc2011 if city==.
replace city=w3_dc2011 if city==.
replace city=w4_dc2011 if city==.
replace city=w5_dc2011 if city==.
keep if city>0


gen city1dummy=0
replace city1dummy=1 if city==798
*Represents Johannesburg

gen city3dummy=0
replace city3dummy=1 if city==798|city==799|city==797
*Represents Gauteng cities

gen city5dummy=0
replace city5dummy=1 if city==799|city==599|city==798|city==199|city==797
*Represents 5 largest cities

gen city8dummy=0
replace city8dummy=1 if city==799|city==599|city==798|city==199|city==797|city==260|city==299|city==174
*Represents Metros

gen urban= w1_geo2011
replace urban=w2_geo2011 if urban==.
replace urban=w3_geo2011 if urban==.
replace urban=w4_geo2011 if urban==.
replace urban=w5_geo2011 if urban==.
keep if urban>0

gen urbandummy=0
replace urbandummy=1 if urban==1
*urbandummy represents those living in urban areas






*Industry dummy 

	
gen ind_variable= w1_a_em1prod_c
replace ind_variable=w2_a_em1prod_c if ind_variable==.
replace ind_variable=w3_a_em1prod_c if ind_variable==.
replace ind_variable=w4_a_em1prod_c if ind_variable==.
replace ind_variable=w5_a_em1prod_c if ind_variable==.

replace ind_variable=. if ind_variable<0	
foreach num of numlist 0/9 {
		   gen inddummy`num'=ind_variable==`num' 
		}
	
	
	
*Occupation dummy 
*There are 10
	
gen occ_variable= w1_a_em1occ_isco_c
replace occ_variable=w2_a_em1occ_isco_c if occ_variable==.
replace occ_variable=w3_a_em1occ_isco_c if occ_variable==.
replace occ_variable=w4_a_em1occ_isco_c if occ_variable==.
replace occ_variable=w5_a_em1occ_isco_c if occ_variable==.
replace occ_variable=. if occ_variable<0	

	
	
foreach num of numlist 0/9 {
		   gen occdummy`num'=occ_variable==`num' 
		}
	
			
*create self employed dummy variable 
gen selfemp	= w1_a_ems==1	
replace selfemp= 1 if w2_a_ems==1.	
replace selfemp= 1 if w3_a_ems==1.
replace selfemp= 1 if w4_a_ems==1.	
replace selfemp= 1 if w5_a_ems==1.
	
		

	
*wave dummy	
	
foreach num of numlist 1/5 {
		gen wavedummy`num'=0
		replace wavedummy`num'=1 if wave==`num'
		}	
		
	
		
*set as panel data	
xtset pid wave
		
*xtdes
*Variables generated done


*Summary and descriptive statistics 

		
*svyset cluster [pw=weight], strata(stratum)


sum realearnings [aw=weight] if year==2008, d 
sum realearnings [aw=weight] if year==2010, d 
sum realearnings [aw=weight] if year==2012, d 
sum realearnings [aw=weight] if year==2014, d 	
sum realearnings [aw=weight] if year==2017, d 	

	

sum realearnings [aw=weight] if year==2008 & city5dummy==1, d 
sum realearnings [aw=weight] if year==2008 & city5dummy==0, d 
sum realearnings [aw=weight] if year==2010 & city5dummy==1, d 
sum realearnings [aw=weight] if year==2010 & city5dummy==0, d 
sum realearnings [aw=weight] if year==2012 & city5dummy==1, d 
sum realearnings [aw=weight] if year==2012 & city5dummy==0, d 
sum realearnings [aw=weight] if year==2014 & city5dummy==1, d 
sum realearnings [aw=weight] if year==2014 & city5dummy==0, d 	
sum realearnings [aw=weight] if year==2017 & city5dummy==1, d 
sum realearnings [aw=weight] if year==2017 & city5dummy==0, d 	
	
*realearnings compared for different years and city5 dummy	
	
	
tab w1_a_em1occ_isco_c
tab occ_variable city5dummy [aw=weight], row


*Most of the skilled jobs in large citys



tab blackdummy city5dummy [aw=weight], col
*Large cities are more diverse as expected.
	
gen employed= 1 if realearnings<100000000000
tab employed wave


	
* Pooled OLS Regression
		
reg logrealwage  city1dummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* 
reg logrealwage  city3dummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* 
reg logrealwage  city5dummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* 
reg logrealwage  city8dummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* 
reg logrealwage  urbandummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* 

*with svy to improve standard errors:

svyset cluster [pw=weight], strata(stratum)

svy: reg logrealwage  city1dummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* 
svy: reg logrealwage  city3dummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* 
svy: reg logrealwage  city5dummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* 
svy: reg logrealwage  city8dummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* 
svy: reg logrealwage  urbandummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* 









*lag variables generated to regress first difference
		
	foreach var of varlist logrealwage city1dummy city3dummy city5dummy city8dummy urbandummy uniondummy  yrs_educ marrieddummy loghours inddummy* occdummy* wavedummy* {
	gen lag_`var'=l.`var'
	gen fd_`var'=`var'-lag_`var'
	}
* A number of variables removed given that they would not expected to be a change such as gender

	
svyset cluster [pw=weight], strata(stratum)
	
	
*first difference regression
reg fd_logrealwage  fd_city1dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours  fd_inddummy* fd_occdummy* fd_wavedummy* 
reg fd_logrealwage  fd_city3dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 
reg fd_logrealwage  fd_city5dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 
reg fd_logrealwage  fd_city8dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 
reg fd_logrealwage  fd_urbandummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 

reg fd_logrealwage  fd_city1dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours  fd_inddummy* fd_occdummy* fd_wavedummy* [pw=weight] , vce( cluster cluster)
reg fd_logrealwage  fd_city3dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* [pw=weight]  , vce( cluster cluster)
reg fd_logrealwage  fd_city5dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* [pw=weight]  , vce( cluster cluster)
reg fd_logrealwage  fd_city8dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* [pw=weight]  , vce( cluster cluster)
reg fd_logrealwage  fd_urbandummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* [pw=weight]  , vce( cluster cluster)






xtset pid wave
		foreach var of varlist logrealwage city1dummy city3dummy city5dummy city8dummy urbandummy uniondummy  yrs_educ marrieddummy loghours inddummy* occdummy* wavedummy* {
		gen secd_`var'=`var'-l2.`var'
		}	

*Regress second difference

reg secd_logrealwage  secd_city1dummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy*  
reg secd_logrealwage  secd_city3dummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy* 	
reg secd_logrealwage  secd_city5dummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy* 	
reg secd_logrealwage  secd_city8dummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy* 	
reg secd_logrealwage  secd_urbandummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy* 	
	
reg secd_logrealwage  secd_city1dummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy* [pw=weight] , vce( cluster cluster)
reg secd_logrealwage  secd_city3dummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy* [pw=weight] , vce( cluster cluster)	
reg secd_logrealwage  secd_city5dummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy* 	[pw=weight] , vce( cluster cluster)
reg secd_logrealwage  secd_city8dummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy* 	[pw=weight] , vce( cluster cluster)
reg secd_logrealwage  secd_urbandummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy* 	[pw=weight] , vce( cluster cluster)
	
		
	
	
	
	
	
	


xtset pid wave
		foreach var of varlist logrealwage city1dummy city3dummy city5dummy city8dummy urbandummy uniondummy  yrs_educ marrieddummy loghours inddummy* occdummy* wavedummy* {
		gen thrd_`var'=`var'-l3.`var'
		}	

*Regress third difference
reg thrd_logrealwage  thrd_city1dummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* 
reg thrd_logrealwage  thrd_city3dummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* 
reg thrd_logrealwage  thrd_city5dummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* 
reg thrd_logrealwage  thrd_city8dummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* 
reg thrd_logrealwage  thrd_urbandummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* 
				
	
	
reg thrd_logrealwage  thrd_city1dummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* [pw=weight] , vce( cluster cluster)
reg thrd_logrealwage  thrd_city3dummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* [pw=weight] , vce( cluster cluster)
reg thrd_logrealwage  thrd_city5dummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* [pw=weight] , vce( cluster cluster)
reg thrd_logrealwage  thrd_city8dummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* [pw=weight] , vce( cluster cluster)
reg thrd_logrealwage  thrd_urbandummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* [pw=weight] , vce( cluster cluster)
				
		
	
	
	
	
	
	
	
	
xtset pid wave
		foreach var of varlist logrealwage city1dummy city3dummy city5dummy city8dummy urbandummy uniondummy  yrs_educ marrieddummy loghours inddummy* occdummy* wavedummy* {
		gen ford_`var'=`var'-l4.`var'
		}	

*Regress fourth difference
reg ford_logrealwage  ford_city1dummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* 
reg ford_logrealwage  ford_city3dummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* 
reg ford_logrealwage  ford_city5dummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* 
reg ford_logrealwage  ford_city8dummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* 
reg ford_logrealwage  ford_urbandummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* 
	
	
reg ford_logrealwage  ford_city1dummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* [pw=weight] , vce( cluster cluster)
reg ford_logrealwage  ford_city3dummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* [pw=weight] , vce( cluster cluster)
reg ford_logrealwage  ford_city5dummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* [pw=weight] , vce( cluster cluster)
reg ford_logrealwage  ford_city8dummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* [pw=weight] , vce( cluster cluster)
reg ford_logrealwage  ford_urbandummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* [pw=weight] , vce( cluster cluster)
	
		
	
	
	
*Summary stats after creating first to fourth difference variables


tab  fd_city5dummy wave 
tab  secd_city5dummy wave
tab  thrd_city5dummy wave
tab  ford_city5dummy wave
*represents people moving

tab  fd_city5dummy wave if employed==1
tab  secd_city5dummy wave if employed==1
tab  thrd_city5dummy wave if employed==1
tab  ford_city5dummy wave if employed==1
  
tab  fd_city5dummy wave if employed==1 [aw=weight], col
tab  secd_city5dummy wave if employed==1 [aw=weight], col
tab  thrd_city5dummy wave if employed==1 [aw=weight], col
tab  ford_city5dummy wave if employed==1 [aw=weight], col
  
 *Roughly 5% of those employed moved out of and into the five largest cities. 
  
tab earnings 
  
  
sum realearnings [aw=weight] if fd_city5dummy ==1, d 
sum realearnings [aw=weight] if fd_city5dummy ==0, d 
sum realearnings [aw=weight] if fd_city5dummy ==-1, d 

sum realearnings [aw=weight] if secd_city5dummy ==1, d 
sum realearnings [aw=weight] if secd_city5dummy ==0, d 
sum realearnings [aw=weight] if secd_city5dummy ==-1, d

sum realearnings [aw=weight] if thrd_city5dummy ==1, d 
sum realearnings [aw=weight] if thrd_city5dummy ==0, d 
sum realearnings [aw=weight] if thrd_city5dummy ==-1, d

sum realearnings [aw=weight] if ford_city5dummy ==1, d 
sum realearnings [aw=weight] if ford_city5dummy ==0, d 
sum realearnings [aw=weight] if ford_city5dummy ==-1, d


	


	
*Look at attrition

*Gen attrite
gen attrite=0
replace attrite=1 if f.pid==. 
tab attrite wave, col	
			
	
*Compare first to fourth difference with attrite variable

reg fd_logrealwage fd_city5dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
reg fd_logrealwage attrite fd_city5dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		

reg secd_logrealwage  secd_city5dummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy*
reg secd_logrealwage attrite  secd_city5dummy secd_uniondummy  secd_yrs_educ secd_marrieddummy secd_loghours secd_inddummy* secd_occdummy* secd_wavedummy*

reg thrd_logrealwage  thrd_city5dummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* 
reg thrd_logrealwage  attrite thrd_city5dummy thrd_uniondummy  thrd_yrs_educ thrd_marrieddummy thrd_loghours thrd_inddummy* thrd_occdummy* thrd_wavedummy* 

reg ford_logrealwage  ford_city5dummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* 
reg ford_logrealwage  attrite ford_city5dummy ford_uniondummy  ford_yrs_educ ford_marrieddummy ford_loghours ford_inddummy* ford_occdummy* ford_wavedummy* 
	
	

	
*Observed count 
*Gen Observed count
sort  pid
by  pid: egen observedcount=count(pid)
tab observedcount



*OLS on observed count


reg logrealwage  city5dummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy*
	forvalues count =1/5 {
		reg logrealwage  city5dummy selfemp uniondummy wavedummy*   blackdummy age age2 femaledummy yrs_educ marrieddummy loghours inddummy* occdummy* if  observedcount==`count'
		}		
	
*Observed count checks if the attributes of those who are observed in everywave are the same
*Observed acccount seems ok.







*Now check for symmetry of city variables


xtset pid wave

gen intocity1=1 if city1dummy==1 & l.city1dummy==0
replace intocity1=0 if intocity1==.
gen outofcity1=1 if city1dummy==0 & l.city1dummy==1
replace outofcity1=0 if outofcity1==.


gen intocity3=1 if city3dummy==1 & l.city3dummy==0
replace intocity3=0 if intocity3==.
gen outofcity3=1 if city3dummy==0 & l.city3dummy==1
replace outofcity3=0 if outofcity3==.


gen intocity5=1 if city5dummy==1 & l.city5dummy==0
replace intocity5=0 if intocity5==.
gen outofcity5=1 if city5dummy==0 & l.city5dummy==1
replace outofcity5=0 if outofcity5==.


gen intocity8=1 if city8dummy==1 & l.city8dummy==0
replace intocity8=0 if intocity8==.
gen outofcity8=1 if city8dummy==0 & l.city8dummy==1
replace outofcity8=0 if outofcity8==.


gen intourban=1 if urbandummy==1 & l.urbandummy==0
replace intourban=0 if intourban==.
gen outofurban=1 if urbandummy==0 & l.urbandummy==1
replace outofurban=0 if outofurban==.


*Into and out of city variables generated


*regular first difference

reg fd_logrealwage fd_city1dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
reg fd_logrealwage intocity1 outofcity1 fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
lincom intocity1 +outofcity1
*a test for whether the city coefficients are equal but of opposite sign

reg fd_logrealwage fd_city3dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
reg fd_logrealwage intocity3 outofcity3 fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
lincom intocity3 +outofcity3


reg fd_logrealwage fd_city5dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
reg fd_logrealwage intocity5 outofcity5 fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
lincom intocity5 +outofcity5


reg fd_logrealwage fd_city8dummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
reg fd_logrealwage intocity8 outofcity8 fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
lincom intocity8 +outofcity8

reg fd_logrealwage fd_urbandummy fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
reg fd_logrealwage intourban outofurban fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 		
lincom intourban +outofurban





*After checking for symmetry. Making the assumption of sequential exogeneity
* Thus can use lagged locations as an IV for moving to or from a large city.

gen lagcity1dummy=l.city1dummy
gen lagcity3dummy=l.city3dummy	
gen lagcity5dummy=l.city5dummy	
gen lagcity8dummy=l.city8dummy	
gen lagurbandummy=l.urbandummy	
	
	
			
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city1dummy= lagcity1dummy), first
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city1dummy= lagcity1dummy)[pweight=weight], first cluster(cluster) 
	
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city3dummy= lagcity3dummy), first
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city3dummy= lagcity3dummy)[pweight=weight], first cluster(cluster) 
	
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city5dummy= lagcity5dummy), first
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city5dummy= lagcity5dummy)[pweight=weight], first cluster(cluster) 
	

ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city8dummy= lagcity8dummy), first
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city8dummy= lagcity8dummy)[pweight=weight], first cluster(cluster) 
	

ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_urbandummy= lagurbandummy), first
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_urbandummy= lagurbandummy)[pweight=weight], first cluster(cluster) 
	
* All the lag variables seem to be correlated with the first difference. However the results arent improved.



* Try using second lag as an instrument

gen lag2city1dummy=l2.city1dummy
gen lag2city3dummy=l2.city3dummy	
gen lag2city5dummy=l2.city5dummy	
gen lag2city8dummy=l2.city8dummy	
gen lag2urbandummy=l2.urbandummy	
	
			
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city1dummy= lag2city1dummy), first
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city1dummy= lag2city1dummy)[pweight=weight], first cluster(cluster) 
	
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city3dummy= lag2city3dummy), first
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city3dummy= lag2city3dummy)[pweight=weight], first cluster(cluster) 
	
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city5dummy= lag2city5dummy), first
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city5dummy= lag2city5dummy)[pweight=weight], first cluster(cluster) 
	

ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city8dummy= lag2city8dummy), first
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_city8dummy= lag2city8dummy)[pweight=weight], first cluster(cluster) 
	

ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_urbandummy= lag2urbandummy), first
ivreg2 fd_logrealwage  fd_uniondummy  fd_yrs_educ fd_marrieddummy fd_loghours fd_inddummy* fd_occdummy* fd_wavedummy* 	(fd_urbandummy= lag2urbandummy)[pweight=weight], first cluster(cluster) 
	

* The second lag variable is correlated with the main explanatory variable, but there arent large changes to the results.
* The results for the main explanatory variable mostly have negative coefficients and are not statistically significant







		