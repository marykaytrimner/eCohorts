
global user "/Users/catherine.arsenault"
global analysis "Dropbox/SPH Kruk QuEST Network/Core Research/Ecohorts/MNH E-Cohorts-internal/Analyses/Manuscripts/Paper 1 ANC1 quality"
global data "Dropbox/SPH Kruk QuEST Network/Core Research/Ecohorts/MNH Ecohorts QuEST-shared/Data"

*------------------------------------------------------------------------------*
* ETHIOPIA

u "$user/$data/Ethiopia/02 recoded data/eco_m1_et_der.dta", clear	
	keep if redcap_event_name=="module_1_arm_1"
	egen tag=tag(facility)
	
* ANC quality
	gen ultrasound = anc1ultrasound if trimester>2 & trimester<. // 3rd trimester only
	gen edd = anc1edd if trimester>1 & trimester<. // 2nd,3rd trimester only
	gen calcium = anc1calcium if trimester>1 & trimester<. // 2nd,3rd trimester only
	gen deworm = anc1deworm if trimester>1 & trimester<. // 2nd,3rd trimester only
	gen tt= anc1tt
	replace tt =. if  m1_714c>=5 &  m1_714c<98 // had 5 or more previous lifetime doses
	replace tt =. if  m1_714c>=4 &  m1_714c<98 & m1_714e <=10 // had 4 or more incl. 1 in last 10 years
	replace tt =. if  m1_714c>=3 &  m1_714c<98 & m1_714e <=5 // had 3 or more incl. 1 in last 5 years
	replace tt =. if  m1_714c>=2 &  m1_714c<98 & m1_714e <=3 // had 2 or more incl. 1 in last 3 years
	g previous_preg=m1_1011a 
			
	egen anc1qual= rowmean(anc1bp anc1weight anc1height anc1muac anc1blood ///
		anc1urine ultrasound anc1lmp anc1depression anc1danger_screen previous_preg ///
		m1_counsel_nutri m1_counsel_exer m1_counsel_complic m1_counsel_birthplan edd ///
		m1_counsel_comeback anc1ifa calcium deworm tt anc1itn)
	
	replace anc1qual = anc1qual*100
	
		egen phys_exam=rowmean(anc1bp anc1weight anc1height anc1muac)
		egen diag=rowmean(anc1blood anc1urine ultrasound)
		egen hist= rowmean(anc1lmp anc1depression anc1danger_screen previous_preg)
		egen counsel=rowmean(m1_counsel_nutri m1_counsel_exer m1_counsel_complic m1_counsel_birthplan edd ///
		m1_counsel_comeback)
		egen tx=rowmean(anc1ifa calcium deworm tt anc1itn)
	
	xtile group_anc1qual=anc1qual, nquantiles(4)
	gen q4_anc1=group_anc1qual==4
	
	gen q60=anc1qual>60

* Demographics & health
	gen second=educ_cat>=3
	gen healthlit_corr=m1_health_lit==4
	
	gen age_cat=enrollage
	recode age_cat 15/19=1 20/35=2 36/60=3
	lab def age_cat 1"15-19yrs" 2"20-35 yrs" 3 "36+yrs"
	lab val age_cat age_cat
	gen young= age_cat==1
	gen older=age_cat==3
	recode  m1_201 (1/3=0) (4/5=1), gen(poorhealth)
	
	recode m1_phq9 4/5=3, gen(depression_cat)
	lab def depression_cat 1"none-minimal 0-4" 2"Mild 5-9" 3"Moderate to severe 10+"
	lab val depression_cat depression_cat

	
* Medical risk factors
	
	replace m1_203_et = 0 if m1_203_other=="Anemia" | m1_203_other=="Chronic Sinusitis and tonsil" ///
	| m1_203_other=="gastritis" | m1_203_other=="Gastro intestinal track" ///
	| m1_203_other=="Hemorrhoids"  | m1_203_other=="Sinus" | m1_203_other=="Sinuse" ///
	| m1_203_other=="Sinusitis" | m1_203_other=="gastric"
	egen chronic = rowmax(m1_202a m1_202b m1_202c m1_202d m1_202e  m1_202g_et m1_203_et)
	replace chronic=1 if m1_HBP==1
	rename m1_malnutrition maln_underw
	
	egen ipv=rowmax(m1_1101 m1_1103)
	
* Obstetric risk factors
	gen multiple= m1_805 >1 &  m1_805<.
	gen cesa= m1_1007==1
	
	gen neodeath = m1_1010 ==1
	gen preterm = m1_1005 ==1
	gen PPH=m1_1006==1
	egen complic = rowmax(stillbirth neodeath preterm PPH cesa)
	egen complic4=rowmax(m1_1004 stillbirth m1_1005 m1_1010)
	

