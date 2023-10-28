# cmt_pleiotropy
Using complete mediation test to identify pleiotropic genetic variants for Mendelian randomization study 

Description

The cmt_pleiotropy R function is designed to use Complete Mediation Test (CMT) to diagnose pleiotropic genetic variants for Mendelian randomization study

data requirement

The data to be analyzed must contain an outcome variable Y, an exposure variable X, and a set of genetic variants G1-Gk.
We assume these Gs had been screened (e.g., by GWAS) an are legitimate instrumental variables satisfying the following conditions     
(1) G is correlated with Y (in a regression),
(2) G is correlated with X  

Criteria

Individual pleiotropy test: a genetic variant is identified as pleiotropic if both the followings are satisfied:
(1) The null hypothes H0 is rejected, where H0: X is a complete mediator of G-Y association, or equivalently, no G-Y direct effect
(2) proportion mediation effect (i.e. indirect effect) <80% (default)  

Installation

Before using the cmt_pleiotropy function, make sure you have the required R packages installed.
If not, you can install them using the following commands:

install.packages("bda")
install.packages("multilevel")
install.packages("dplyr")

Usage

cmt_pleiotropy (outcome,exposure,G,data, Bootstrap_times, prop)

Arguments

Outcome					character, name of the outcome variable(numerical). 
exposure 				character, name of the exposure variable(numerical).
G 						vector of characters, name(s) of the SNP(s).
data 					dataframe.
Bootstrap_times 			number of bootstrap times.The default is 50.
prop 					proportion threshold.The default is 0.8.

Value

prop.med  				the proportion of the effect that is mediated.(αβ/C)
Signif		 			"*" indicating pleiotropy.
Signif.level 				0.05 / numbers of G

Examples

	#Please download the data first.
	library(readxl)
	gout <- read_excel("C:/Users/ User-Name/Downloads/gout.xlsx")
	result <- cmt_pleiotropy(outcome="gout",                                                                                     
	                         exposure="bmi",
	                         G=colnames(gout)[-c(1,12)],
	                         data=gout,
	                         Bootstrap_times = 100, prop = 0.8)
	result
	$Outcome
	[1] "gout"

	$Exposure
	[1] "bmi"

	$N
	[1] 268

	$SNPs
	 [1] "rs11731353_C" "rs61794965_G" "rs16890979_T" "rs3775948_G"  	"rs10516801_T" "rs2725211_T"  "rs12505410_G" "rs2231142_T" 
	 [9] "rs72552713_A" "rs4148155_G" 

	$CMT_value
	             prop.med Statistics P_Value Signif
	rs11731353_C  2.88041     7.4426 0.00000      .
	rs61794965_G  3.83185    -0.1760 0.86027      .
	rs16890979_T  0.16047    -2.3108 0.02084      .
	rs3775948_G   2.26691    -2.8283 0.00468      .
	rs10516801_T  3.63320    -6.1847 0.00000      .
	rs2725211_T   0.03337    -1.2834 0.19936      .
	rs12505410_G  0.12134     2.3069 0.02106      .
	rs2231142_T   0.02737    -3.3277 0.00088      *
	rs72552713_A  0.22751    -2.8369 0.00456      *
	rs4148155_G   0.02737    -3.3277 0.00088      *

	$Signif.level
	[1] 0.005

	$Note
	[1] "* indicating pleiotropy"                                                              
	[2] "prop.med means the proportion of the effect that is mediated.(αβ/C)"                  
	[3] "The function automatically handles missing values by omitting rows with 	missing data."
	
	$proportion.threshold
	[1] 0.8

Contact Information
If you have any questions or need assistance, you can contact maiblian@gm.ncue.edu.tw 

