** Ethiopia malnutrition analysis
** Analysis 4: Longitudinal figures of weight and blood monitoring
** Created by: Emma Clarke-Deelder
** Last update: 26 March 2025


*** TREND FIGURES
use "$datafolder/econut_analyticdata_10sept2025.dta", clear

preserve 
	* reshape long
	reshape long m2_ga_r m2_301_r m2_302_r m2_305_r m2_308_r m2_314_r m2_317_r m2_502_r m2_503_r m2_505a_r m2_601a_r m2_603_r m2_604_r m2_date_r m2_202_r m2_501b_r m2_501c_r m2_501d_r, i(redcap_record_id) j(interview)
	
	rename m2_ga_r m2_ga
	rename m2_301_r m2_301
	rename m2_302_r m2_302
	rename m2_305_r m2_305
	rename m2_308_r m2_308
	rename m2_314_r m2_314
	rename m2_317_r m2_317
	rename m2_502_r m2_502
	rename m2_503_r m2_503
	rename m2_505a_r m2_505a
	rename m2_601a_r m2_601a
	rename m2_603_r m2_603
	rename m2_604_r m2_604
	rename m2_date_r m2_date
	rename m2_202_r m2_202
	rename m2_501b_r m2_501b
	rename m2_501c_r m2_501c
	rename m2_501d_r m2_501d

	drop if m2_202!=1
	
	* calculate average by week
	gen m2_ga_round = round(m2_ga)
	bysort m2_ga_round: egen weight_monitored = mean(m2_501b)
	
	gen m2_blood_any = m2_501c 
	replace m2_blood_any = 1 if m2_501d==1
	bysort m2_ga_round: egen blood_tested = mean(m2_blood_any)
		
	* create figure for portion who report monitoring since last interview
	twoway (lpolyci m2_501b m2_ga if m2_ga <40 & m2_ga>20, ylabel(0(.1)1)  xlabel(20(5)40) ///
		xtitle("Gestational age (weeks)") ///
		legend(order(3 "Portion who report weight monitoring since last interview" 2 "Local polynomial fit" 1 "95% CI")) ///
		scheme(white_tableau)) ///
		(scatter weight_monitored m2_ga_round  if m2_ga_round<=40 & m2_ga_round>=20 ) 
			 gr export "$outputfolder/weight_monitoring.emf", replace
			 
		twoway (lpolyci m2_blood_any m2_ga if m2_ga <40 & m2_ga>20, ylabel(0(.1)1)  xlabel(20(5)40) ///
		xtitle("Gestational age (weeks)") ///
		legend(order(3 "Portion who report blood testing since last interview" 2 "Local polynomial fit" 1 "95% CI")) ///
		scheme(white_tableau)) ///
		(scatter blood_tested m2_ga_round  if m2_ga_round<=40 & m2_ga_round>=20 ) 
			 gr export "$outputfolder/blood_testing.emf", replace
			 
restore


*** CUMULATIVE MONITORING FIGURES

preserve 
	* reshape long
	reshape long m2_ga_r m2_301_r m2_302_r m2_305_r m2_308_r m2_311_r m2_314_r m2_317_r m2_502_r m2_503_r m2_505a_r m2_601a_r m2_603_r m2_604_r m2_date_r m2_202_r m2_501b_r m2_501c_r m2_501d_r, i(redcap_record_id) j(interview)
	
	rename m2_ga_r m2_ga
	rename m2_301_r m2_301
	rename m2_302_r m2_302
	rename m2_305_r m2_305
	rename m2_308_r m2_308
	rename m2_311_r m2_311
	rename m2_314_r m2_314
	rename m2_317_r m2_317
	rename m2_502_r m2_502
	rename m2_505a_r m2_505a
	rename m2_601a_r m2_601a
	rename m2_603_r m2_603
	rename m2_604_r m2_604
	rename m2_date_r m2_date
	rename m2_202_r m2_202
	rename m2_501b_r m2_501b
	rename m2_501c_r m2_501c
	rename m2_501d_r m2_501d

	drop if m2_202!=1
	

* variable for the number of weight measures since last interview
	egen routine_visits_since_last_call = rowtotal(m2_305 m2_308 m2_311 m2_314 m2_317)
	gen weight_measures_since_last_call = m2_501b*routine_visits_since_last_call 
	replace weight_measures_since_last_call = 1 if m2_501b==1 & routine_visits_since_last_call==0 
	
