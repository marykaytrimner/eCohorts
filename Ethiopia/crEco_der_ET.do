* MNH: ECohorts derived variable creation (Ethiopia)
* Date of last update: August 2023
* S Sabwa, K Wright, C Arsenault

/*
	This file creates derived variables for analysis from the MNH ECohorts Ethiopia dataset. 

*/

u "$et_data_final/eco_m1m2_et.dta", clear

*------------------------------------------------------------------------------*
* MODULE 1
*------------------------------------------------------------------------------*
	* SECTION A: META DATA
			
			gen facility_own = facility
			recode facility_own (2/11 14 16/19 =1) ///
							    (1 13 15 20 21 22 96 =2)
			lab def facility_own 1 "Public" 2 "Private"
			lab val facility_own facility_own 
			
			gen facility_lvl = facility 
			recode facility_lvl (2/6 8/12 14 16 17 19  =1) (7 18 =2) ///
								(1 13 15 20 21 22 96 =3) 
			
			lab def facility_lvl 1"Primary" 2 "Secondary" 3 "Private"
			lab val facility_lvl facility_lvl
*------------------------------------------------------------------------------*	
	* SECTION 2: HEALTH PROFILE
	
			egen phq9_cat = rowtotal(phq9*)
			recode phq9_cat (0/4=1) (5/9=2) (10/14=3) (15/19=4) (20/27=5)
			label define phq9_cat 1 "none-minimal 0-4" 2 "mild 5-9" 3 "moderate 10-14" ///
			                        4 "moderately severe 15-19" 5 "severe 20+" 
			label values phq9_cat phq9_cat

			egen phq2_cat= rowtotal(phq9a phq9b)
			recode phq2_cat (0/2=0) (3/6=1)
			
*------------------------------------------------------------------------------*	
	* SECTION 3: CONFIDENCE AND TRUST HEALTH SYSTEM
			recode m1_302 (98=.) // this shuold be fixed in cleaning do file
	
*------------------------------------------------------------------------------*	
	* SECTION 5: BASIC DEMOGRAPHICS
	
			gen educ_cat=m1_503
			replace educ_cat = 1 if m1_502==0
			recode educ_cat (3=2) (4/5=3) 
			lab def educ_cat 1 "No education or some primary" 2 "Complete primary" 3 "Complete secondary or higher"  
			lab val educ_cat educ_cat
			
			recode m1_505 (1/4=0) (5/6=1), gen(marriedp) 

*------------------------------------------------------------------------------*	
	* SECTION 6: USER EXPERIENCE
			foreach v in m1_601 m1_605a m1_605b m1_605c m1_605d m1_605e m1_605f ///
			             m1_605g m1_605h m1_605i m1_605j m1_605k {
				recode `v' (2=1) (3/5=0), gen(vg`v')
			}
			egen anc1ux=rowmean(vgm1_605a-vgm1_605k)
			*drop vgm1_605a-vgm1_605k
