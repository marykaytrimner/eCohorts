** Ethiopia malnutrition analysis
** Analysis 2: IFA adherence figures
** Created by: Emma Clarke-Deelder
** Last update: 8 May 2024


*** IFA ADHERENCE -- FULL SAMPLE

preserve 
	* reshape long
	reshape long m2_ga_r m2_204d_r m2_301_r m2_302_r m2_305_r m2_308_r m2_31_r1 m2_314_r m2_317_r m2_502_r m2_503_r m2_505a_r m2_601a_r m2_603_r m2_604_r m2_date_r interval m2_202_r, i(redcap_record_id) j(interview)
	
	rename m2_ga_r m2_ga
	rename m2_204d_r m2_204d
	rename m2_301_r m2_301
	rename m2_302_r m2_302
	rename m2_305_r m2_305
	rename m2_308_r m2_308
	rename m2_31_r1 m2_31
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

	drop if m2_202!=1
	
	* calculate average by week
	gen m2_ga_round = round(m2_ga)
	bysort m2_ga_round: egen ifa_adherence_average = mean(m2_603)
	bysort m2_ga_round: egen ifa_adherence_average_anemic = mean(m2_603) if hb_under11==1
	
	sort m2_ga_round
	br m2_ga_round ifa_adherence_average
	
	gen ifa_daily = 0 if m2_603==0 | (m2_604!=1 & m2_604<.)
	replace ifa_daily = 1 if m2_604==1
	bysort m2_ga_round: egen ifa_adherence_average_daily = mean(ifa_daily)

	* create figure for portion taking IFA
			 
		twoway (lpolyci ifa_daily m2_ga if m2_ga <40 & m2_ga>20, ylabel(0(.1)1)  xlabel(20(5)40) ///
		xtitle("Gestational age (weeks)") ///
		ytitle("Portion of sample") ///
		legend(order(3 "Portion currently taking IFA daily" 2 "Local polynomial fit" 1 "95% CI")) ///
		scheme(white_tableau)) ///
		(scatter ifa_adherence_average_daily m2_ga_round  if m2_ga_round<=40 & m2_ga_round>=20 ) 
			 gr export "$outputfolder/ifa_adherence_daily.emf", replace
			 
restore


*** IFA ADHERENCE -- ONLY WOMEN WHO CAME IN IN TRIMESTER 1

preserve 

	* restrict sample
	keep if m1_trimester==1

	* reshape long
	reshape long m2_ga_r m2_204d_r m2_301_r m2_302_r m2_305_r m2_308_r m2_31_r1 m2_314_r m2_317_r m2_502_r m2_503_r m2_505a_r m2_601a_r m2_603_r m2_604_r m2_date_r interval m2_202_r, i(redcap_record_id) j(interview)
	
	rename m2_ga_r m2_ga
	rename m2_204d_r m2_204d
	rename m2_301_r m2_301
	rename m2_302_r m2_302
	rename m2_305_r m2_305
	rename m2_308_r m2_308
	rename m2_31_r1 m2_31
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

	drop if m2_202!=1
	
	* calculate average by week
	gen m2_ga_round = round(m2_ga)
	bysort m2_ga_round: egen ifa_adherence_average = mean(m2_603)
	bysort m2_ga_round: egen ifa_adherence_average_anemic = mean(m2_603) if hb_under11==1
	
	gen ifa_daily = 0 if m2_603==0 | (m2_604!=1 & m2_604<.)
	replace ifa_daily = 1 if m2_604==1
	bysort m2_ga_round: egen ifa_adherence_average_daily = mean(ifa_daily)
			 
		twoway (lpolyci ifa_daily m2_ga if m2_ga <40 & m2_ga>20, ylabel(0(.1)1)  xlabel(20(5)40) ///
		xtitle("Gestational age (weeks)") ///
		ytitle("Portion of sample") ///
		legend(order(3 "Portion currently taking IFA daily" 2 "Local polynomial fit" 1 "95% CI")) ///
		scheme(white_tableau)) ///
		(scatter ifa_adherence_average_daily m2_ga_round  if m2_ga_round<=40 & m2_ga_round>=20 ) 
			 gr export "$outputfolder/ifa_adherence_daily_restricted_tri1.emf", replace
			 
restore


*** IFA ADHERENCE -- RESTRICTED SAMPLE

* create figure for portion taking IFA; sample restricted to those who were at 20 weeks or earlier at M1; only show weeks 20 on

	preserve 
	
			* restrict sample to those who enrolled at 20 weeks or earlier 
			keep if m1_ga<=20 
			
			* reshape long
	reshape long m2_ga_r m2_204d_r m2_301_r m2_302_r m2_305_r m2_308_r m2_31_r1 m2_314_r m2_317_r m2_502_r m2_503_r m2_505a_r m2_601a_r m2_603_r m2_604_r m2_date_r interval m2_202_r, i(redcap_record_id) j(interview)
	
	rename m2_ga_r m2_ga
	rename m2_204d_r m2_204d
	rename m2_301_r m2_301
	rename m2_302_r m2_302
	rename m2_305_r m2_305
	rename m2_308_r m2_308
	rename m2_31_r1 m2_31
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

	drop if m2_202!=1
	
	* calculate average by week
	gen m2_ga_round = round(m2_ga)
	bysort m2_ga_round: egen ifa_adherence_average = mean(m2_603)
	bysort m2_ga_round: egen ifa_adherence_average_anemic = mean(m2_603) if hb_under11==1
	
	gen ifa_daily = 0 if m2_603==0 | (m2_604!=1 & m2_604<.)
	replace ifa_daily = 1 if m2_604==1
	bysort m2_ga_round: egen ifa_adherence_average_daily = mean(ifa_daily)
	
	* Make figures
			 
		twoway (lpolyci ifa_daily m2_ga if m2_ga <40 & m2_ga>=20, ylabel(0(.1)1) xlabel(20(5)40) ///
		xtitle("Gestational age (weeks)") ///
		ytitle("Portion of sample") ///
		legend(order(3 "Portion currently taking IFA daily" 2 "Local polynomial fit" 1 "95% CI")) ///
		scheme(white_tableau)) ///
		(scatter ifa_adherence_average_daily m2_ga_round if m2_ga <40 & m2_ga>=20) 
			 gr export "$outputfolder/ifa_adherence_daily_restrictedsamp.emf", replace
			 
restore


