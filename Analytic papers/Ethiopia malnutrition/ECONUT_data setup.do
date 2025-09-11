** Emma Clarke-Deelder
** Replication code for: "Screening, prevention, and management of maternal acute malnutrition and anemia in Ethiopia: evidence from a longitudinal eCohort study"
** Data setup

* Set-up
clear all

* Set globals
global datafolder "J:\HEHS\HE\Emma\Maternal health ecohorts\Ethiopia malnutrition\Github"
global outputfolder "J:\HEHS\HE\Emma\Maternal health ecohorts\Ethiopia malnutrition\Github\Output"

* Install relevant programs
ssc install codebookout
ssc install table1_mc
ssc install variog 
ssc install qic 

* Set current directory
cd "J:\HEHS\HE\Emma\Maternal health ecohorts\Ethiopia malnutrition\Github"

* Run variable creation file
run "crECONUT01.do"

* Create analytic dataset
keep site sampstrata redcap_record_id facility muac_under23 hb_under11 bmi_under18p5 anemia_adj anemia_sev malnourished_double m1_enrollage m1_enrollage_cat m1_ga m1_date m1_trimester m1_713a m1_1001 m1_height_cm m1_weight_kg past_complications comorbidity formalemployment education_simp m1_1221 quintile firstpregnancy m0_a6_fac_type m0_a8_fac_own m0_a9_urban facility_anc1volume facility_ancrepeatvolume fac_bp_any fac_bp_functioning fac_scale_any fac_scale_functioning fac_measuringtape_any fac_measuretape_functioning fac_haemoglobintest_any fac_haemoglobintest_onsite m1_702 m1_701 m1_703 blooddraw_any_anc1_binary ifapills_firstanc antimalarial_anc1 nutri_counseling_anc1 nutri_counseling_anc1 told_when_to_come_back knows_anemic_anc1 nutrisup_anc1 m1_1306 weight_recorded weight_ever weight_atleast2 weight_atleast8 ifapills_firstanc multivitamins_firstanc ifapills_everduringpregnancy multivitamins_everpreg delivery_counseled_nutrition bloodtests_ever bloodtests_atleast2 bloodtests_atleast3 multivitamins_firstanc calcium_firstanc deworming_firstanc antimalarial_anc1 bednet_anc1 bednet_counseling_anc1  multivitamins_everpreg calcium_everpreg deworming_everpreg antimalarial_everpreg m2_302_r* m2_305_r* m2_308_r* m2_310* m2_314_r* m2_317_r* m2_502_r* m2_505a_r* m2_601a_r* m2_603_r* m2_604_r* m2_date_r*  m2_202* m2_ga_r* m2_301_r* m2_302_r* m2_305_r* m2_308_r* m2_311_r* m2_502_r* m2_604_r* m2_date_r* m2_205a_r* m2_205b_r* m2_205c_r* m2_205d_r* m2_205e_r* m2_205f_r* m2_205g_r* m2_205h_r* m2_205i_r* m2_603_r* m2_204d* routine_consults_atleast4 count nutrisup_everpreg ifapills_everduringpregnancy ifa_adherence_complete_daily education m1_ga_4weeks depress  m2_202_r* m2_501b_r* m2_501c_r* m2_501d_*

save "$datafolder/econut_analyticdata_10sept2025.dta", replace

codebookout "$datafolder/econut_codebook.xlsx", replace

