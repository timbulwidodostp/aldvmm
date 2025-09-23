*! version 1.1  September 2016 - -Added support for margins and svy with linearized variance
*! version 1.0  24 October 2014
*! author: Monica Hernandez Alava

/********************************************************************/
/*   Adjusted Limited Dependent Variable Mixture model              */
/*   for cross sectional data. Predictions */
/********************************************************************/

program define aldvmm_p
	version 13.1
	
				/* handle scores */
	syntax [anything] [if] [in] [, SCores * ]
	
	
	if ("`e(cmd)'" != "aldvmm") {
			error 301
			display in red  "aldvmm was not the last command"
		}	
	
	// Mark the prediction sample
	marksample touse, novarlist
	markout `touse' `e(indepvars1)' `e(indepvars2)'

	// Return error if no observations
	qui count if `touse'
	if r(N) == 0 {
		error 2000
	}
	
		// Generate variables needed for mata
		local ncomp = e(k_aux)
		mata: aldvmm_ncomp = strtoreal(st_local("ncomp"))	
		
				
		local top = e(psi1)
		local bot = e(psi2)
		mata: aldvmm_top =strtoreal(st_local("top"))
		mata: aldvmm_bot =strtoreal(st_local("bot"))
		
		
				
		mata: aldvmm_x = 1		
		mata: aldvmm_probc = 1	
		mata: aldvmm_y = 1
		
		local n : word count `e(indepvars1)'		
		/*if `n' != 0 {
			
			local temp `e(indepvars1)'
			mata: st_view(aldvmm_x, ., st_local("temp"), st_local("touse"))
						
		}			
		
		local n : word count `e(indepvars2)'		
		if `n' != 0 {
			
			local temp `e(indepvars2)'
			mata: st_view(aldvmm_probc, ., st_local("temp"), st_local("touse"))
						
		}
		*/
		
		local temp e(depvar)
		mata: st_view(aldvmm_y, ., st_local("`e(depvar)'"), st_local("touse"))

	//set trace on
	
    if `"`scores'"' != "" {
		_score_spec `0'
		//noi di "_score_spec `0'"
		local varn `s(varlist)'
		local vtyp `s(typlist)'
			
		ml score `:word 1 of `vtyp'' `varn' if `touse'	
		exit

    }

	
	//local myopts "OUTcome(string)"
	
	local myopts "OUTcome(string)"
    _pred_se "`myopts'" `0'
	
	if `s(done)'  exit 
    local vtyp `s(typ)'
    local varn `s(varn)'
    local 0    `"`s(rest)'"'
    syntax [if] [in] [, `myopts']
	local temp ""
	forvalues  i = 1(1)`ncomp' {
		tempvar xx`i'
		qui _predict double `xx`i''  if `touse', xb equation(Comp_`i')
		local temp "`temp' `xx`i''"
	}
	mata: st_view(aldvmm_x, ., st_local("temp"), st_local("touse"))
	local temp ""
	forvalues  i = 1(1)`=`ncomp'-1' {
		tempvar px`i'
		qui _predict double `px`i''  if `touse', xb equation(Prob_C`i')
		local temp "`temp' `px`i''"	
	}
	if `ncomp' > 1 {
		mata: st_view(aldvmm_probc, ., st_local("temp"), st_local("touse"))
	}
		
	
	// Outcome can be  y (the final index only),  all  OR #positive integer
	if "`outcome'" == "" {
		local outcome "y"
	}
	
	if (("`outcome'" != "y") & ("`outcome'" != "all")) {
		local outcome : subinstr local outcome "#" ""
		capture assert `outcome' == abs(int(`outcome'))
		if _rc != 0 | (`outcome'<1 | `outcome' > `ncomp') {
			display in red "The outcome selected is invalid."
			exit 198
		}
	}
	
	

		
		tempname b
		matrix `b' = e(b)
		
		
		//local temp "`anything'"
		qui gen double `varn' = .
		
		local newlist `varn'
		
		if "`outcome'" == "y" {
			mata: outp = 0 //pass the output level to mata (only predicted y)
			
			
		}
		else if "`outcome'" == "all" {
			mata: outp = 1
			
					
			forvalues i = 1(1)`ncomp' {
				local temp "`varn'_y`i'"
				qui gen double `temp' = .
				local newlist `newlist' `temp'
			}	
					
			
			forvalues i = 1(1)`ncomp' {
				local temp "`varn'_p`i'"
				qui gen double `temp' = .
				local newlist `newlist' `temp'
			}

		}
		else {
			mata: outp = 2
			mata: aldvmm_out = strtoreal(st_local("outcome"))
			
		}
		//di in red "`newlist'"
		mata: aldvmm_pred("`b'", "`newlist'", "`touse'")
	
end	
/********************************************************************************************************************/
mata:
mata set matastrict on
void aldvmm_pred(string scalar b, string scalar vars, string scalar touse_p)
{external aldvmm_ncomp, aldvmm_probc, aldvmm_x, aldvmm_y, outp, aldvmm_top, aldvmm_bot, aldvmm_out

real colvector tmp
real rowvector s_e, b0
real matrix exb, probc, tmp1, tmp2, tmp3, bet, delt, pr1, pr2, indx0, eyc, ey
real scalar i, ncomp, psi, psi2, kx, kz, nobs, outy

psi = aldvmm_top
psi2 = aldvmm_bot



outy = aldvmm_out

ncomp = aldvmm_ncomp
nobs = rows(aldvmm_y)
if (rows(aldvmm_probc) == 1) {
	aldvmm_probc = J(nobs,1,1)
}
b0=st_matrix(b)

s_e = exp(b0[(cols(b0)-ncomp+1) .. cols(b0)])

s_e = s_e :* J(nobs, ncomp,1)

if (ncomp > 1) {
	probc = exp(aldvmm_probc)

	probc = probc, J(rows(probc), 1, 1)
	tmp = rowsum(probc)
	probc = probc :/ tmp
}
else {
	probc = aldvmm_probc
}	

tmp = (psi:- aldvmm_x):/s_e
pr1 = normal(-tmp)

tmp2 = (psi2:-aldvmm_x):/s_e
pr2 = normal(tmp2)

tmp3 = normalden(tmp,0,1)- normalden(tmp2,0,1)

indx0 = (tmp3:>= J(1,ncomp,-1E-08)) :& (tmp3:<= J(1,ncomp,1E-08))
tmp1 = indx0 + (1:-indx0) :*(pr2 - normal(tmp))


eyc = aldvmm_x + ((s_e):* (tmp3:/tmp1))
eyc = pr1 + ((1:-pr1:-pr2) :* eyc) + (pr2 :* J(1,ncomp,psi2))


ey = eyc :* probc
ey = rowsum(ey)

if (outp == 1) {
	ey= ey, eyc,probc
}	

else if (outp == 2) {
	
	ey= eyc[.,outy]
}
st_store(., tokens(vars),touse_p, ey)

}

end




