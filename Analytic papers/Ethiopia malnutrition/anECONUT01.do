** Ethiopia malnutrition analysis
** Analysis 1: Descriptive tables
** Created by: Emma Clarke-Deelder
** Last update: 8 May 2024


*** Analysis of prevalence and patient characteristics ***************************

	tab1 muac_under23 hb_under11 malnourished_double 
	
*** Table 1:
	
	* Describe characteristics by group	
	
	#delimit ;
	table1_mc, by(muac_under23)  
	vars( 
	site cat \
	sampstrata cat \
	m1_enrollage contn \
	m1_1001 contn \
	m1_height_cm contn \ 
	m1_weight_kg contn \
	past_complications bin \
	comorbidity bin \
	formalemployment bin \
	education_simp cat \
	m1_1221 bin \
	quintile cat \
	m1_trimester cat  \
	routine_consults_atleast4 bin \
	)  
	nospace percent onecol total(before) 
	saving("$outputfolder/sample_characteristics_bymuac.xlsx", replace)
	;
	#delimit cr
	
	#delimit ;
	table1_mc, by(hb_under11)  
	vars( 
	site cat \
	sampstrata cat \
	m1_enrollage contn \
	m1_1001 contn \
	m1_height_cm contn \ 
	m1_weight_kg contn \
	past_complications bin \
	comorbidity bin \
	formalemployment bin \
	education_simp cat \
	m1_1221 bin \
	quintile cat \
	m1_trimester cat  \
	routine_consults_atleast4 bin \
	)  
	nospace percent onecol total(before) 
	saving("$outputfolder/sample_characteristics_byanemia.xlsx", replace)
	;
	#delimit cr

*** Table S2
	
	* characteristics of facilities use for ANC1 
	
	global facility_vars m0_a6_fac_type m0_a8_fac_own m0_a9_urban facility_anc1volume facility_ancrepeatvolume fac_bp_any fac_bp_functioning fac_scale_any fac_scale_functioning fac_measuringtape_any fac_measuretape_functioning fac_haemoglobintest_any fac_haemoglobintest_onsite
	
	drop count
	bysort facility: gen count=_n
	
	preserve 
	keep if count==1  // first - count each facility once
	#delimit ;
	table1_mc,  
	vars( 
	m0_a6_fac_type cat \
	m0_a8_fac_own cat \
	m0_a9_urban cat \
	facility_anc1volume contn \
	facility_ancrepeatvolume contn \ 
	fac_bp_any bin \
	fac_bp_functioning bin \
	fac_scale_any bin \
	fac_scale_functioning bin \
	fac_measuringtape_any bin \
	fac_measuretape_functioning bin \
	fac_haemoglobintest_any bin \
	fac_haemoglobintest_onsite bin \
	)  
	nospace percent onecol total(before) 
	saving("$outputfolder/facility_characteristics.xlsx", replace)
	;
	#delimit cr
	restore
	
	#delimit ;
	table1_mc, by(muac_under23) // second - by MUAC
	vars( 
	m0_a6_fac_type cat \
	m0_a8_fac_own cat \
	m0_a9_urban cat \
	facility_anc1volume contn \
	facility_ancrepeatvolume contn \ 
	fac_bp_any bin \
	fac_bp_functioning bin \
	fac_scale_any bin \
	fac_scale_functioning bin \
	fac_measuringtape_any bin \
	fac_measuretape_functioning bin \
	fac_haemoglobintest_any bin \
	fac_haemoglobintest_onsite bin \
	)  
	nospace percent onecol total(before) 
	saving("$outputfolder/facility_characteristics_bymuac.xlsx", replace)
	;
	#delimit cr
	
	#delimit ;
	table1_mc, by(hb_under11) 
	vars( 
	m0_a6_fac_type cat \
	m0_a8_fac_own cat \
	m0_a9_urban cat \
	facility_anc1volume contn \
	facility_ancrepeatvolume contn \ 
	fac_bp_any bin \
	fac_bp_functioning bin \
	fac_scale_any bin \
	fac_scale_functioning bin \
	fac_measuringtape_any bin \
	fac_measuretape_functioning bin \
	fac_haemoglobintest_any bin \
	fac_haemoglobintest_onsite bin \
	)  
	nospace percent onecol total(before) 
	saving("$outputfolder/facility_characteristics_byanemia.xlsx", replace)
	;
	#delimit cr
	
