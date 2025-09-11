** Ethiopia malnutrition analysis
** Create 1: Sample set-up and creation of variables
** Created by: Emma Clarke-Deelder
** Last update: 11 April 2025

***************************************************************************************************
*** 0) Set-up *************************************************************************************
***************************************************************************************************

* Open wide dataset
use "eco_ET_Complete", clear

* Define study sample
gen muac_available = 0
replace muac_available = 1 if m1_muac!=. & m1_muac!=999 

gen hb_available = 0
replace hb_available = 1 if m1_1307<. | m1_1309<.

unique redcap_record_id // N=1000
tab m3_501, m

* How many of them were followed up through M3? (completed M3-part 1)
br redcap_record_id m3_* if m3_303b==. | m3_303b==.a  | m3_501==.
keep if m3_303b!=. & m3_303b!=.a  & m3_501!=. // 113 observations deleted; did not complete M3 part 1
unique redcap_record_id // 887 remaining

* How many had live births or stillbirths (not abortion or miscarriage)?
tab birth_outcome,m
*keep if birth_outcome!=6 & birth_outcome!=7  // 24 observations deleted (miscarriages)
drop if m3_202==4 | m3_202==5 // 5 observations deleted (incomplete follow-up)
tab birth_outcome // N=858

* How many have MUAC information available?
keep if muac_available==1 // 3 observations dropped
unique redcap_record_id // N=855

* How many have Hb information available?
keep if hb_available ==1 // 45 observations dropped
tab hb_available // N=810

***************************************************************************************************
*** 1) Clean and create variables *****************************************************************
***************************************************************************************************

