{smcl}
{* documented: September 2016}{...}
{cmd:help aldvmm postestimation}{right: ({browse "http://www.stata-journal.com/article.html?article=up0053":SJ16-4: st0401_1})}
{hline}

{title:Title}

{p2colset 5 30 32 2}{...}
{p2col:{hi:aldvmm postestimation} {hline 2}}Postestimation tools for
aldvmm{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following postestimation commands are of special interest after
{cmd:aldvmm}:

{synoptset 15}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{p2coldent :{helpb estat}}postestimation statistics{p_end}
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
{synopt:{helpb aldvmm_postestimation##margins:margins}}marginal
	means, predictive margins, marginal effects, and average marginal
	effects{p_end}
INCLUDE help post_marginsplot
INCLUDE help post_nlcom
INCLUDE help post_test
INCLUDE help post_testnl
{synopt :{helpb aldvmm postestimation##predict:predict}}predictions including component 
means and probabilities{p_end}
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 14 2}
{cmd:predict} {it:newvar} {ifin} [{cmd:,} {opt out:come(outcome)}]

{p 8 14 2}
{cmd:predict} {dtype} {it:stub}{cmd:*}{c |}{it:newvar1} ...{it:newvarq}{c )-}
{ifin}{cmd:,} {opt sc:ores}


{title:Options for predict}

{phang}
{opt outcome(outcome)} specifies the predictions to be stored.
{it:outcome} can be {opt y} or {opt all} or one of {cmd:#1}, {cmd:#2}, etc.
The default, {cmd:outcome(y)}, stores only the dependent variable prediction
in {it:newvar}.  Use {opt all} to additionally obtain the predicted means and
probabilities for each component in the mixture.  These are stored as
{it:newvar}{cmd:_y1}, {it:newvar}{cmd:_y2},... and {it:newvar}{opt _p1},
{it:newvar}{cmd:_p2}, ..., respectively.  {cmd:outcome(#}{it:c}{cmd:)}
stores in {it:newvar} the prediction for class {it:c}.

{phang}
{opt scores} calculates equation-level score variables.


{marker margins}{...}
{title:Syntax for margins}

{p 8 14 2}
{cmd:predict} {it:newvar} {ifin} [{cmd:,} {opt out:come(outcome)}]


{title:Option for margins}

{phang}
{opt outcome(outcome)} specifies the predictions to be stored.
{it:outcome} can be {opt y} or one of {cmd:#1}, {cmd:#2}, etc.
The default, {cmd:outcome(y)}, stores only the dependent variable prediction
in {it:newvar}.  This is stored as {it:newvar}{cmd:_y1}, {it:newvar}{cmd:_y2},
....  {cmd:outcome(#}{it:c}{cmd:)} stores in {it:newvar} the prediction for
class {it:c}.


{title:Examples}

{pstd}
Predicting EQ-5D and storing it in the variable {opt Ey} after estimating a
mixture of two components{p_end}
{phang2}{cmd:. aldvmm eq5d haq pain female age, ncomponents(2)}{p_end}
{phang2}{cmd:. predict Ey}{p_end}

{pstd}
Predicting EQ-5D and the means and probabilities of each component; EQ-5D
will be stored in {opt Ey}, the means of each component will be stored in
{cmd:Ey_y1} and {opt Ey_y2}, and the probabilities in {cmd:Ey_p1} and
{cmd:Ey_p2}{p_end}
{phang2}{cmd:. predict Ey, outcome(all)}{p_end}


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
Help:  {helpb aldvmm} (if installed){p_end}
