*! version 1.1  September 2016 - -Added support for margins and svy with linearized variance
*! version 1.0  27 October 2014
*! author: Monica Hernandez Alava

/********************************************************************/
/*   Adjusted Limited Dependent Variable Mixture model              */
/*   for cross sectional data. Stata code for Panel Data is under   */
/*   development. */
/********************************************************************/

program aldvmm, properties(svyb svyj svyr)
	version 13.1

	if replay() {
		if ("`e(cmd)'" != "aldvmm") error 301
		Replay `0'
	}
	else Estimate `0'
end


program Replay
	syntax [, Level(cilevel)]
	
/*	local ncomponents `e(k_aux)'
	local probabilities `e(indepvars2)'
	
	// Calculate sigmas from ln(sigma)

	
	forvalues  i = 1(1)`ncomponents' {
		local sigmas `"`sigmas' diparm(lns_`i', exp label("sigma`i'"))"'		
	}
	local sigmas `"`sigmas'"'
	

	// Calculate probabilities if constant probabilities
	if "`probabilities'" == "" {
		if `ncomponents' == 2 {
			local pis `" diparm(Prob_C1, invlogit label(pi1))"'					
			local pis `"`pis'  diparm(Prob_C1, func(1-exp(@)/(1+exp(@))) der(-exp(@)/((1+exp(@))^2)) label(pi2))"'
							
		}
		if `ncomponents' >= 3 {
			local den "1"
	
			forvalues i=1/`=`ncomponents'-1' {
				local den `"`den'+exp(@`i')"'
				local invml `"`invml' Prob_C`i'"'
			}
			forvalues i=1/`=`ncomponents'-1' {
				local prob`i' `"diparm( `invml', func(exp(@`i')/(`den')) der("'
				forvalues j=1/`=`ncomponents'-1' {
					if `i'==`j' {					
						local prod `"`den'-exp(@`i')"'
						local der`i'`j' `"+0+exp(@`i')*(`prod')/((`den')^2)"'
					}
					else {
						local der`i'`j' `"-exp(@`i')*exp(@`j')/((`den')^2)"'
					}					
					local prob`i' `"`prob`i'' `der`i'`j''"'
				}				
				local prob`i' `" `prob`i'' ) label(pi`i') ci(logit) )"' /*)*/
				
				local pis `"`pis' `prob`i''"'
			}
			forvalues j=1/`=`ncomponents'-1' {
				forvalues i=1/`=`ncomponents'-1' {
					local sumder`j' `"`sumder`j''`der`i'`j''"'
				}
				local derivs `"`derivs'`sumder`j'' "'
			}
			local pis `"`pis' diparm(`invml', func(1-(`den'-1)/(`den')) der(`derivs') label(pi`ncomponents'))"'		
		}
	}
	
	
	
	
	/***********************************************************/
	if "`probabilities'" == "" {
		
		ml display, level(`level') `sigmas' `pis'

	}
		
	else {
		ml display, level(`level') `sigmas'
	}
		*/
	ml display, level(`level') 
	
	 
end	

program Estimate, eclass sortpreserve
	syntax varlist(min=1 fv) [if] [in]  [fweight pweight iweight aweight] ///
		, NCOMPonents(integer) [PROBabilities(varlist fv) INIMethod(string) country(string) llim(real -999) ulim(real -999) vce(passthru) Level(cilevel) ///
		SEarch(string) FRom(string) Repeat(string) SAOPTs(string) SASLim(string) SAPARMax(string) Constraints(string) *]
	mlopts mlopts, `options'
	
		
	gettoken depv indv  : varlist
	
	if "`weight'" != "" {
		local wgt "[`weight' `exp']"
	}
	
	/*if "`search'" == "" {
		local search "off"
	}*/
	
	if "`inimethod'" == "" {
		local inimethod "single"
	}
	
	
	if "`repeat'" == "" {
		local repeat = 10 //use 10 repeats as default
	}
	
	if "`inimethod'" != "simann" & "`saopts'" != "" {
		display in red "simann is not the selected algorithm => saopts() is ignored"
		exit 498
	}
	if "`inimethod'" != "simann" & "`saslim'" != "" {
		display in red "simann is not the selected algorithm => saslim() is ignored"
		exit 498
	}
	if "`inimethod'" != "simann" & "`saparmax'" != "" {
		display in red "simann is not the selected algorithm => saparmax() is ignored"
		exit 498
	}
	
	if "`inimethod'" == "simann" & "`saopts'" != "" {
		mata: saoptpar = st_matrix(st_local("saopts"))		
	}
	
	
	if "`inimethod'" == "simann" & "`saslim'" != "" {
		mata: saselims = st_matrix(st_local("saslim"))	
	}
	else if "`inimethod'" == "simann" & "`saslim'" == "" {
		mata: saselims = J(1,1,.)
	}
	
	if "`inimethod'" == "simann" & "`saparmax'" != "" {
		mata: saparmaxval = strtoreal(st_local("saparmax"))
	}
	else if "`inimethod'" == "simann" & "`saparmax'" == "" {
		mata: saparmaxval = J(1,1,.)
	}
	
	if "`inimethod'" != "single" &  "`inimethod'" != "cons" & "`inimethod'" != "simann" {
		display in red "inimethod must be single, cons or simann"
		exit 198
	}
	
	
	
	//Check independent variable is not a factor variable
	_fv_check_depvar `depv'

		
	// mark the estimation sample
	marksample touse
	markout `touse' `probabilities'
	
	_vce_parse `touse', opt(Robust opg oim) argopt(CLuster) : `wgt' , `vce'
	
		if `llim' == -999 & `ulim' == -999 {
	
	
		if "`country'" == "" {
			local country "UK"
		}	
		if ("`country'" != "UK" &  "`country'" != "US" & "`country'" != "uk" &  "`country'" != "us") {
			display in red "country must be UK or US"
			exit 198
		}
		if "`country'" == "UK" | "`country'" == "uk" {
			
			capture assert `depv' ==1 | (`depv'<=0.883 & `depv' >= -0.594) if `touse'
			
			if _rc == 9 {
				di in red "Some observations of EQ-5D are outside the UK tariff limits."
				di in red "Check the coding of the data. EQ-5D takes values from -0.594 to 0.883 or 1."
				exit 498
			}
			scalar lim1 = 0.883
			scalar lim2 = -0.594
			mata: aldvmm_top = 0.883
			mata: aldvmm_bot = -0.594
		}
		else if "`country'" == "US" | "`country'" == "us" {
			capture assert `depv' ==1 | (`depv'<=0.860 & `depv' >= -0.109) if `touse'
			if _rc == 9 {
				di in red "Some observations of EQ-5D are outside the US tariff limits."
				di in red "Check the coding of the data. EQ-5D takes values from -0.109 to 0.860 or 1."
				exit 498
			}
			scalar lim1 = 0.860
			scalar lim2 = -0.109
			mata: aldvmm_top = 0.860
			mata: aldvmm_bot = -0.109
		}
	}
	else if `llim' != -999 & `ulim' != -999 {
		if "`country'" != "" {
			display in red "Lower and upper limits are used. Country is ignored"
		}
		local country "Unknown"
		
		capture assert `depv' ==1 | (`depv'<=`ulim' & `depv' >= `llim') if `touse'
			if _rc == 9 {
				di in red "Some observations on EQ-5D are outside the user defined tariff limits."
				di in red "Check the coding of the data and/or the EQ-5D limits supplied"
				exit 498
			}
		scalar lim1 = `ulim'
		scalar lim2 = `llim'
		mata: aldvmm_top =strtoreal(st_local("ulim"))
		mata: aldvmm_bot =strtoreal(st_local("llim"))
		
	}
	else {
		display in red "Both limits must be specified."
		exit 198
	
	}
	
	// Return error if no observations
	qui count if `touse'
	if r(N) == 0 {
		error 2000
	}
	
	// get rid of collinear variables
	_rmcoll `indv' if `touse'
	local indv `r(varlist)'
	_rmcoll `probabilities' if `touse'
	local probabilities `r(varlist)'
	
	//set number of components scalar for mata
	mata: aldvmm_ncomp = strtoreal(st_local("ncomponents"))
	
		
		
	// create equations for the components
	if "`indv'" != "" {
	
		local equs `"`equs' (Comp_1: `depv' = `indv')"'
		forvalues  i = 2(1)`ncomponents' {
			local equs `"`equs' (Comp_`i': `indv')"'			
		}
	}
	
	else {
		
		local equs `"`equs' (Comp_1: `depv' =   )"'
		forvalues  i = 2(1)`ncomponents' {
			local equs `"`equs' (Comp_`i':)"'
		}
	}
	
	if "`probabilities'" == "" {
		forvalues  i = 1(1)`=`ncomponents'-1' {
			local equs `"`equs' /Prob_C`i'"'
		}	
	}
	else {
		forvalues  i = 1(1)`=`ncomponents'-1' {
			local equs `"`equs' (Prob_C`i': `probabilities')"'
		}
	}
	
	forvalues  i = 1(1)`ncomponents' {
		local equs `"`equs' /lns_`i'"'
	}
	
	// Set up the model and maximize
	local equs `"`equs'"'
	
	// starting values
	if "`from'" !=""  {
		if "`inimethod'" == "cons" {
			local initcond init(`from', copy) search(on) repeat(`repeat')
		}
		else if "`inimethod'" == "starts" {
			local initcond search(`search') repeat(`repeat')
		}
		else {
			local initcond init(`from', copy) search(`search') repeat(`repeat')
		}
	}
	else {
		local initcond search(`search') repeat(`repeat')
	}
	
/**********************diparm option for ml **********************/
	
	// Calculate sigmas from ln(sigma)

	
	forvalues  i = 1(1)`ncomponents' {
		local sigmas `"`sigmas' diparm(lns_`i', exp label("sigma`i'"))"'		
	}
	local sigmas `"`sigmas'"'
	

	// Calculate probabilities if constant probabilities
	if "`probabilities'" == "" {
		if `ncomponents' == 2 {
			local pis `" diparm(Prob_C1, invlogit label(pi1))"'					
			local pis `"`pis'  diparm(Prob_C1, func(1-exp(@)/(1+exp(@))) der(-exp(@)/((1+exp(@))^2)) label(pi2))"'
							
		}
		if `ncomponents' >= 3 {
			local den "1"
	
			forvalues i=1/`=`ncomponents'-1' {
				local den `"`den'+exp(@`i')"'
				local invml `"`invml' Prob_C`i'"'
			}
			forvalues i=1/`=`ncomponents'-1' {
				local prob`i' `"diparm( `invml', func(exp(@`i')/(`den')) der("'
				forvalues j=1/`=`ncomponents'-1' {
					if `i'==`j' {					
						local prod `"`den'-exp(@`i')"'
						local der`i'`j' `"+0+exp(@`i')*(`prod')/((`den')^2)"'
					}
					else {
						local der`i'`j' `"-exp(@`i')*exp(@`j')/((`den')^2)"'
					}					
					local prob`i' `"`prob`i'' `der`i'`j''"'
				}				
				local prob`i' `" `prob`i'' ) label(pi`i') ci(logit) )"' /*)*/
				
				local pis `"`pis' `prob`i''"'
			}
			forvalues j=1/`=`ncomponents'-1' {
				forvalues i=1/`=`ncomponents'-1' {
					local sumder`j' `"`sumder`j''`der`i'`j''"'
				}
				local derivs `"`derivs'`sumder`j'' "'
			}
			local pis `"`pis' diparm(`invml', func(1-(`den'-1)/(`den')) der(`derivs') label(pi`ncomponents'))"'		
		}
	}
	
	
	
	
	/***********************************************************/
	if "`probabilities'" == "" {
		
		local dipa `"`sigmas' `pis' "'

	}
		
	else {
		local dipa `"`sigmas' "'
	}
	
	local title "`ncomponents' component Adjusted Limited Dependent Variable Mixture Model"
	local title `title'
	local waldk = 1 - 2 * `ncomponents'
	if "`inimethod'" == "cons" {
		local equs0 `"`equs0' (Comp_1: `depv' =   )"'
		forvalues  i = 2(1)`ncomponents' {
			local equs0 `"`equs0' (Comp_`i':)"'
		}
		forvalues  i = 1(1)`=`ncomponents'-1' {
			local equs0 `"`equs0' (Prob_C`i':)"'
		}		
		forvalues  i = 1(1)`ncomponents' {
			local equs0 `"`equs0' /lns_`i'"'
		}
		
		display as txt _n "Fitting constant-only model:"
		ml model lf1 aldvmm_lf() `equs0' `wgt' if `touse', `mlopts' `initcond'  `svy'  ///
	        repeat(100) collinear missing maximize
		display as txt _n "Fitting full model:"
	
		ml model lf1 aldvmm_lf() `equs' `wgt' if `touse', `vce' `mlopts' continue search(on) repeat(`repeat') ///
	        collinear missing constraints(`constraints') title(`title') waldtest(`waldk') `svy' `dipa' maximize
	}
	else if "`inimethod'" == "single" {
		ml model lf1 aldvmm_lf() `equs' `wgt' if `touse', `vce' `mlopts' `initcond' ///
	        collinear missing constraints(`constraints') title(`title') waldtest(`waldk') `svy' `dipa' maximize
	}
	
	else if "`inimethod'" == "simann" {
		// run simann first.
		set seed 123
		//create labels for matrix
			
		local n : word count `indv'
		forvalues  i = 1(1)`ncomponents' {
			if `n' != 0 {
				tokenize `indv'
				forvalues j=1(1)`n' {
					local parnames `"`parnames' [Comp_`i']:`j'"'			
				}	
			}
			local parnames `"`parnames' [Comp_`i']:_cons"'
			local temp `"`temp' \lnsig`i'"'
		}
		
		local n : word count `probabilities'
		forvalues  i = 1(1)`=`ncomponents'-1' {
			if `n' != 0 {
				tokenize `probabilities'
				forvalues j=1(1)`n' {
					local parnames `"`parnames' [Prob_`i']:`j'"'			
				}	
			}
			local parnames `"`parnames' [Prob_`i']:_cons"'
			
		}
		local parnames `"`parnames' `temp'"'
		
		
		// pass data to simman likelihood function
		mata: aldvmm_y = 1
		mata: aldvmm_x = 1
		mata: aldvmm_probc = 1
		mata: st_view(aldvmm_y, ., st_local("depv"), st_local("touse"))
		mata: st_view(aldvmm_x, ., tokens(st_local("indv")), st_local("touse"))
		mata: st_view(aldvmm_probc, ., st_local("probabilities"), st_local("touse"))

		mata: par=0
		display as txt _n "Fitting model using simulated annealing:"
		if "`from'" == "" {		
			mata: npar = aldvmm_ncomp*(cols(aldvmm_x)+1) + aldvmm_ncomp + (cols(aldvmm_probc) + 1) * (aldvmm_ncomp-1)
			mata: inipar = J(1, npar-aldvmm_ncomp,-0.1), J(1, aldvmm_ncomp,-0.1)
		}
		else {
			mata: inipar = st_matrix(st_local("from"))
			//mata:"matrix inipar"
			//mata: inipar
			
		}
		if "`saopts'" == "" {
			mata: par = simann( &aldvmm_lfsa(),inipar)
		}
		else {
			mata: par = simann( &aldvmm_lfsa(), inipar, saoptpar[1,1], saoptpar[1,2],saoptpar[1,3],saoptpar[1,4],saoptpar[1,5],saoptpar[1,6])
		} 
		mata: st_matrix("inisa", par)
		
		
		mata: fun = aldvmm_lfsa(par)
		mata: st_numscalar("loglfun", fun)
		//mata: 
		display as txt _n "log likelihood = " -loglfun
		display as txt _n "Estimated parameters using Simann = " 
		matrix colnames inisa = `parnames'
		matrix list inisa
		
		// use the final values from simann as initial values for ml
		display as txt _n "Fitting model using local optimization algorithm:"
		ml model lf1 aldvmm_lf() `equs' `wgt' if `touse', `vce' `mlopts' init(inisa, copy) search(on) ///
	        collinear missing constraints(`constraints') title(`title') waldtest(`waldk') `svy' `dipa' maximize
	}
	

	//ml check
	
	// Return extra results
	ereturn local indepvars1 `indv'	
	ereturn local indepvars2 `probabilities'	
	ereturn local cmd aldvmm
	ereturn scalar k_aux = `ncomponents'
	ereturn local predict "aldvmm_p"
	ereturn local country `country'
	ereturn scalar psi1 = lim1
	ereturn scalar psi2 = lim2
	ereturn local marginsok "default"
	
	Replay, level(`level')
	
	
end
	
