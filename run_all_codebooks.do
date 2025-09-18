	global Country ET
	capture erase "${et_data_final}/${Country}_Codebooks.xlsx"

	
	use "$et_data_final/eco_ET_Complete.dta", clear
	* Missing Module for 3 vars in M4
	char m4_411a[Module] 4 
	char m4_411b[Module] 4
	char m4_411c[Module] 4
	
	save "$et_data_final/eco_ET_Complete.dta", replace
	
	foreach v in 0 1 2 3 4 5 6 {
		create_module_codebook, country(Ethiopia) outputfolder($et_data_final) codebook_folder($et_data_final\archive\Codebook) module_number(`v') module_dataset(eco_ET_Complete) id(respondentid) special
	}

	****************************************************************************
	
	global Country IN
	capture erase "${in_data_final}/${Country}_Codebooks.xlsx"
	
	* It looks as though some modules are missing the modules
	* A few variables form M4 and alot from M5
	* add these then run the below code
	use "$in_data_final/eco_IN_Complete", clear

	* Create the codebooks
	foreach v in 0 1 2 3 4 5 { 
		create_module_codebook, country(IN) outputfolder($in_data_final) codebook_folder($in_data_final/Archive/Codebook) module_number(`v') module_dataset(eco_IN_Complete) id(respondentid) special
		
	}
	
	****************************************************************************

	global Country KE
	capture erase "${ke_data_final}/${Country}_Codebooks.xlsx"
	
	use "$et_data_final/eco_ET_Complete.dta", clear

	* Looks as though for some reason the Module char is missing from this var
	char m4_date_delivery[Module] 4
	save "$et_data_final/eco_ET_Complete.dta", replace

	* Create the codebooks
	foreach v in 0 1 2 3 4 5 6 {
		create_module_codebook, country(Kenya) outputfolder($ke_data_final) codebook_folder($ke_data_final\archive\Codebook) module_number(`v') module_dataset(eco_KE_Complete) id(respondentid) special
	}
	
	****************************************************************************
	
	capture erase "${za_data_final}/${Country}_Codebooks.xlsx"
	global Country ZA

	use "$za_data_final/eco_ZA_Complete.dta", clear
	* Add char to this var 
	char m5_505_1[Module] 5
	save "$za_data_final/eco_ZA_Complete.dta", replace
	foreach v in 0 1 2 3 4 5  {

		create_module_codebook, country(South Africa) outputfolder($za_data_final) codebook_folder($za_data_final/archive/Codebook) module_number(`v') module_dataset(eco_ZA_der) id(respondentid) special
		
	}