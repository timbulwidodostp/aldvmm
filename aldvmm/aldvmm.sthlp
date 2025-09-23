{smcl}
{* documented: September 2016}{...}
{cmd:help aldvmm}{right: ({browse "http://www.stata-journal.com/article.html?article=up0053":SJ16-4: st0401_1})}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col:{hi:aldvmm} {hline 2}}Adjusted limited dependent variable mixture
model{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:aldvmm} {depvar} [{indepvars}] {ifin} {weight}{cmd:,} {opt ncomp:onents(#)}
[{it:options}]{p_end}

{pstd}
{cmd:aldvmm} requires Stas Kolenikov's simulated annealing package
({cmd:simann()}) to be installed.  Type 
{cmd:net install simann.pkg, from(http://web.missouri.edu/~kolenikovs/stata)}
to install the {cmd:simann()} Mata function.{p_end}

{synoptset 28 tabbed}{...}
{marker aldvmm_options}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt ncomp:onents(#)}}number of mixture components{p_end}
{synopt :{opth prob:abilities(varlist)}}specify variables used to model the component
probabilities; default is constant probabilities{p_end}
{synopt :{opt country(country)}}specify {it:country}; may be {opt UK} or {opt US}; default is {cmd:country(UK)}{p_end}
{synopt :{opt llim(#)}}specify user-supplied lower limit of EQ-5D{p_end}
{synopt :{opt ulim(#)}}specify user-supplied highest EQ-5D index value below 1{p_end}
{synopt :{opth c:onstraints(numlist)}}apply specified linear constraints{p_end}
{synopt :{opth vce(vcetype)}}specify how to estimate variance-covariance matrix; {it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, or {opt cl:uster} {it:clustvar}{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt inim:ethod(inimethod)}}specify how to choose starting values for parameters; {it:inimethod} may be {opt single}, {opt cons}, or {opt simann}; default is {cmd:inimethod(single)}{p_end}
{synopt :{opt saopt:s(matrix)}}specify the name of the matrix{p_end}
{synopt :{it:{help aldvmm##aldvmm_maximize:maximize_options}}}control the maximization process; some options may be especially useful{p_end}
{synopt :{opt se:arch(spec)}}specify whether {helpb ml}'s initial search algorithm is used{p_end}
{synopt :{opt r:epeat(#)}}specify the number of random attempts to be
made to find a better initial-value vector{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt ncomponents(#)} is required.{p_end}
{p 4 6 2}{helpb svy} is allowed.  {cmd:svy} may not be
specified with the {cmd:vce()} option or with {it:weight}s.{p_end}
{p 4 6 2}{cmd:aldvmm} typed without arguments redisplays previous results.{p_end}
{p 4 6 2}{cmd:fweight}s and {cmd:pweight}s are allowed; see {help weight}.{p_end}
{p 4 6 2}See {help aldvmm postestimation} for features available after
estimation.


{title:Description}

{pstd}
{cmd:aldvmm} is a user-written program that fits an adjusted limited dependent
variable mixture model ({help aldvmm##references:Hern{c a'}ndez et al. 2013})
of {depvar} on {indepvars} using maximum likelihood estimation.  The model is
a C-component mixture of densities adjusted to deal with EQ-5D data.  The mean
of a density within a component as well as the mixing probabilities may be
functions of covariates.  The default model allows the variances of the
components to be different, but they can be constrained to be the same.


{title:Options}

{phang}
{opt ncomponents(#)} specifies the number of mixture components.  Strictly, a
mixture model has a minimum of two components, but {cmd:aldvmm} does allow the
estimation of a model with only one component.  This one-component model is
similar to a tobit model but can reflect the gap found in EQ-5D.
{cmd:ncomponents()} is required.

{phang}
{opth probabilities(varlist)} specifies a set of variables to be used to model
the probability of component membership.  The probabilities are specified
using a multinomial logit parameterization.  The default is to use constant
probabilities.

{phang}
{opt country(country)} specifies the EQ-5D tariff.  The string {it:country}
may be {cmd:UK} or {cmd:US}.  The default is {cmd:country(UK)}.  This option
is ignored if {opt llim(#)} and {opt ulim(#)} are supplied by the user.

{phang}
{opt llim(#)} specifies the user-supplied lower limit of EQ-5D.  {opt llim()}
and {opt ulim()} must be provided together.

{phang}
{opt ulim(#)} specifies the user-supplied highest EQ-5D index value below 1.
Setting {it:#} to {cmd:1} fits a model without a gap, that is, a mixture of
tobit models.  {opt llim()} and {opt ulim()} must be provided together.

{phang}
{opt constraints(numlist)}; see {manhelp estimation_options##constraints() R:estimation options}.

{phang}
{opt vce(vcetype)} specifies how to estimate the variance-covariance matrix
corresponding to the parameter estimates.  The supported options are
{cmd:oim}, {cmd:opg}, {cmd:robust}, or {cmd:cluster} {it:clustvar}.  The
current version of the command does not allow {cmd:bootstrap} or
{cmd:jacknife} estimators; see {manhelpi vce_option R}.

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt inimethod(inimethod)} specifies the method for choosing starting values
for the parameters.  {it:inimethod} may be {opt single}, {cmd:cons}, or
{cmd:simann}.  The default is {cmd:inimethod(single)}, which lets {cmd:ml}
find starting values.  {opt cons} fits first a constant-only model and uses
those parameters as starting values in the estimation of the full model.
{cmd:simann} runs simulated annealing first to find appropriate starting
values.  Simulated annealing can be slow depending on the arguments used (see
{helpb simann:simann()}).  The default arguments for {cmd:simann()} can be
changed by using the {opt saopts(matrix)} option.

{phang}
{opt saopts(matrix)} specifies the name of the matrix with the following
{cmd:simann()} arguments:  {it:count}, {it:ftol}, {it:steps}, {it:cooling},
{it:start}, and {it:loglevel}.

{marker aldvmm_maximize}{...}
{phang}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{cmdab:no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient},
{opt showstep}, {opt hess:ian}, {opt showtol:erance}, {opt tol:erance(#)},
{opt ltol:erance(#)}, {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt nonrtol:erance}, and {opt from(init_specs)}; see 
{manhelp maximize R}.{p_end}

{phang}
{opt search(spec)} specifies whether to use {helpb ml}'s initial search
algorithm or not.  {it:spec} may be {opt on} or {opt off}.

{phang}
{opt repeat(#)} specifies the number of random attempts to be made to find a
better initial-value vector.  This option is used in conjunction with
{cmd:search(on)}.

{pstd}
The likelihood functions of mixture models have multiple optima.  The options
{opt inimethod(inimethod)}, {opt difficult}, {opt trace}, {opt search(spec)},
and {opt from(init_specs)} are especially useful when the default option does
not achieve convergence.


{title:Remarks}

{pstd}
The likelihood functions of mixture models are known to have multiple optima
({help aldvmm##references:McLachlan and Peel 2000}).  It is recommended that
multiple different starting values be used to ensure convergence to the global
maximum.

{pstd}
When a constant-probabilities model is estimated, the mixing probabilities are
shown in the output along with the parameters of the multinomial logit model.


{title:Examples}

{pstd}
Mixture of two components with constant probabilities using the UK
tariff{p_end}
{phang2}{cmd:. aldvmm eq5d haq pain female age, ncomponents(2)}{p_end}

{pstd}
Mixture of two components with constant probabilities using the U.S. tariff{p_end}
{phang2}{cmd:. aldvmm eq5d haq pain female age, ncomponents(2) country(US)}{p_end}

{pstd}
Mixture of three components using simulated annealing to generate a good
starting value{p_end}
{phang2}{cmd:. matrix samat = 2000, 1e-7, 80, 0.9, 100, 0}{p_end}
{phang2}{cmd:. aldvmm eq5d haq pain female age, ncomponents(3) inimethod(simann) saopt(samat)} {p_end}

{pstd}
Mixture of four components with probabilities of class membership depending on
{cmd:haq} and {cmd:pain}.  The command fits first a constant-only model and
uses the estimated intercepts and variances as starting points for the
estimation of the full model{p_end}
{phang2}{cmd:. aldvmm eq5d haq pain female age, ncomponents(4) probabilities(haq pain) inimethod(cons)}{p_end}

{pstd}
Mixture of two components with constant probabilities with given starting
values for the parameters{p_end}
{phang2}{cmd:. matrix x =(-0.06,-0.29,0.34,-0.24,-0.11,0.99,-2.3,-2,-2)}{p_end}
{phang2}{cmd:. aldvmm eq5d haq pain, ncomponents(2) from(x)}{p_end}


{title:Stored results}

{pstd}
In addition to standard results saved by maximum likelihood procedures in
{cmd:e()}, {cmd:aldvmm} saves the following scalars and macros in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(k_aux)}}number of components{p_end}
{synopt:{cmd:e(psi1)}}EQ-5D value closest to 1 (or 1 for a model without gap
at the top)  {p_end}
{synopt:{cmd:e(psi2)}}lower limit of the EQ-5D index{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(country)}}country for EQ-5D tariff{p_end}
{synopt:{cmd:e(cmd)}}{cmd:aldvmm}{p_end}
{synopt:{cmd:e(indepvars1)}}variables included in the components{p_end}
{synopt:{cmd:e(indepvars2)}}variables included in the probabilities{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}


{marker references}{...}
{title:References}

{p 4 8 2}Hern{c a'}ndez Alava, M., A. Wailoo, F. Wolfe, and K. Michaud.
2013. The relationship between EQ-5D, HAQ and pain in patients
with rheumatoid arthritis. {it:Rheumatology} 52: 944-950.

{p 4 8 2}McLachlan, G., and D. Peel. 2000. {it:Finite Mixture Models}. New
York: Wiley.


{title:Author}

{pstd}Monica Hern{c a'}ndez Alava{p_end}
{pstd}School of Health and Related Research{p_end}
{pstd}Health Economics and Decision Science{p_end}
{pstd}University of Sheffield{p_end}
{pstd}Sheffield, UK{p_end}
{pstd}monica.hernandez@sheffield.ac.uk{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 16, number 4: {browse "http://www.stata-journal.com/article.html?article=up0053":st0401_1},{break}
                    {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=st0401":st0401}{p_end}

{p 7 14 2}
Help:  {help aldvmm postestimation} (if installed){p_end}