* cumulative weight measures
	gen m2_ga_round = round(m2_ga)

	bysort redcap_record_id (m2_ga_round) : gen m2_weight_cumulative  = sum(weight_measures_since_last_call) 
	br redcap_record_id m2_ga_round weight_measures_since_last_call m2_weight_cumulative
	
	gen weight_measures_cumulative = m2_weight_cumulative + m1_701 // adding 1 for the weight measure at baseline
	
	br redcap_record_id m1_701 m2_ga_round weight_measures_since_last_call m2_weight_cumulative weight_measures_cumulative
	
	bysort m2_ga_round: egen weight_measures_cumulative_avg = mean(weight_measures_cumulative)
	bysort m2_ga_round: egen weight_measures_cumulative_p25 = pctile(weight_measures_cumulative),p(25)
	bysort m2_ga_round: egen weight_measures_cumulative_p75 = pctile(weight_measures_cumulative),p(75)
	
	gen weight_measures_cumulative_maln = weight_measures_cumulative // anemic version
	replace weight_measures_cumulative_maln = . if muac_under23==0
	bysort m2_ga_round: egen weight_measures_cum_maln_avg = mean(weight_measures_cumulative_maln)
	
	tab weight_measures_cumulative_avg if m2_ga==20 
	tab weight_measures_cumulative_avg if m2_ga==40 

	
	twoway (lpolyci weight_measures_cumulative m2_ga if m2_ga <40 & m2_ga>20, ylabel(0(1)5)  xlabel(20(5)40) ///
		xtitle("Gestational age (weeks)") ///
		ytitle("Cumulative number of measures") ///
		legend(order(3 "Cumulative number of weight measures" 2 "Local polynomial fit" 1 "95% CI")) ///
		scheme(white_tableau)) ///
		(scatter weight_measures_cumulative_avg m2_ga_round  if m2_ga_round<=40 & m2_ga_round>=20 ) 
			 gr export "$outputfolder/weight_monitoring_cumulative.emf", replace
			 
	twoway (lpolyci weight_measures_cumulative_maln m2_ga if m2_ga <40 & m2_ga>20, ylabel(0(1)5)  xlabel(20(5)40) ///
		xtitle("Gestational age (weeks)") ///
		ytitle("Cumulative number of measures") ///
		legend(order(3 "Cumulative number of weight measures" 2 "Local polynomial fit" 1 "95% CI")) ///
		scheme(white_tableau)) ///
		(scatter weight_measures_cum_maln_avg m2_ga_round  if m2_ga_round<=40 & m2_ga_round>=20 ) 
			 gr export "$outputfolder/weight_monitoring_cumulative_malnourished.emf", replace
	
	
* cumulative blood tests 
	gen m2_blood_any = m2_501c 
	replace m2_blood_any = 1 if m2_501d==1
	bysort m2_ga_round: egen blood_tested = mean(m2_blood_any)
	
	gen blood_since_last_call = m2_blood_any*routine_visits_since_last_call 
	replace blood_since_last_call =1 if m2_blood_any==1 & routine_visits_since_last_call==0 
	bysort redcap_record_id (m2_ga_round) : gen m2_blood_cumulative  = sum(blood_since_last_call) 
	
	gen blood_measures_cumulative = m2_blood_cumulative + blooddraw_any_anc1_binary // adding 1 for the weight measure at baseline
	bysort m2_ga_round: egen blood_measures_cumulative_avg = mean(blood_measures_cumulative)
	
	gen blood_measures_cumulative_anemic = blood_measures_cumulative // anemic version
	replace blood_measures_cumulative_anemic = . if hb_under11==0
	bysort m2_ga_round: egen blood_measures_cum_anemic_avg = mean(blood_measures_cumulative_anemic)
	

	twoway (lpolyci blood_measures_cumulative m2_ga if m2_ga <40 & m2_ga>20, ylabel(0(1)3)  xlabel(20(5)40) ///
		xtitle("Gestational age (weeks)") ///
		ytitle("Cumulative number of tests") ///
		legend(order(3 "Cumulative number of blood tests" 2 "Local polynomial fit" 1 "95% CI")) ///
		scheme(white_tableau)) ///
		(scatter blood_measures_cumulative_avg m2_ga_round  if m2_ga_round<=40 & m2_ga_round>=20 )
			 gr export "$outputfolder/blood_testing_cumulative.emf", replace

	twoway (lpolyci blood_measures_cumulative_anemic m2_ga if m2_ga <40 & m2_ga>20, ylabel(0(1)3)  xlabel(20(5)40) ///
		xtitle("Gestational age (weeks)") ///
		ytitle("Cumulative number of tests") ///
		legend(order(3 "Cumulative number of blood tests" 2 "Local polynomial fit" 1 "95% CI")) ///
		scheme(white_tableau)) ///
		(scatter blood_measures_cum_anemic_avg m2_ga_round  if m2_ga_round<=40 & m2_ga_round>=20 ) 
			 gr export "$outputfolder/blood_testing_cumulative_anemia.emf", replace
			 


	

	