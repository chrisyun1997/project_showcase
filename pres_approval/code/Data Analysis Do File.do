***Cleaning the June 2009 data
***Chris Yun, Janet Malzahn
capture log close
clear all
***log using "Data Analysis", replace
use "June2009UNCLEAN"

*****************
*Variable Cleaning
*****************

**Keeps the variables we want
keep sex age educ racethn hh1 hh2 income party employ scregion q23 q24 q25 q26 q2

**Renames the variables
rename q23 econcountry
rename q24 econcountryfuture
rename q25 persfin
rename q26 persfinfuture
rename q2 presatt
rename hh1 famsize
rename hh2 children

**Drops people who don't have op abt president
drop if presatt == 9.0
keep if age != 99
keep if famsize != 99
keep if econcountry !=9
keep if econcountryfuture != 9
keep if persfin != 9
keep if persfinfuture !=9
keep if income != 10
*keep if children != 99
keep if employ != 9
keep if educ != 9
drop if children == .
drop if racethn == 9

**Relabel level of employment
gen level_employ = 1 if employ == 1.0
replace level_employ = 1 if employ == 2.0
replace level_employ = 0 if employ == 3.0

*Relabel party
gen party_dem = 1 if party == 2
replace party_dem = 0 if party != 2

*Recasting sex (1 means male after the change)
replace sex = 0 if sex == 1
replace sex = 1 if sex == 2
*recasting presatt
replace presatt = 0 if presatt == 2

*Making a new variable for income level
gen level_income = 0 
replace level_income = 1 if income >= 4 & income <= 6
replace level_income = 2 if income >=7 & income <= 9

*Recasting Econ Country Future
/*replace econcountryfuture = 0 if econcountryfuture == 2
replace econcountryfuture = 4 if econcountryfuture == 1
replace econcountryfuture = 1 if econcountryfuture == 3
replace econcountryfuture = 2 if econcountryfuture == 4 */

gen econcountryfuturenew = 0 
replace econcountryfuturenew = 2 if econcountryfuture == 1
replace econcountryfuturenew = 1 if econcountryfuture == 3

*Making attitudinal variables into dummies
gen persfinfutureworse = 0
replace persfinfutureworse = 1 if persfinfuture == 4 | persfinfuture == 3
gen persfinfuturesame = 0
replace persfinfuturesame = 1 if persfinfuture == 5
gen persfinfuturebetter = 0 
replace persfinfuturebetter = 1 if persfinfuture == 1 | persfinfuture == 2

*Lumping all attudinal variables 
gen poseconcountry = 1 
replace poseconcountry = 0 if econcountry == 3 | econcountry ==4

gen pospersfin = 1
replace pospersfin = 0 if persfin == 4 | persfin == 3

*Interactions
*gen inter_partyposeconcountry = poseconcountry *party_dem
gen inter_partypospersfin = pospersfin* party_dem
gen inter_partypersfinfutureworse = persfinfutureworse * party_dem
gen inter_partypersfinfuturesame = persfinfuturesame * party_dem
gen inter_partypersfinfuturebetter = persfinfuturebetter * party_dem

**************************
*Statistics and Histograms
**************************

*Stats of continuous variables
/*
summarize age
hist age, freq

summarize famsize
hist famsize, freq

summarize children
hist children, freq

*distributions of children for first men then women
bysort sex: summarize children
hist children if sex == 1
hist children if sex == 2

*tabulations of categorical variables
tab persfin
tab persfinfuture
tab income
tab econcountry
tab econcountryfuture
tab racethn
tab level_employ
tab educ
tab presatt
tab scregion
tab sex
tab party


*Test difference in means
ttest income, by(party_dem)
ttest income, by(sex)
*/

*************
*Regressions 
*************
reg presatt sex age i.racethn i.scregion i.level_income level_employ i.educ children famsize
estimate store R

reg presatt sex age i.racethn i.scregion i.level_income level_employ i.educ children famsize ///
poseconcountry i.econcountryfuturenew pospersfin persfinfutureworse persfinfuturebetter 
estimate store A

reg presatt sex age i.racethn i.scregion i.level_income level_employ i.educ children famsize ///
poseconcountry i.econcountryfuturenew pospersfin persfinfutureworse persfinfuturebetter party_dem
estimate store B


reg presatt sex age i.racethn i.scregion i.level_income level_employ i.educ children famsize ///
poseconcountry i.econcountryfuturenew pospersfin persfinfutureworse persfinfuturebetter  party_dem  ///
inter_partypospersfin inter_partypersfinfutureworse inter_partypersfinfuturebetter 

estimate store C

probit presatt sex age i.racethn i.scregion i.level_income level_employ i.educ children famsize ///
poseconcountry i.econcountryfuturenew pospersfin persfinfutureworse persfinfuturebetter party_dem ///
inter_partypospersfin inter_partypersfinfutureworse inter_partypersfinfuturebetter

margins, dydx(*) atmeans

logit presatt sex age i.racethn i.scregion i.level_income level_employ i.educ children famsize ///
poseconcountry i.econcountryfuturenew pospersfin persfinfutureworse persfinfuturebetter party_dem ///
inter_partypospersfin inter_partypersfinfutureworse inter_partypersfinfuturebetter 

******************
*Regression Tests
******************

lrtest R A, force
lrtest A B, force
lrtest B C, force

***log close 