egen risk_score =rowtotal(young older multiple m1_202a m1_202b m1_202c m1_202d m1_202e  ///
							m1_202g_et m1_203_et cesa stillbirth  preterm PPH neodeath  ///
							 m1_anemic_7 m1_HBP)
	g crisk=risk_score
	recode risk_score 4/7=3
	
	
* Visit-level
	encode date_m1, gen(month)
	recode month 1/17=1 18/33=2
	lab def mo 1"April" 2"May"
	lab val month mo
	
	encode date_m1, gen(day)
	recode day 6=1 7=2 8=3 9=4 10=2 11=3 12=4 13=1 14=2 15=3 16=4 17=5 18=2 19=3 20=4 21=5 ///
		   22=1 23=2 24=3 25=4 26=5 27=1 28=2 29=3 30=4 31=5 32=1 33=1
	lab def day2 1"MON" 2"TUE" 3"WED" 4"THU" 5"FRI" 
	lab val day day2 
	
	encode m1_start_time, gen(time)
	recode time 1/8=2 9/20=3 21/202=1 203/321=2 322/418=3
	lab def time2 1"Morning" 2"Afternoon" 3"Evening"
	lab val time time2
	

save "$user/$analysis/ETtmp.dta", replace

*------------------------------------------------------------------------------*		
* KENYA
u "$user/$data/Kenya/02 recoded data/eco_m1_ke_der.dta", clear
		keep if module==1	// keep m1 data only
		rename study_site site
		egen tag=tag(facility)
* ANC quality
		gen ultrasound = anc1ultrasound if trimester>2 & trimester<. // 3rd trimester only
		gen edd2 = anc1edd if trimester>1 & trimester<. // 2nd or 3rd
		gen deworm = anc1deworm if trimester>1 & trimester<. // 2nd or 3rd
		gen tt= anc1tt
		replace tt =. if  m1_714c>=5 &  m1_714c<98 // had 5 or more previous lifetime doses
		replace tt =. if  m1_714c>=4 &  m1_714c<98 & m1_714e <=10 // had 4 or more incl. 1 in last 10 years
		replace tt =. if  m1_714c>=3 &  m1_714c<98 & m1_714e <=5 // had 3 or more incl. 1 in last 5 years
		replace tt =. if  m1_714c>=2 &  m1_714c<98 & m1_714e <=3 // had 2 or more incl. 1 in last 3 years
		g previous_preg=m1_1011a 
		
		egen anc1qual= rowmean(anc1bp anc1weight anc1height anc1muac anc1blood ///
		anc1urine ultrasound anc1lmp anc1depression previous_preg ///
		counsel_nutri counsel_exer counsel_complic counsel_birthplan edd2 ///
		counsel_comeback anc1ifa deworm tt anc1itn)
		replace anc1qual = anc1qual*100
		
		xtile group_anc1qual=anc1qual, nquantiles(4)
		gen q4_anc1=group_anc1qual==4
		
		gen q60=anc1qual>60
		
		egen phys_exam=rowmean(anc1bp anc1weight anc1height anc1muac)
		egen diag=rowmean(anc1blood anc1urine ultrasound)
		egen hist= rowmean(anc1lmp anc1depression previous_preg)
		egen counsel=rowmean(counsel_nutri counsel_exer counsel_complic counsel_birthplan edd2 ///
		counsel_comeback)
		egen tx=rowmean(anc1ifa deworm tt anc1itn)

* Demographics & health 
		recode educ_cat 1/2=0 3/4=1, gen(second)
		gen healthlit_corr=health_lit==4
		gen age_cat=enrollage
		recode age_cat 15/19=1 20/35=2 36/60=3
		lab def age_cat 1"15-19yrs" 2"20-35 yrs" 3 "36+yrs"
		gen young= age_cat==1
		gen older=age_cat==3
		recode  m1_201 (1/3=0) (4/5=1), gen(poorhealth)
	
		recode phq9_cat 4/5=3, gen(depression_cat)
		lab def depression_cat 1"none-minimal 0-4" 2"Mild 5-9" 3"Moderate to severe 10+"
		lab val depression_cat depression_cat

				
*Medical risk factors
		g other_chronic= 1 if m1_203_other=="Fibroids" | m1_203_other=="Peptic ulcers disease" ///
		| m1_203_other=="PUD" | m1_203_other=="Gestational Hypertension in previous pregnancy" ///
		| m1_203_other=="Ovarian cyst" | m1_203_other=="Peptic ulcerative disease"
		egen chronic= rowmax(m1_202a m1_202b m1_202c m1_202d m1_202e m1_203c_ke ///
		m1_203d_ke m1_203e_ke m1_203f_ke m1_203g_ke m1_203h_ke m1_203i_ke ///
		m1_203k_ke m1_203l_ke m1_203m_ke m1_203n_ke m1_203o_ke other_chronic)
		replace chronic=1 if HBP==1
		rename low_BMI maln_underw
		
		egen ipv=rowmax(m1_1101 m1_1103)