*** Descriptive tables: quality of care *****************************************************************************

	global screening m1_702 m1_701 m1_703 blooddraw_any_anc1_binary 
	
	global prevention ifapills_firstanc antimalarial_anc1 nutri_counseling_anc1 
	
	global counseling nutri_counseling_anc1 told_when_to_come_back knows_anemic_anc1
		
	global treatment nutrisup_anc1 
	
	global record m1_1306 weight_recorded
	
**** Table 2: Content of ANC1

	sum $screening $prevention $counseling $treatment $record, sep(0)
	sum $screening $prevention $counseling $treatment $record if muac_under23==1, sep(0)
	sum $screening $prevention $counseling $treatment $record if hb_under11==1, sep(0)
	sum $screening $prevention $counseling $treatment $record if bmi_under18p5==1 & m1_trimester==1, sep(0)
	sum $screening $prevention $counseling $treatment $record if anemia_adj==1, sep(0)

	tab m1_713a
	
			 
***** Figure 1: Quality of follow-up ANC care

	* monitoring
	sum weight_ever weight_atleast2 weight_atleast8 if muac_under23==1 
	sum bloodtests_ever bloodtests_atleast2 bloodtests_atleast3 if hb_under11==1
	
	* treatment
	sum nutrisup_everpreg if muac_under23==1 
	sum ifapills_everduringpregnancy ifa_adherence_complete_daily if hb_under11==1
	
	* counseling
	sum nutri_counseling_anc1 delivery_counseled_nutrition if muac_under23==1 
	sum nutri_counseling_anc1 delivery_counseled_nutrition if hb_under11==1
	
	tab fac_haemoglobintest_onsite if hb_under11==1 // 40% have it
	
	* sensitivity
	sum weight_ever weight_atleast2 weight_atleast8 if bmi_under18p5==1 & m1_trimester==1
	sum nutrisup_everpreg if bmi_under18p5==1 & m1_trimester==1
	sum nutri_counseling_anc1 delivery_counseled_nutrition if bmi_under18p5==1 & m1_trimester==1

	sum bloodtests_ever bloodtests_atleast2 bloodtests_atleast3 if anemia_adj==1
	sum ifapills_everduringpregnancy ifa_adherence_complete_daily if anemia_adj==1
	sum nutri_counseling_anc1 delivery_counseled_nutrition if anemia_adj==1

	
	
**** Table S4: 
	gen multi_and_ifa_firstanc = 0 if ifapills_firstanc<. & multivitamins_firstanc<.
	replace multi_and_ifa_firstanc = 1 if ifapills_firstanc==1 & multivitamins_firstanc==1
	
	gen multi_and_ifa_everpreg = 0 if ifapills_everduringpregnancy < . & multivitamins_everpreg<.
	replace multi_and_ifa_everpreg = 1 if ifapills_everduringpregnancy==1 & multivitamins_everpreg==1
	

	global appendix_meds multivitamins_firstanc multi_and_ifa_firstanc calcium_firstanc deworming_firstanc antimalarial_anc1 bednet_anc1 bednet_counseling_anc1  multivitamins_everpreg  multi_and_ifa_everpreg calcium_everpreg deworming_everpreg antimalarial_everpreg
	sum $appendix_meds, sep(0)
	sum $appendix_meds if muac_under23==1, sep(0)
	sum $appendix_meds if hb_under11==1, sep(0)
	
	
***** MISSING DATA TABLE

	foreach var in site sampstrata m1_enrollage m1_1001 m1_height_cm m1_weight_kg past_complications comorbidity formalemployment education_simp m1_1221 quintile m1_trimester routine_consults_atleast4 m1_702 m1_701 m1_703 blooddraw_any_anc1_binary ifapills_firstanc antimalarial_anc1 nutri_counseling_anc1 told_when_to_come_back knows_anemic_anc1 nutrisup_anc1 m1_1306 weight_recorded weight_ever weight_atleast2 weight_atleast7 nutrisup_everpreg ifapills_everduringpregnancy ifa_adherence_complete_daily  delivery_counseled_nutrition  {
		gen `var'_m = 0
		replace `var'_m = 1 if `var'==. | `var'==.a | `var'==.d | `var'==.r
	}
	
	sum *_m
	sum *_m if muac_under23==1
	sum *_m if hb_under11==1