** Ethiopia malnutrition analysis
** Analysis 3: Regression analysis
** Created by: Emma Clarke-Deelder
** Last update: 7 June 2024



	
* REGRESSION ANALYSIS 

reshape long m2_ga_r m2_204d_et_r m2_301_r m2_302_r m2_305_r m2_308_r m2_311_r m2_314_r m2_317_r m2_502_r m2_503_r m2_505a_r m2_601a_r m2_603_r m2_604_r m2_date_r interval m2_202_r m2_205a_r m2_205b_r m2_205c_r m2_205d_r m2_205e_r m2_205f_r m2_205g_r m2_205h_r m2_205i_r, i(redcap_record_id) j(interview)
	
	rename m2_ga_r m2_ga
	rename m2_204d_et_r m2_204d
	rename m2_301_r m2_301
	rename m2_302_r m2_302
	rename m2_305_r m2_305
	rename m2_308_r m2_308
	rename m2_311_r m2_311
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
	rename m2_205a_r m2_205a
	rename m2_205b_r m2_205b
	rename m2_205c_r m2_205c
	rename m2_205d_r m2_205d
	rename m2_205e_r m2_205e
	rename m2_205f_r m2_205f
	rename m2_205g_r m2_205g
	rename m2_205h_r m2_205h
	rename m2_205i_r m2_205i

	drop if m2_202!=1
	
	* setup data as panel 

	* recode some covariates
	gen m2_ga_4weeks = m2_ga/4
	
	gen time_since_anc1_weeks = (m2_date - m1_date)/7 
	gen time_since_anc1_4weeks = (m2_date - m1_date)/28
	tab time_since_anc1_4weeks, m
		
	rename m2_601a ifapills_sincelastcall
	
	gen time_ifapills_interaction = time_since_anc1_4weeks*ifapills_sincelastcall
	
	gen new_pos_anemia_test = m2_505a 
		replace new_pos_anemia_test = 0 if m2_502==0 | m2_503==0
		tab new_pos_anemia_test // only 3% of calls
		
	gen m2_603daily=m2_603
	replace m2_603daily = 0 if m2_604!=1 & m2_603<.
	
	gen m2_anemiabelief = m2_204d 
	
	replace ifapills_firstanc = 2 if m1_713a==2 
	label define ifapills_firstanc 0 "Not given or prescribed" 1 "Given directly" 2 "Prescribed"
	label values ifapills_firstanc ifapills_firstanc
	
	* Define globals for model covariates
		
	tab m1_enrollage_cat, gen(age_cat)	
	tab education, gen(edu_cat)
	tab quintile, gen (quintile_cat) 
	tab sampstrata, gen(sampstrata_cat)
	tab m0_a9_urban, gen (urban_cat)
	tab facility, gen (facility_cat)
	tab anemia_sev, gen(anemia_cat)
	tab ifapills_firstanc, gen(ifapills_firstanc_cat)
	tab education_simp, gen(education_simp_cat)
		
	global timevarying time_since_anc1_4weeks
	global maternal_characteristics ///
			age_cat2 age_cat3 ///
			formalemployment ///
			education_simp_cat2 education_simp_cat3 ///
			quintile_cat2 quintile_cat3 quintile_cat4 quintile_cat5 ///
			past_complications ///
			comorbidity ///
			firstpregnancy  ///
			m1_ga_4weeks ///
			depress ///
			anemia_cat2 anemia_cat3 ///
			knows_anemic_anc1 ///
			ifapills_firstanc_cat2 ifapills_firstanc_cat3 
	global facility_characteristics sampstrata_cat1 sampstrata_cat2 sampstrata_cat3 urban_cat1 urban_cat2 
	global facility_id facility_cat1 facility_cat2 facility_cat3 facility_cat4 facility_cat5 facility_cat6 facility_cat7 facility_cat8 facility_cat9 facility_cat10 facility_cat11 facility_cat12 facility_cat13 facility_cat14 facility_cat15 facility_cat16 facility_cat17 facility_cat18
	
	* Check covariance structure 
	
	* Variogram for the main outcome: 
	variog m2_603daily 
	