* Obstetric risk factors		
		gen multiple= m1_805 >1 &  m1_805<.
		gen cesa= m1_1007==1
		
		gen neodeath = m1_1010 ==1
		gen preterm = m1_1005 ==1
		gen PPH=m1_1006==1
		egen complic = rowmax(stillbirth neodeath preterm PPH cesa)
		egen complic4=rowmax(m1_1004 stillbirth m1_1005 m1_1010)
		
* Visit-level
		 *ssc install numdate
		 extrdate month month = m1_start_time
		 extrdate dow day = m1_start_time
		 recode day 6=5
		 extrdate hh time  = m1_start_time
		 recode time 9/11=1 12/14=2 15/23=3
		 lab def time2 1"Morning" 2"Afternoon" 3"Evening"
		 lab val time time2

		 egen risk_score =rowtotal(young older multiple m1_202a m1_202b m1_202c m1_202d m1_202e m1_203c_ke ///
		m1_203d_ke m1_203e_ke m1_203f_ke m1_203g_ke m1_203h_ke m1_203i_ke ///
		m1_203k_ke m1_203l_ke m1_203m_ke m1_203n_ke m1_203o_ke other_chronic HBP stillbirth ///
		neodeath preterm PPH cesa maln_underw anemic m1_814a m1_814b m1_814c m1_814d  m1_814f m1_814g )
		g crisk=risk_score
		 recode risk_score 4/7=3
save "$user/$analysis/KEtmp.dta", replace

*------------------------------------------------------------------------------*	
* SOUTH AFRICA 

u  "$user/$data/South Africa/02 recoded data/eco_m1_za_der.dta", clear
		drop if respondent =="NEL_045"	// missing entire sections 7 and 8		 				      
		rename  study_site_sd site
		egen tag=tag(facility)
		
* ANC quality
		gen edd = anc1edd if trimester>1 & trimester<.
		gen calcium = anc1calcium if trimester>1 & trimester<.
		gen tt= anc1tt
		replace tt =. if  m1_714c>=5 &  m1_714c<98 // had 5 or more previous lifetime doses
		replace tt =. if  m1_714c>=4 &  m1_714c<98 & m1_714e <=10 // had 4 or more incl. 1 in last 10 years
		replace tt =. if  m1_714c>=3 &  m1_714c<98 & m1_714e <=5 // had 3 or more incl. 1 in last 5 years
		replace tt =. if  m1_714c>=2 &  m1_714c<98 & m1_714e <=3 // had 2 or more incl. 1 in last 3 years
		g previous_preg=m1_1011a 
		
		egen anc1qual= rowmean(anc1bp anc1weight anc1height anc1muac anc1blood ///
		anc1urine anc1lmp anc1depression anc1danger_screen previous_preg ///
		counsel_nutri counsel_exer counsel_complic counsel_birthplan edd ///
		counsel_comeback anc1ifa calcium tt )
		replace anc1qual = anc1qual*100
		xtile group_anc1qual=anc1qual, nquantiles(4)
		gen q4_anc1=group_anc1qual==4
		
		gen q60=anc1qual>60
		
		egen phys_exam=rowmean(anc1bp anc1weight anc1height anc1muac)
		egen diag=rowmean(anc1blood anc1urine )
		egen hist= rowmean(anc1lmp anc1depression anc1danger_screen previous_preg)
		egen counsel=rowmean(counsel_nutri counsel_exer counsel_complic counsel_birthplan edd ///
		counsel_comeback)
		egen tx=rowmean(anc1ifa calcium  tt )

* Demographics & health 
		recode educ_cat 1/2=0 3/4=1, gen(second)
		gen healthlit_corr=health_lit==4
		gen age_cat=enrollage
		recode age_cat 15/19=1 20/35=2 36/60=3
		lab def age_cat 1"15-19yrs" 2"20-35 yrs" 3 "36+yrs"
		gen young= age_cat==1
		gen older=age_cat==3
		recode  m1_201 (1/3=0) (4/5=1), gen(poorhealth)
	
		recode phq9_cat 4/5=3, gen(depression_cat)
		lab def depression_cat 1"none-minimal 0-4" 2"Mild 5-9" 3"Moderate to severe 10+"
		lab val depression_cat depression_cat

* Medical risk factors
		egen chronic= rowmax(m1_202a m1_202b m1_202c m1_202d m1_202e)
		encode m1_203, gen(prob)
		recode prob (1/4 10 16 18/21 24 29 33 34 28 =0 ) (5/9 11/15 17 22 23 25 26 27 30 31 32=1)
		replace chronic = 1 if prob==1
		drop prob
		replace chronic=1 if HBP==1
		rename low_BMI maln_underw
		
		egen ipv=rowmax(m1_1101 m1_1103)
		