* Maternal characteristics

	*  MUAC
	replace m1_muac = . if m1_muac==999
	tab m1_muac, m 
	
	*  Hb measured
	tab m1_1307, m  
	tab m1_1309, m 
	gen hb_measured = m1_1307 
	replace hb_measured = m1_1309 if hb_measured==. | hb_measured==.a
	label var hb_measured "Haemoglobin value (measured either during visit or after)"
	tab hb_measured, m 
	br redcap_record_id m1_1307 m1_1309 hb_measured

	*  MUAC <23
	gen muac_under23 = 0 if m1_muac<.
	replace muac_under23 = 1 if m1_muac<23 
	label var muac_under23 "MUAC under 23"
	tab muac_under23, m
	label var muac_under23 "Underweight"
	
	*  Hb < 11
	gen hb_under11 = 0 if hb_measured<. 
	replace hb_under11 = 1 if hb_measured<11
	label var hb_under11 "Hb under 11"
	tab hb_under11, m 
	label var hb_under11 "Anemic"
	
	* Hb category 
	gen anemia_sev = 0 if hb_measured>=11 & hb_measured<. // no anemia
	replace anemia_sev = 1 if hb_measured >=10 & hb_measured<11 // mild
	replace anemia_sev = 2 if hb_measured >=7 & hb_measured<10 // moderate
	replace anemia_sev = 3 if hb_measured <7 // severe
	tab anemia_sev
	label define anemia_sev 0 "No anemia" 1 "Mild anemia" 2 "Moderate anemia" 3 "Severe anemia"
	label values anemia_sev anemia_sev
	label var anemia_sev "Anemia (severity)"
	
	* Altitude and trimester-adjusted anemia
	gen hb_altadjusted = hb_measured - 1.1
	label var hb_altadjusted "Altitude-adjusted Hb level"
	
	gen anemia_sev_adj = 0 if hb_altadjusted>=11 & hb_altadjusted<.  // no anemia
	replace anemia_sev_adj = 1 if hb_altadjusted >=10 & hb_altadjusted<11 // mild
	replace anemia_sev_adj = 2 if hb_altadjusted >=7 & hb_altadjusted<10 // moderate
	replace anemia_sev_adj = 3 if hb_altadjusted <7 // severe
	
	replace anemia_sev_adj = 0 if hb_altadjusted>=10.5 & hb_altadjusted<. & m1_trimester==2  // no anemia
	replace anemia_sev_adj = 1 if hb_altadjusted >=9.5 & hb_altadjusted<10.5 & m1_trimester==2 // mild
	replace anemia_sev_adj = 2 if hb_altadjusted >=7 & hb_altadjusted<9.5 & m1_trimester==2 // moderate
	replace anemia_sev_adj = 3 if hb_altadjusted <7 & m1_trimester==2 // severe
	
	replace anemia_sev_adj = . if m1_trimester==.
	
	label values anemia_sev_adj anemia_sev
	label var anemia_sev_adj "Anemia severity (adjusted for GA and altitude)"
	
	br hb_measured hb_under11 anemia_sev hb_altadjusted anemia_sev_adj m1_trimester
	
	gen anemia_adj = anemia_sev_adj
	recode anemia_adj (3=1) (2=1) 
	tab anemia_adj, m 
	label var anemia_adj "Severe anemia (adjusted for GA and altitude)"
	
	*  MUAC<23 AND Hb<11
	gen malnourished_double = 0 if muac_under23<. & hb_under11<.
	replace malnourished_double = 1 if muac_under23==1 & hb_under11==1
	label var malnourished_double
	tab malnourished_double, m 
	label var malnourished_double "MUAC under 23 and HB under 11"
	
	* BMI
	gen bmi = m1_weight_kg/((m1_height_cm/100)^2)
	
	gen bmi_under18p5 = 0 if bmi!=.
	replace bmi_under18p5 = 1 if bmi<18.5 
	label var bmi_under18p5 "BMI under 18.5"
	
	* Formal employment
	gen employed = 0 if m1_506<.
	replace employed = 1 if m1_506==1 | m1_506==2 | m1_506==3
	label var employed "Formally employed (government, private, or NGO)"
	
	* Number of meals per day
	replace m1_1216b = . if m1_1216b==13 // doesn't make sense
	
	* Health insurance  
	label define yesno 0 "No" 1 "Yes"
	label values m1_1221 yesno
	
	label define healthinsurance 1 "Community-based" 2 "Employer-provided" 3 "Private" 96 "Other"
	label values m1_1222 healthinsurance 
	
	gen healthinsurance_anyortype = m1_1222
	replace healthinsurance_anyortype = 0 if m1_1221==0
	replace healthinsurance_anyortype = 2 if m1_1222==3 // combining since these are small categories
	label define healthinsurance_anyortype 0 "None" 1 "Community-based" 2 "Private or employer-provided" 96 "Other"
	label values healthinsurance_anyortype healthinsurance_anyortype
	tab healthinsurance_anyortype
	
	* Past late miscarriage
	gen latemiscarriage = 0 if m1_1001>=1 & m1_1001<.
	replace latemiscarriage = 1 if m1_1004==1
	label var latemiscarriage "Late miscarriage (among women with past pregnancies)"
	
	* Past neonatal mortality
	gen neonatal_mortality = 0 if m1_1001>+1 & m1_1001<.
	replace neonatal_mortality = 1 if m1_1010==1
	label var neonatal_mortality "Neonatal mortality (among women with past pregnancies)"
	
	* Past preterm birth
	gen preterm = 0 if m1_1001>=1 & m1_1001<.
	replace preterm = 1 if m1_1005==1 
	label var preterm "Preterm birth (among women with past pregnancies)"
	
	* Past late miscarriage, neonatal mortality, or preterm birth 
	gen past_complications = latemiscarriage 
	replace past_complications = 1 if neonatal_mortality==1 
	replace past_complications = 1 if preterm==1 
	replace past_complications = 0 if m1_1001==1 // zero if first pregnancy
	label var past_complications "Past late miscarriage, neonatal mortality, or preterm birth"
	
	* Comorbid conditions 
	egen comorbidity = rowtotal(m1_202a m1_202b m1_202c m1_202d m1_202e m1_202f_et m1_202g_et)
	tab comorbidity, m
	replace comorbidity = 1 if comorbidity>1 & comorbidity<.
	label var comorbidity "Has diabetes, high blood pressure, cardiovascular disease, mental health disorder, HIV, Hepatitis B, or renal disorder"
	
	* Depression
	recode m1_phq9_cat 4/5=3, gen(depression_cat)
	lab def depression_cat 1"none-minimal 0-4" 2"Mild 5-9" 3"Moderate to severe 10+"
	lab val depression_cat depression_cat
	recode depression_cat 1=0 2/3=1, g(depress)
	label var depress "Mild or moderate depression"
	
	* Age under 19
	gen adolescent = 0 if m1_enrollage<.
	replace adolescent = 1 if m1_enrollage<19
	label var adolescent "Age under 19 at enrollment"
	
	* First pregnancy
	gen firstpregnancy = (m1_1001==1)
	tab firstpregnancy m1_1001, m	
	label var firstpregnancy "First pregnancy"
	
	* Trimester at ANC1
	tab m1_trimester
				
		* Formal employment
		gen formalemployment = 0 if m1_506<.
		replace formalemployment = 1 if m1_506==1 | m1_506==2 | m1_506==3
		label var formalemployment "Employed (government, private, or NGO)"
		
		* Education 
		gen education = 0 if m1_502==0 
		replace education = 1 if m1_503==1 
		replace education = 2 if m1_503==2 
		replace education = 3 if m1_503==3 
		replace education = 4 if m1_503==4 
		replace education = 5 if m1_503==5 
		label define educationlabel 0 "None" 1 "Some primary" 2 "Completed primary" 3 "Some secondary" 4 "Completed secondary" 5 "Higher education" 
		label values education educationlabel
		tab education, m
		label var education "Highest level of edu completed"
		
		gen education_simp = education
		replace education_simp = 0 if education==0 | education==1 
		replace education_simp = 1 if education==2 | education==3 
		replace education_simp = 2 if education==4 | education==5 
		label var education_simp "Highest level of education completed"
		label define education_simp 0 "None or some primary" 1 "Completed primary" 2 "Completed secondary or higher"
		label values education_simp education_simp
		
		* Categorical variable for age at enrollment
		gen m1_enrollage_cat = 1 if m1_enrollage >=16 & m1_enrollage <20 
		replace m1_enrollage_cat = 2 if m1_enrollage>=20 & m1_enrollage <35
		replace m1_enrollage_cat = 3 if m1_enrollage>=35
		label define m1_enrollage_cat 1 "Age <20" 2 "Age 20-35" 3 "Age 35+"
		label values m1_enrollage_cat m1_enrollage_cat
		tab m1_enrollage_cat
		label var m1_enrollage_cat "Age category at enrolment"
	
		* Categorical variable for parity
		gen m1_1001_cat = 1 if m1_1001 ==1
		replace m1_1001_cat = 2 if m1_1001==2 | m1_1001==3 
		replace m1_1001_cat = 3 if m1_1001 >=4
		label define m1_1001_cat 1 "First pregnancy" 2 "2nd or 3rd pregnancy" 3 "4th or later pregnancy"
		label values m1_1001_cat m1_1001_cat
	