* CHOOSE CORRELATION STRUCTURE	
	encode redcap_record_id, gen(redcap_record_id1)
	gen m2_ga_daily = m2_ga*7 
	gen m2_ga_daily_round = round(m2_ga_daily)
	
	
	* WITH FACILITY FIXED EFFECTS
	qic m2_603daily $timevarying $maternal_characteristics  $facility_id, i(redcap_record_id1) t(m2_ga_daily_round) family(bin) link(logit) corr(exchangeable) robust // QIC=3308.382	
	
	* WITH FACILITY CHARACTERISTICS	
	qic m2_603daily $timevarying $maternal_characteristics  $facility_characteristics, i(redcap_record_id1) t(m2_ga_daily_round) family(bin) link(logit) corr(exchangeable) robust // QIC=3579.412
	
	
**** RUN REGRESSIONS
	
	 eststo clear
	 
	* Main model
	eststo: quietly xtgee m2_603daily $timevarying $maternal_characteristics $facility_id, family(bin) link(logit) corr(exchangeable) vce(robust)

	* Sensitivity 1: with facility characteristics
	eststo: quietly xtgee m2_603daily $timevarying $maternal_characteristics $facility_characteristics, family(bin) link(logit) corr(exchangeable) vce(robust)	
	
	* Sensitivity 2: restricted sample
	eststo: quietly xtgee m2_603daily $timevarying $maternal_characteristics i.facility if m1_ga<=20 & m2_ga>=20, family(bin) link(logit) corr(exchangeable) vce(robust)

	esttab, eform cells("b(star fmt(2)) p(fmt(2)) ci(fmt(2))")
	
	* Sensitivity 3: linear regression
	eststo clear 
	eststo: quietly xtgee m2_603daily $timevarying $maternal_characteristics $facility_id, family(gaussian) link(identity) corr(exchangeable) vce(robust)
	
	* Sensitivity 4: linear regression with woman fixed effects
	eststo: regress m2_603daily $timevarying i.redcap_record_id1, robust
	
	esttab, cells("b(star fmt(2)) p(fmt(2)) ci(fmt(2))")
	
	
****

	* Appendix figure

	* Identify the last call each woman received within each trimester
	gen m2_ga_trimester = 1 if m2_ga<13 
	replace m2_ga_trimester = 2 if m2_ga>=13 & m2_ga<=27 
	replace m2_ga_trimester = 3 if m2_ga>27
	sort m2_date
	bysort redcap_record_id: gen call_number = _n 
	egen maxcall_withintri = max(call_number), by(redcap_record_id m2_ga_trimester)

	gen lastcall_2ndtri = 1 if m2_ga_trimester==2 & call_number==maxcall_withintri
	gen lastcall_3rdtri = 1 if m2_ga_trimester==3 & call_number==maxcall_withintri

	tab lastcall_2ndtri  //664
	tab lastcall_3rdtri // 768 
	replace lastcall_2ndtri=. if interval<4 | interval>8 // 633
	replace lastcall_3rdtri=. if interval<4 | interval>8 // 692
	
	bysort redcap_record_id: egen lastcall_2ndtri_pos = total(lastcall_2ndtri)
	bysort redcap_record_id: egen lastcall_3rdtri_pos = total(lastcall_3rdtri)
	gen table_eligible = 0
	replace table_eligible = 1 if lastcall_2ndtri_pos==1 & lastcall_3rdtri_pos==1
	unique redcap_record_id if table_eligible==1 // 564
	
	gen visit_ifapills = .
	replace visit_ifapills = 0 if m2_301==0 
	replace visit_ifapills = 1 if m2_301==1 & ifapills_sincelastcall==0 
	replace visit_ifapills = 2 if m2_301==1 & ifapills_sincelastcall==1 
	
	gen ifa_freq = m2_603
	replace ifa_freq = 2 if m2_603daily==1
	
	tab ifa_freq visit_ifapills  if lastcall_2ndtri==1 & table_eligible==1, col
	tab ifa_freq visit_ifapills  if lastcall_3rdtri==1 & table_eligible==1, col

	