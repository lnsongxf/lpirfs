# Submission notes

## Purpose
* Included the option to set the lag length of the endogenous variable in *lp_lin_iv* and *lp_nl_iv* to 0.
  This excludes the endogenous variable as an explanatory one.
* Deleted the deprecated plot functions *plot_lin_irfs* and *plot_nl_irfs*.
* Improved documentation.
* Input names in `lp_lin_iv()` and `lp_nl_iv()` have been changed for consistency:

function | old input name | new input name
:--------|:-------------  |:------------- 
`lp_lin_iv()` | `instr`     | `shock`
`lp_nl_iv()`  | `instr`     | `shock`


## Test environments
* local x86_64-pc-linux-gnu (64-bit), R version 3.5.1
* ubuntu 14.04.5 (on travis-ci),      R version 3.4.4, R-oldrel, R-devel.
* win-builder (devel and release) 
* rhub (for Oracle Solaris)

## Check results
0 errors ✔ | 0 warnings ✔ | 0 notes ✔

## Downstream dependencies
No errors, warnings, or notes were caused in other packages. I used `devtools::revdep_check()` to confirm. 