*------------------------------------------------------------------------------*	
	* SECTION 7: VISIT TODAY: CONTENT OF CARE
	
			* Technical quality of first ANC visit
			gen anc1bp = m1_700 
			gen anc1weight = m1_701 
			gen anc1height = m1_702
			egen anc1bmi = rowtotal(m1_701 m1_702)
			recode anc1bmi (1=0) (2=1)
			gen anc1muac = m1_703
			gen anc1fetal_hr = m1_704
			recode anc1fetal_hr  (2=.) 
			replace anc1fetal_hr=. if m1_804==1 // only applies to those in 2nd or 3rd trimester
			gen anc1urine = m1_705
			egen anc1blood = rowmax(m1_706 m1_707) // finger prick or blood draw
			gen anc1hiv_test =  m1_708a
			gen anc1syphilis_test = m1_710a
			gen anc1blood_sugar_test = m1_711a
			gen anc1ultrasound = m1_712
			gen anc1ifa =  m1_713a
			recode anc1ifa (2=1) (3=0)
			gen anc1tt = m1_714a
			recode m1_713b (2=1) (3=0), gen(anc1calcium)
			recode m1_713d (2=1) (3=0), gen(anc1deworm)
			recode m1_715 (2=.), gen(anc1itn) // ITN provision, among women who dont already have one, in kebele with malaria
			gen anc1depression = m1_716c
			gen anc1edd =  m1_801

			egen anc1tq = rowmean(anc1bp anc1weight anc1height anc1muac anc1fetal_hr anc1urine ///
								 anc1blood anc1ultrasound anc1ifa anc1tt ) // 10 items
					  
			* Counselling at first ANC visit
			gen counsel_nutri =  m1_716a  
			gen counsel_exer=  m1_716b
			gen counsel_complic =  m1_716e
			gen counsel_comeback = m1_724a
			gen counsel_birthplan =  m1_809
			egen anc1counsel = rowmean(counsel_nutri counsel_exer counsel_complic ///
								counsel_comeback counsel_birthplan)
										
			* Q713 Other treatments/medicine at first ANC visit 
			gen anc1food_supp = m1_713c
			gen anc1mental_health_drug = m1_713f
			gen anc1hypertension = m1_713h
			gen anc1diabetes = m1_713i
			foreach v in anc1food_supp anc1mental_health_drug anc1hypertension ///
						 anc1diabetes {
			recode `v' (3=0) (2=1)
			}
			
			
			* Instructions and advanced care
			egen specialist_hosp= rowmax(m1_724e m1_724c) 
*------------------------------------------------------------------------------*	
	* SECTION 8: CURRENT PREGNANCY
			/* Gestational age at ANC1
			Here we should recalculate the GA based on LMP (m1_802c and self-report m1_803 */
			
			*calculating GA - confirm with Catherine/Kate: 
			
			*this part needs to go into cleaning file - remove once that file is updated
			replace m1_803 = ".d" if m1_803 == "Dk" | m1_803 == "98"
			replace m1_803 = "." if m1_803 == ""
			encode m1_803, generate(recm1_803)
			drop m1_803
			ren rec* *
			
			gen ga = m1_802d_et 
			replace ga = m1_803 if ga == . // ga based reported LMP or self report of weeks pregnant 
			
			recode ga (1/12.99999 = 1) (13/26.99999= 2) (27/50=3), gen(trimester)
			lab def trimester 1"1st trimester 0-12wks" 2"2nd trimester 13-26 wks" 3 "3rd trimester 27-42 wks"
			lab val trimester trimester
			
			gen preg_intent = m1_807
			* Reports danger signs
			egen dangersigns = rowmax(m1_814a m1_814b m1_814c m1_814d  m1_814f m1_814g)
			
			* Asked about LMP
			gen anc1lmp= m1_806
			
			* Screened for danger signs 
			egen anc1danger_screen = rowmax(m1_815_1-m1_815_96) 
			replace anc1danger_screen = 0 if m1_815_other=="I told her the problem but she said nothing"
			replace anc1danger_screen= 0 if  m1_815_0==1 // did not discuss the danger sign 
			replace anc1danger_screen =  m1_816 if anc1danger_screen==.a | anc1danger_screen==.
*------------------------------------------------------------------------------*	
	* SECTION 9: RISKY HEALTH BEHAVIOR
			recode m1_901 (1/2=1) (3=0)
			recode m1_903  (1/2=1) (3=0)
			egen risk_health = rowmax( m1_901  m1_903  m1_905)
			egen stop_risk = rowmax( m1_902  m1_904  m1_907)
*------------------------------------------------------------------------------*	
	* SECTION 10: OBSTETRIC HISTORY
			gen nbpreviouspreg = m1_1001-1 // nb of pregnancies including current minus current pregnancy
			gen gravidity = m1_1001
			gen primipara=  m1_1001==1 // first pregnancy
			replace primipara = 1 if  m1_1002==0  // never gave birth
			gen pregloss = nbpreviouspreg-m1_1002 // nb previous pregnancies not including current minus previous births
			replace pregloss =. if pregloss<0 // 6 women had more births than pregnancies
			
			gen stillbirths = m1_1002 - m1_1003 // nb of deliveries/births minus live births
			replace stillbirths=. if stillbirths<0 // 6 women had more livebirths than pregnancies
			replace stillbirths = 1 if stillbirths>1 & stillbirths<.
			
*------------------------------------------------------------------------------*	
	* SECTION 12: ECONOMIC STATUS AND OUTCOMES
			*Asset variables
			recode  m1_1201 (2 4 6 96=0) (3=1), gen(safewater) // 96 is Roto tanks or tanker 
			recode  m1_1202 (2=1) (3=0), gen(toilet) // flush/ pour flush toilet and pit laterine =improved 
			gen electr = m1_1203
			gen radio = m1_1204
			gen tv = m1_1205
			gen phone = m1_1206
			gen refrig = m1_1207
			recode m1_1208 (3=1) (4/5=0), gen(fuel) // electricity, kerosene (improved) charcoal wood (unimproved)
			gen bicycle =  m1_1212 
			gen motorbik = m1_1213
			gen car = m1_1214 
			gen bankacc = m1_1215
			recode m1_1209 (96 1=0) (2/3=1), gen(floor) // Earth, dung (unimproved) wood planks, palm, polished wood and tiles (improved)
			recode m1_1210 (1 2 5=0) (3/4 6/8=1) (96=0), gen(wall) // Grass, timber, poles, mud  (unimproved) bricks, cement, stones (improved)
			recode m1_1211 (1/2=0) (3/5=1) (96=.), gen(roof)  // Iron sheets, Tiles, Concrete (improved) grass, leaves, mud, no roof (unimproved)
			lab def imp 1"Improved" 0"Unimproved"
			lab val safewater toilet fuel floor wall roof imp
			* I used the WFP's approach to create the wealth index
			// the link can be found here https://docs.wfp.org/api/documents/WFP-0000022418/download/ 
			pca safewater toilet electr radio tv phone refrig fuel bankacc car ///
			motorbik bicycle roof wall floor 
			estat kmo // all above 50
			predict wealthindex
			xtile quintile = wealthindex, nq(5)
			xtile tertile = wealthindex, nq(3)
			
			gen registration_cost= m1_1218a_1 // registration
				replace registration = . if registr==0
			gen med_vax_cost =  m1_1218b_1 // med or vax
				replace med_vax_cost = . if med_vax_cost==0
			gen labtest_cost =  m1_1218c_1 // lab tests
				replace labtest_cost= . if labtest_cost==0
			egen indirect_cost = rowtotal (m1_1218d_1 m1_1218e_1 m1_1218f_1 )
				replace indirect = . if indirect==0
*------------------------------------------------------------------------------*	
	* SECTION 13: HEALTH ASSESSMENTS AT BASELINE

			* High blood pressure (HBP)
			egen systolic_bp= rowmean(bp_time_1_systolic bp_time_2_systolic bp_time_3_systolic)
			egen diastolic_bp= rowmean(bp_time_1_diastolic bp_time_2_diastolic bp_time_3_diastolic)
			gen systolic_high = 1 if systolic_bp >=140 & systolic_bp <.
			replace systolic_high = 0 if systolic_bp<140
			gen diastolic_high = 1 if diastolic_bp>=90 & diastolic_bp<.
			replace diastolic_high=0 if diastolic_high <90
			egen HBP= rowmax (systolic_high diastolic_high)
			drop systolic* diastolic*
			
			* Anemia 
			gen Hb= m1_1309 // test done by E-Cohort data collector
			gen Hb_card= m1_1307 // hemoglobin value taken from the card
				replace Hb_card=11.3 if Hb_card==113
			replace Hb = Hb_card if Hb==.a // use the card value if the test wasn't done
				// Reference value of 11 from: 2022 Ethiopian ANC guidelines ≥ 11 gm/dl is normal.
			gen anemic_11= 0 if Hb>=11 & Hb<. 
			replace anemic_11=1 if Hb<11
			*gen anemic_12= 0 if Hb>=12 & Hb<. 
			*replace anemic_12=1 if Hb<12
			drop Hb_card
			
			* MUAC
			recode muac (999=.)
			gen malnutrition = 1 if muac<23
			replace malnutrition = 0 if muac>=23 & muac<.
			
			* BMI 
			gen height_m = height_cm/100
			gen BMI = weight_kg / (height_m^2)
			gen low_BMI= 1 if BMI<18.5 
			replace low_BMI = 0 if BMI>=18.5 & BMI<.


*------------------------------------------------------------------------------*	
* Labelling new variables 
	lab var facility_own "Facility ownership"
	lab var phq9_cat "PHQ9 Depression level Based on sum of all 9 items"
	lab var anc1bp "Blood pressure taken at ANC1"
	lab var anc1weight "Weight taken at ANC1"
	lab var anc1height "Height measured at ANC1"
	lab var anc1bmi "Both Weight and Height measured at ANC1"
	lab var anc1muac "Upper arm measured at ANC1"
	lab var anc1urine "Urine test done at ANC1"
	lab var anc1blood "Blood test done at ANC1 (finger prick or blood draw)"
	lab var anc1hiv_test "HIV test done at ANC1"
	lab var anc1syphilis_test "Syphilis test done at ANC1"
	lab var anc1ultrasound "Ultrasound done at ANC1"
	lab var anc1food_supp "Received food supplement directly or a prescription at ANC1"
	lab var anc1ifa "Received iron and folic acid pills directly or a prescription at ANC1"
	lab var anc1tq "Technical quality score 1st ANC"
	lab var counsel_nutri "Counselled about proper nutrition at ANC1"
	lab var counsel_exer "Counselled about exercise at ANC1"
	lab var counsel_complic  "Counselled about signs of pregnancy complications"
	lab var counsel_birthplan "Counselled on birth plan at ANC1"
	lab var anc1counsel "Counselling quality score 1st ANC"
	lab var specialist_hosp  "Told to go see a specialist or to go to hospital for ANC"
	lab var dangersigns "Experienced at least one danger sign so far in pregnancy"
	lab var pregloss "Number of pregnancy losses (Nb pregnancies > Nb births)"
	lab var HBP "High blood pressure at 1st ANC"
	lab var anemic_11 "Anemic (Hb <11.0)"
	*lab var anemic_12 "Anemic (Hb <12.0)"
	lab var height_m "Height in meters"
	lab var malnutrition "Acute malnutrition MUAC<23"
	lab var BMI "Body mass index"
	lab var low_BMI "BMI below 18.5 (low)"

	order facility_own facility_lvl, after(facility)
	
save "$et_data_final/eco_m1m2_et_der.dta", replace