* Quality of care during ANC 1
	
	* Blood sample (any)
	gen blooddraw_any_anc1 = m1_706 
	replace blooddraw_any_anc1 = 1 if m1_707==1 
	replace blooddraw_any_anc1 = 2 if m1_724g==1 
	label define blooddraw_any_anc1 0 "No blood draw done" 1 "Blood drawn at facility during ANC1" 2 "Patient send elsewhere for a blood test"
	label var blooddraw_any_anc1 "Any blood test at ANC1"
	label values blooddraw_any_anc1 blooddraw_any_anc1
	label var blooddraw_any_anc1 "Blood sample (finger prick or blood draw)"
	gen blooddraw_any_anc1_binary = blooddraw_any_anc1
	replace blooddraw_any_anc1_binary = 1 if blooddraw_any_anc1==2
	
	* Given or prescribed IFA at first ANC 
	gen ifapills_firstanc = 0 if m1_713a<.
	replace ifapills_firstanc =1 if m1_713a==1 | m1_713a==2
	label var ifapills_firstanc "Given or prescribed IFA at first ANC"
	
	* Given or prescribed multivitamins at first ANC 
	gen multivitamins_firstanc = 0 if m1_713g<.
	replace multivitamins_firstanc = 1 if m1_713g==1 | m1_713g==2
	label var multivitamins_firstanc "Given or prescribed multivit at first ANC"
	 
	* Given or prescribed calcium supplements at first ANC 
	gen calcium_firstanc = 0 if m1_713b<.
	replace calcium_firstanc = 1 if m1_713b==1 | m1_713b==2
	label var calcium_firstanc "Given or prescribed calcium at first ANC"
	
	* Given or prescribed multivitamins OR iron & folic acid supplements at first ANC
	gen multi_or_ifa_firstanc = 0 if ifapills_firstanc!=. & multivitamins_firstanc!=. 
	replace multi_or_ifa_firstanc = 1 if ifapills_firstanc==1 | multivitamins_firstanc==1
	label var multi_or_ifa_firstanc "Multivitamins OR iron-folic acid at ANC1"
	
	* Given or prescribed deworming at first ANC if endemic & gestational age > 14 weeks
	gen deworming_firstanc = 0 if m1_713d<.
	replace deworming_firstanc = 1 if m1_713d==1 | m1_713d==2
	tab deworming_firstanc // 1/231
	label var deworming_firstanc "Given or prescribed deworming at first ANC if endemic and GA>14 wks"
	
	* Given insecticide-treated net (or already has one) if malaria endemic area
	gen bednet_anc1 = 0 if m1_715<.
	replace bednet_anc1 = 1 if m1_715==1 | m1_715==2
	replace bednet_anc1 = .a if kebele_malaria==0
	tab bednet_anc1 
	label var bednet_anc1 "Given insecticide-treated net or has one at ANC1"
	
	* Given or prescribed nutritional supplements at ANC1
	gen nutrisup_anc1 = 0 if m1_713c<.
	replace nutrisup_anc1 =1 if m1_713c==1 | m1_713c==2
	label var nutrisup_anc1 "Given or prescribed nutritional supplements at ANC1"
	
	* Given antimalarial medication at ANC1
	gen antimalarial_anc1 = 0 if m1_713e<.
	replace antimalarial_anc1 = 1 if m1_713e==1 | m1_713e==2 
	tab antimalarial_anc1 
	replace antimalarial_anc1 = .a if kebele_malaria==0
	replace antimalarial_anc1 = .a if m1_ga<13.99999
	label var antimalarial_anc1 "Given or prescribed antimalarial med at ANC1"
	
	* ANC1 counseling: nutrition 
	gen nutri_counseling_anc1 = m1_716a
	label var nutri_counseling_anc1 "Counseled on nutrition at ANC1"
	
	* ANC1 counseling: bednet 
	gen bednet_counseling_anc1 = m1_716d
	label var bednet_counseling_anc1 "Counseled on bednet at ANC1"
	
	* ANC1 counseling general
	egen counseling_index = rowtotal(m1_716a m1_716b m1_716c m1_716d m1_716e)
	
	* ANC knowledge 
	gen knows_anemic_anc1 = m1_8c_et
	label var knows_anemic_anc1 "Self-report anemia at ANC1"
	
	* ANC booklets - information rleated to being underweight?
	* mcard_danger_signs 
	gen weight_recorded = 0
	replace weight_recorded=1 if mcard_weight!=. & mcard_weight!=998 & mcard_weight!=999 & mcard_weight!=888
	tab weight_recorded
	