* Obstetric risk factors
		gen multiple= m1_805 >1 &  m1_805<.
		gen cesa= m1_1007==1
		
		gen neodeath = m1_1010 ==1
		gen preterm = m1_1005 ==1
		gen PPH=m1_1006==1
		egen complic = rowmax(stillbirth neodeath preterm PPH)
		egen complic4=rowmax(m1_1004 stillbirth m1_1005 m1_1010)
		
		
* Visit-level
		extrdate month month =date_m1
		extrdate dow day = date_m1
		encode m1_start_time, gen(time)
		recode time 2/11=2 12/217=1 218/344=2  345/369=3
		lab def time2 1"Morning" 2"Afternoon" 3"Evening"
		lab val time time2
* Risk score 
		encode m1_203, gen(prob)
		ta prob,g(dum)
			
 egen risk_score =rowtotal(young older multiple m1_202a m1_202b m1_202c m1_202d m1_202e HBP ///
				dum5 dum6 dum7 dum8 dum9 dum11 dum12 dum13 dum14 dum15 dum17 dum22 ///
				dum23 dum25 dum26 dum27 dum30 dum31 dum32 stillbirth neodeath preterm ///
				PPH maln_underw anemic m1_814a m1_814b m1_814c m1_814d  m1_814f m1_814g )
		g crisk=risk_score
		recode risk_score 4/9=3
		
save "$user/$analysis/ZAtmp.dta", replace

*------------------------------------------------------------------------------*
* INDIA
u "$user/$data/India/02 recoded data/eco_m1_in_der.dta", clear	

* ANC quality
		gen edd = anc1edd if trimester>1 & trimester<.  // 2nd or 3rd trimester only
		gen ultra =anc1ultrasound if trimester>2 & trimester<. // 3rd trimester only
		gen calcium = anc1calcium if trimester>1 & trimester<. // 2nd or 3rd trimester only
		gen tt= anc1tt
		replace tt =. if  m1_714c>=5 &  m1_714c<98 // had 5 or more previous lifetime doses
		replace tt =. if  m1_714c>=4 &  m1_714c<98 & m1_714e <=10 // had 4 or more incl. 1 in last 10 years
		replace tt =. if  m1_714c>=3 &  m1_714c<98 & m1_714e <=5 // had 3 or more incl. 1 in last 5 years
		replace tt =. if  m1_714c>=2 &  m1_714c<98 & m1_714e <=3 // had 2 or more incl. 1 in last 3 years
		
		g previous_preg=m1_1011a 

		egen anc1qual= rowmean(anc1bp anc1weight anc1blood ///
		anc1urine ultra anc1lmp  previous_preg counsel_nutri  counsel_complic counsel_birthplan edd ///
		counsel_comeback anc1ifa calcium anc1deworm tt )
		
		replace anc1qual = anc1qual*100
		
		egen phys_exam=rowmean(anc1bp anc1weight)
		egen diag=rowmean(anc1blood anc1urine ultra )
		egen hist= rowmean(anc1lmp previous_preg)
		egen counsel=rowmean(counsel_nutri  counsel_complic counsel_birthplan edd counsel_comeback)
		egen tx=rowmean(anc1ifa calcium anc1deworm tt )

		egen ipv=rowmax(m1_1101 m1_1103)

* Demographics & health 
		recode educ_cat 1/2=0 3/4=1, gen(second)
		gen healthlit_corr=m1_health_lit==4
		gen age_cat=enrollage
		recode age_cat 15/19=1 20/35=2 36/60=3
		lab def age_cat 1"15-19yrs" 2"20-35 yrs" 3 "36+yrs"
		gen young= age_cat==1
		gen older=age_cat==3
		recode  m1_201 (1/3=0) (4/5=1), gen(poorhealth)
	
		recode phq9_cat 4/5=3, gen(depression_cat)
		lab def depression_cat 1"none-minimal 0-4" 2"Mild 5-9" 3"Moderate to severe 10+"
		lab val depression_cat depression_cat
		
* Medical risk factors
		egen chronic= rowmax(m1_202a m1_202b m1_202c m1_202d m1_202e m1_203)
		replace chronic=1 if HBP==1
		rename low_BMI maln_underw
		
* Obstetric risk factors
		gen multiple= m1_805 >1 &  m1_805<.
		gen cesa= m1_1007==1
		
		gen neodeath = m1_1010 ==1
		gen preterm = m1_1005 ==1
		gen PPH=m1_1006==1
		egen complic = rowmax(stillbirth neodeath preterm PPH)
		egen complic4=rowmax(m1_1004 stillbirth m1_1005 m1_1010)
		
save "$user/$analysis/INtmp.dta", replace





