* Quality of care (longitudinal)

	* Number of routine ANC consultations
	egen consultations = rowtotal(m2_305* m2_308* m2_311* m2_314* m2_317* m3_consultation_1 m3_consultation_2 m3_consultation_3 m3_consultation_4 m3_consultation_5) 
	gen total_consultations_routine = consultations + 1 // adding first ANC
	drop consultations
	foreach i in 1 2 3 4 5 6 7 8 {
		replace total_consultations_routine = . if m2_date_r`i'!=. & m2_202_r`i'==1 & m2_301_r`i'==. // missing if there is a full M2 entry (hwere the mother is still pregnant) that doesn't have info for this question
	}
	replace total_consultations_routine = . if m3_401==.a // 4 cases where the questions on follow-up care were not asked during module 3 (even though these were live births) 
	tab total_consultations_routine, m // 16 missings 
	label var total_consultations_routine "Total number of routine ANC consultations during pregnancy"
	
	gen routine_consults_atleast4 = 0 if total_consultations_routine!=.
	replace routine_consults_atleast4 = 1 if total_consultations_routine>=4 & total_consultations_routine<.
	label var routine_consults_atleast4 "At least 4 routine ANC consultations during pregnancy"
	
	* Number of ANY health visits during pregnancy 
	egen consultations_any = rowtotal(m2_302*  m3_402)
	gen total_consultations_any = consultations_any + 1
	drop consultations_any
	foreach i in 1 2 3 4 5 6 7 {
		replace total_consultations_any = . if (m2_date_r`i'!=. & m2_202_r`i'==1 & m2_301_r`i'==.)
	}
	replace total_consultations_any = . if m3_401==.a
	label var total_consultations_any "Total number of any health consultations during pregnancy"
	tab total_consultations_any, m // 16 missings
	
	* Weight ever taken after ANC1
	egen weight_postanc1 = rowtotal(m2_501b* m3_412b)
	foreach i in 1 2 3 4 5 6 7 {
		replace weight_postanc1 = . if (m2_date_r`i'!=.  & m2_202_r`i'==1 & m2_501b_r`i'==.)
	}
	replace weight_postanc1=. if m3_412b==. | m3_401==.a

	replace weight_postanc1=1 if weight_postanc1>1 & weight_postanc1<.
	label var weight_postanc1 "Weight ever taken after ANC1"
	tab weight_postanc1, m // 3 missings
		
	* Cumulative weight draws over the course of pregnancy
	* Note: we assume that, if she had multiple routine ANC visits since her last call,
	* and she reports that her weight was measured at at least one of them, 
	* then her weight was measured at all of them.
	foreach i in 1 2 3 4 5 6 7 {
		egen routinevisitssincelastcall_r`i' = rowtotal(m2_305_r`i' m2_308_r`i' m2_311_r`i' m2_314_r`i' m2_317_r`i')
		replace routinevisitssincelastcall_r`i'=. if m2_501b_r`i'==.a
		gen weightmeasuressincelastcall_r`i' = routinevisitssincelastcall_r`i' * m2_501b_r`i'
		replace weightmeasuressincelastcall_r`i' = 1 if weightmeasuressincelastcall_r`i'==0 & m2_501b_r`i'==1 // taken at a non-routine visit
	}
	br m2_305_r1 m2_308_r1 m2_311_r1 m2_314_r1 routinevisitssincelastcall_r1 m2_501b_r1 weightmeasuressincelastcall_r1
	br m2_305_r2 m2_308_r2 m2_311_r2 m2_314_r2 routinevisitssincelastcall_r2 m2_501b_r2 weightmeasuressincelastcall_r2
	br m2_305_r7 m2_308_r7 m2_311_r7 m2_314_r7 routinevisitssincelastcall_r7 m2_501b_r7 weightmeasuressincelastcall_r7
	br m2_305_r2 m2_308_r2 m2_311_r2 m2_314_r2 routinevisitssincelastcall_r2 m2_501b_r2 weightmeasuressincelastcall_r2 if m2_501b_r2==1 & routinevisitssincelastcall_r2==0
	
	egen weightmeasures_cumulative = rowtotal (m1_701 weightmeasuressincelastcall_r1 weightmeasuressincelastcall_r2 weightmeasuressincelastcall_r3 weightmeasuressincelastcall_r4 weightmeasuressincelastcall_r5 weightmeasuressincelastcall_r6 weightmeasuressincelastcall_r7 m3_412b)
	label var weightmeasures_cumulative "Total number of times weight was taken during pregnancy"

	gen weight_ever = 0 if weightmeasures_cumulative<. 
	replace weight_ever = 1 if weightmeasures_cumulative>=1 & weightmeasures_cumulative<. 
	label var weight_ever "Weight taken at least once during pregnancy"
	
	gen weight_atleast2 = 0 if weightmeasures_cumulative<.
	replace weight_atleast2 = 1 if weightmeasures_cumulative>=2 & weightmeasures_cumulative<.
	label var weight_atleast2 "Weight taken at least 2 times during pregnancy"
	
	gen weight_atleast7 = 0 if weightmeasures_cumulative<.
	replace weight_atleast7 = 1 if weightmeasures_cumulative>=7 & weightmeasures_cumulative<. 
	label var weight_atleast7 "Weight taken at least 7 times during pregnancy"
	
	gen weight_atleast8 = 0 if weightmeasures_cumulative<.
	replace weight_atleast8 = 1 if weightmeasures_cumulative>=8 & weightmeasures_cumulative<. 
	label var weight_atleast8 "Weight taken at least 8 times during pregnancy"
		
	* Blood test ever done after ANC1 
	replace m2_501c_r1 = 1 if m2_501g_other_r1=="Blood group testing" | m2_501g_other_r1=="Rh factor"
	egen bloodtest_postanc1 = rowtotal(m2_501c* m2_501d* m3_412c m3_412d)
	replace bloodtest_postanc1 =1 if bloodtest_postanc1>1 & bloodtest_postanc1<.
	foreach i in 1 2 3 4 5 6 7 {
		replace bloodtest_postanc1 = . if (m2_date_r`i'!=. &  m2_202_r`i'==1 & (m2_501c_r`i'==. | m2_501g_r`i'==.))
	}
	replace bloodtest_postanc1 =. if m3_401==.a | m3_412d==.
	tab bloodtest_postanc1, m // 5 missing
	label var bloodtest_postanc1 "Blood tests after ANC1"
		
	* Cumulative blood draws over the course of pregnancy
	* Same assumption used as for weight measurement
	foreach i in 1 2 3 4 5 6 7 {
		
		* create a binary variable for either blood draw or prick since last call
		egen anybloodsincelastcall_r`i' = rowtotal(m2_501c_r`i' m2_501d_r`i') 
		replace anybloodsincelastcall_r`i' = 1 if anybloodsincelastcall_r`i'>1 & anybloodsincelastcall_r`i'<.
		
		* multiply this by the number of routine visits since last call
		gen bloodtestssincelastcall_r`i' = routinevisitssincelastcall_r`i' * anybloodsincelastcall_r`i'
		
		* recode the number of tests as 1 if she reports no routine visits but also says she had a blood test since last call
		replace bloodtestssincelastcall_r`i' = 1 if routinevisitssincelastcall_r`i'==0 & bloodtestssincelastcall_r`i'==1 // taken at a non-routine visit
	}
	
	br m2_501c_r1 m2_501d_r1 anybloodsincelastcall_r1 routinevisitssincelastcall_r1 bloodtestssincelastcall_r1
	label var anybloodsincelastcall_r1 "Any blood tests since last call"
	label var routinevisitssincelastcall_r1 "Routine visits since last call"
	label var bloodtestssincelastcall_r1 "Blood tests since last call"
	
	label var anybloodsincelastcall_r2 "Any blood tests since last call"
	label var routinevisitssincelastcall_r2 "Routine visits since last call"
	label var bloodtestssincelastcall_r2 "Blood tests since last call"
	
	label var anybloodsincelastcall_r3 "Any blood tests since last call"
	label var routinevisitssincelastcall_r3 "Routine visits since last call"
	label var bloodtestssincelastcall_r3 "Blood tests since last call"
	
	label var anybloodsincelastcall_r4 "Any blood tests since last call"
	label var routinevisitssincelastcall_r4 "Routine visits since last call"
	label var bloodtestssincelastcall_r4 "Blood tests since last call"
	
	
	label var anybloodsincelastcall_r5 "Any blood tests since last call"
	label var routinevisitssincelastcall_r5 "Routine visits since last call"
	label var bloodtestssincelastcall_r5 "Blood tests since last call"
	
	label var anybloodsincelastcall_r6 "Any blood tests since last call"
	label var routinevisitssincelastcall_r6 "Routine visits since last call"
	label var bloodtestssincelastcall_r6 "Blood tests since last call"
	
	label var anybloodsincelastcall_r7 "Any blood tests since last call"
	label var routinevisitssincelastcall_r7 "Routine visits since last call"
	label var bloodtestssincelastcall_r7 "Blood tests since last call"
	
	gen anyblood_mod3 = m3_412c 
	replace anyblood_mod3 = 1 if m3_412d==1
	label var anyblood_mod3 "Any blood test reported at M3"
		
	egen bloodtests_cumulative = rowtotal(blooddraw_any_anc1_binary bloodtestssincelastcall_r1 bloodtestssincelastcall_r2 bloodtestssincelastcall_r3 bloodtestssincelastcall_r4 bloodtestssincelastcall_r5 bloodtestssincelastcall_r6 bloodtestssincelastcall_r7 anyblood_mod3) 
	label var bloodtests_cumulative "Cumulative blood tests"
	
	gen bloodtests_atleast3 = 0 if bloodtests_cumulative<.
	replace bloodtests_atleast3 = 1 if bloodtests_cumulative>=3 & bloodtests_cumulative<. 
	label var bloodtests_atleast3 "At least 3 blood tests over the course of pregnancy"
	
	gen bloodtests_atleast2 = 0 if bloodtests_cumulative<.
	replace bloodtests_atleast2 = 1 if bloodtests_cumulative>=2 & bloodtests_cumulative<. 
	label var bloodtests_atleast2 "At least 2 blood tests over the course of pregnancy"

	
	gen bloodtests_ever = 0 if bloodtests_cumulative<.
	replace bloodtests_ever = 1 if bloodtests_cumulative>=1 & bloodtests_cumulative<. 
	label var bloodtests_ever "At least 1 blood test1 over the course of pregnancy"
	
		
	* BP taken after 1st ANC
	egen bp_postanc1 = rowtotal(m2_501a*  m3_412a)
	replace bp_postanc1 = 1 if bp_postanc1>1 & bp_postanc1<.
	foreach i in 1 2 3 4 5 6 7 {
		replace bp_postanc1 = . if (m2_date_r`i'!=. &  m2_202_r`i'==1 & m2_501a_r`i'==. )
	}
	replace bp_postanc1 = . if m3_401==.a
	tab bp_postanc1, m // 2 missing
	label var bp_postanc1 "Blood pressure after ANC1"
	
	* Create variable for whether given/prescribed or purchased IFA or other iron supplements ever
	replace m2_601a_r1 = 1 if m2_601_other_r1=="iron" | m2_601_other_r1=="iron " | m2_601_other_r1=="iron folic acid syrup"
	replace m2_601a_r2 = 1 if m2_601_other_r2=="Heame up and prenatal tabs"
	replace m2_601a_r3 = 1 if m2_601_other_r3=="iron" | m2_601_other_r3=="irons " 
	replace m2_601a_r4 = 1 if m2_601_other_r4=="haemup" | m2_601_other_r4=="iron" | m2_601_other_r4=="iron and albendazole"
	replace m2_601a_r5 = 1 if m2_601_other_r5=="iron supplement syrup"
	egen ifapills_everduringpregnancy = rowtotal(ifapills_firstanc m2_601a*  m3_901a)
	gen ifapills_timesgiven = ifapills_everduringpregnancy
	replace ifapills_everduringpregnancy = 1 if ifapills_everduringpregnancy>1 & ifapills_everduringpregnancy<.
	foreach i in 1 2 3 4 5 6 7 {
		replace ifapills_everduringpregnancy = . if (m2_date_r`i'!=. &  m2_202_r`i'==1 & m2_601a_r`i'==.)
		replace ifapills_timesgiven = . if ifapills_everduringpregnancy==.
	}
	tab ifapills_everduringpregnancy if m3_901b==1 // * note: I didn't include iron injections here  m3_901b, but everyone who got the injection also got the pills, so not an issue
	replace ifapills_everduringpregnancy = . if m3_401==.a 
	replace ifapills_timesgiven = . if m3_401==.a
	tab1 ifapills_everduringpregnancy ifapills_timesgiven, m // 35 missings for each var 
	tab m2_601a_r1 if m2_date_r1!=., m // 17 unexplained missings here
	label var ifapills_everduringpregnancy "IFA ever during pregnancy"
	
	* Create variable for whether given calcium supplements ever
	egen calcium_everpregnancy = rowtotal (calcium_firstanc m2_601b* m3_901c)
	replace calcium_everpregnancy = 1 if calcium_everpregnancy>1 & calcium_everpregnancy<.
	foreach i in 1 2 3 4 5 6 7 {
		replace calcium_everpregnancy = . if (m2_date_r`i'!=. & m2_202_r`i'==1 & (m2_601b_r`i'==. | m2_601b_r`i'==.d))
	}
	tab m2_601b_r1 if m2_date_r1!=.a, m // 17 unexplained missings here
	replace calcium_everpregnancy = . if m3_401==.a
	tab calcium_everpregnancy, m // 31 missings
	label var calcium_everpregnancy "Calcium ever during pregnancy"
	
	* Create variable for whether given multivitamins
	replace m2_601c_r2 = 1 if m2_601_other_r2=="Heame up and prenatal tabs"
	egen multivitamins_everpreg = rowtotal(multivitamins_firstanc m2_601c* m3_901d)
	replace multivitamins_everpreg = 1 if multivitamins_everpreg>1 & multivitamins_everpreg<.
	foreach i in 1 2 3 4 5 6 7 {
		replace multivitamins_everpreg = . if (m2_date_r`i'!=. & m2_202_r`i'==1 & m2_601c_r`i'==.)
	} 
	replace multivitamins_everpreg = . if m3_401==.a
	tab multivitamins_everpreg, m // 29 missings
	label var multivitamins_everpreg "Multivitamins ever during pregnancy"
	
	* Given or prescribed multivitamins OR iron & folic acid supplements at any point during pregnancy
	gen multi_or_ifa_ever = 0 if ifapills_everduringpregnancy!=. & multivitamins_everpreg!=.
	replace multi_or_ifa_ever = 1 if ifapills_everduringpregnancy==1 | multivitamins_everpreg==1 
	label var multi_or_ifa_ever "Multivitamins OR iron-folic acid ever during pregnancy"

	* Create variable for whether given de-worming 
	replace m2_601e_r4 = 1 if m2_601_other_r4=="iron and albendazole" | m2_601_other_r4=="Albendazole"
	egen deworming_everpreg = rowtotal(deworming_firstanc m2_601e* m3_901f)
	replace deworming_everpreg = 1 if deworming_everpreg>1 & deworming_everpreg<. 
	foreach i in 1 2 3 4 5 6 7 {
		replace deworming_everpreg = . if (m2_date_r`i'!=. & m2_202_r`i'==1 & m2_601e_r`i'==.)
	} 
	replace deworming_everpreg = . if m3_401==.a
	replace deworming_everpreg = .a if kebele_intworm==0 // fix this because this should be missing if in a non-endemic area
	tab deworming_everpreg, m // 1 missing
	label var deworming_everpreg "Deworming ever in pregnancy"
	
	* Create variable for whether given antimalarials 
	egen antimalarial_everpreg = rowtotal(antimalarial_anc1 m2_601f* m3_901g)
	replace antimalarial_everpreg = 1 if antimalarial_everpreg>1 & antimalarial_everpreg<. 
	foreach i in 1 2 3 4 5 6 7 {
		replace antimalarial_everpreg = . if (m2_date_r`i'!=. & m2_202_r`i'==1 & m2_601f_r`i'==.)
	}  
	replace antimalarial_everpreg = . if m3_401==.a
	tab antimalarial_everpreg kebele_malaria, m
	replace antimalarial_everpreg = .a if kebele_malaria==0
	tab antimalarial_everpreg, m // 9 missing
	label var antimalarial_everpreg " antimalarial ever in pregnancy"
	
	* Nutritional supplements ever during pregnancy 
	egen nutrisup_everpreg = rowtotal(nutrisup_anc1 m2_601d* m3_901e)
	replace nutrisup_everpreg = 1 if nutrisup_everpreg>1 & nutrisup_everpreg<.
	foreach i in 1 2 3 4 5 6 7 {
		replace nutrisup_everpreg = . if (m2_date_r`i'!=. & m2_202_r`i'==1 & m2_601d_r`i'==.)
	}  
	replace nutrisup_everpreg = . if m3_401==.a
	tab nutrisup_everpreg, m // 27 missing
	label var nutrisup_everpreg " nutritional supplements ever in pregnancy"

	* IFA adherence
	egen ifa_adherence_percent = rowmean(m2_603_r1 m2_603_r2 m2_603_r3 m2_603_r4 m2_603_r5 m2_603_r6 m2_603_r7)
	label var ifa_adherence_percent "IFA adherence (% of calls)"
	
	gen ifa_adherence_complete = ifa_adherence_percent
	replace ifa_adherence_complete = 0 if ifa_adherence_percent<1
	label var ifa_adherence_complete "IFA adherence (binary var for adhering during 100% of calls)"
	
	
	foreach num in 1 2 3 4 5 6 7  {
		gen m2_604_r`num'_daily = 0 if m2_603_r`num'<.
		replace m2_604_r`num'_daily = 1 if m2_604_r`num'==1
		
	}
	
	label var m2_604_r1_daily "Daily IFA adherence (M1 - R2)"
	label var m2_604_r2_daily "Daily IFA adherence (M2 - R2)"
	label var m2_604_r3_daily "Daily IFA adherence (M3 - R2)"
	label var m2_604_r4_daily "Daily IFA adherence (M4 - R2)"
	label var m2_604_r5_daily "Daily IFA adherence (M5 - R2)"
	label var m2_604_r6_daily "Daily IFA adherence (M6 - R2)"
	label var m2_604_r7_daily "Daily IFA adherence (M7 - R2)"

	
	egen ifa_adherence_percent_daily = rowmean(m2_604_r1_daily m2_604_r2_daily m2_604_r3_daily m2_604_r4_daily m2_604_r5_daily m2_604_r6_daily m2_604_r7_daily)
	gen ifa_adherence_complete_daily = ifa_adherence_percent_daily 
	replace ifa_adherence_complete_daily = 0 if ifa_adherence_complete_daily<1 
	label var ifa_adherence_complete_daily "IFA adherence every day (binary var for adhering daily during 100% of calls)"
	tab ifa_adherence_complete_daily

	* When to come back after ANC1
	gen told_when_to_come_back = m1_724a
	label var told_when_to_come_back "Told when to come back after ANC1"
			
	* Referrals to specialists 
	gen referred_to_specialist_anc1 = m1_724c
	egen referred_to_specialist_ever = rowtotal(referred_to_specialist_anc1 m2_509a*)
	replace referred_to_specialist_ever = 1 if referred_to_specialist_ever>1 & referred_to_specialist_ever<.
	
	foreach i in 1 2 3 4 5 6 7 {
		replace referred_to_specialist_ever = . if (m2_date_r`i'!=. & m2_202_r`i'==1 & m2_509a_r`i'==.)
	}  
	tab referred_to_specialist_ever, m // 4 missing
	*** NOTE: NO INFO IN MODULE 3??
	label var referred_to_specialist_ever "Ever referred to specialist"


	* Referrals to hospital
	gen referred_to_hospital_anc1 = m1_724e
	egen referred_to_hospital_ever = rowtotal(referred_to_hospital_anc1 m2_509b*)
	replace referred_to_hospital_ever = 1 if referred_to_hospital_ever>1 & referred_to_hospital_ever<.
	
	foreach i in 1 2 3 4 5 6 7 {
		replace referred_to_hospital_ever = . if (m2_date_r`i'!=. & m2_202_r`i'==1 & m2_509b_r`i'==.)
	}  
	tab referred_to_hospital_ever, m
	label var referred_to_hospital_ever "Ever referred to hospital"
	
	* Referral to specialist OR hospital
	gen referred_specialist_or_hosp_anc1 = referred_to_specialist_anc1
	replace referred_specialist_or_hosp_anc1 = 1 if referred_to_hospital_anc1
	replace referred_specialist_or_hosp_anc1 = . if referred_to_hospital_anc1==.
	label var referred_specialist_or_hosp_anc1 "Referred to hospital or specialist after ANC1"
	
	gen referred_specialist_or_hosp_ever = referred_to_specialist_ever
	replace referred_specialist_or_hosp_ever = 1 if referred_to_hospital_ever==1
	replace referred_specialist_or_hosp_ever = . if referred_to_hospital_ever==.
	label var referred_specialist_or_hosp_ever "Ever referred to hospital or specialist"
	
	* At delivery: 
	gen delivery_asked_about_status = m3_601a
	*gen delivery_looked_at_card = m3_602a
	*gen delivery_had_info = m3_602b
	gen delivery_had_info_cardorother = m3_602a
		replace delivery_had_info_cardorother = 1 if m3_602b==1
	gen delivery_counseled_nutrition = m3_619j
	
* Facility-level data 
* merge with facility-level data
	merge m:1 facility using "$datafolder/eco_m0_et.dta", gen(_merge3)
	tab facility if _merge3==2
	drop if _merge3==2
	
* facility-level ANC volume 
	egen facility_anc1volume = rowtotal(m0_802_apr m0_802_aug m0_802_dec m0_802_feb m0_802_jan m0_802_jul m0_802_jun m0_802_mar m0_802_may m0_802_nov m0_802_oct m0_802_sep)
	label var facility_anc1volume "Annual ANC1 volume"
	
	egen facility_ancrepeatvolume = rowtotal(m0_801_apr m0_801_aug m0_801_dec m0_801_feb m0_801_jan m0_801_jul m0_801_jun m0_801_mar m0_801_may m0_801_nov m0_801_oct m0_801_sep)
	label var facility_ancrepeatvolume "Annual ANC-repeat volume"
	
	gen ancvol_monthly_hundreds = (facility_anc1volume+facility_ancrepeatvolume)/120
	
* facility type (combining ownership and type variable into one)
	gen facility_type2 = facility_type 
	replace facility_type2 = 5 if facility_type==4 
	replace facility_type2 = 4 if facility_type==3 & m0_a8_fac_own==4 
	label define facility_type2 1 "Public general hospital" 2 "Public primary hospital" 3 "Public health center" 4 "Mission/faith-based health center" 5 "NGO/non-profit MCH Speciality Clinic/Center"
	label values facility_type2 facility_type2
	
* urban or rural catchment area
	label define urbanrural 1 "Urban" 2 "Rural"
	label values m0_a9_urban urbanrural
	
*  BP apparatus
	gen fac_bp_any = (m0_401==1 | m0_401==2)
	tab fac_bp_any
	label var fac_bp_any "Has a BP apparatus"

	gen fac_bp_functioning = (m0_401a==1)
	tab fac_bp_functioning m0_401a
	label var fac_bp_functioning "Has a functioning BP apparatus"

*  scale 
	gen fac_scale_any = (m0_402==1 | m0_402==2)
	label var fac_scale_any "Has a scale"

	gen fac_scale_functioning = (m0_402a==1)
	label var fac_scale_functioning "Has a functioning scale"
	
*  measuring tape 
	gen fac_measuringtape_any = (m0_404==1 | m0_404==2)
	label var fac_measuringtape_any "Has measuring tape"

	gen fac_measuretape_functioning = (m0_404a==1)
	label var fac_measuretape_functioning "Has functioning measuring tape"
	
* haemoglobin testing
	gen fac_haemoglobintest_any = m0_427
	replace fac_haemoglobintest_any = 1 if m0_427==2 
	label var fac_haemoglobintest_any "Has Haemoglobin testing"
	
	gen fac_haemoglobintest_onsite = (m0_427==1)
	label var fac_haemoglobintest_onsite "Has on-site hemoglobin testing"
	
	gen m1_ga_4weeks = m1_ga/4
	label var m1_ga_4weeks "Gestational age in 4week increments at ANC1"
	
* Renaming
rename m2_204d_et_r1 m2_204d_r1
rename m2_204d_et_r2 m2_204d_r2
rename m2_204d_et_r3 m2_204d_r3 
rename m2_204d_et_r4 m2_204d_r4
rename m2_204d_et_r5 m2_204d_r5
rename m2_204d_et_r6 m2_204d_r6
rename m2_204d_et_r7 m2_204d_r7