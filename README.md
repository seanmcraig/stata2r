# stata2r

## Summary
*stata2r* is an R package that allows users to translate Stata instructions into executable R code on the fly.

## Overview
*stata2r* in an add-on package for R. It contains functions for parsing strings of Stata code and executing equivalent instructions in R. The main function, `s2r()`, allows the user to execute commmon Stata command-line instructions. The package serves two main groups of users:

1. Primary R users who prefer Stata syntax for simple tasks.
2. New R users who want a safety net / educational tool.

To better serve the first group, the package aims for robust support of Stata's data manipulation functions and basic regression models. To aid the second group, all functions return the code translation in addition to normal output.

## Installation
You can install *stata2r* from an R console via the [devtools](https://github.com/hadley/devtools) package.
~~~~
install.packages("devtools")
library(devtools)
install_github("seanmcraig/stata2r")
~~~~

## Dependencies
*stata2r* requires the `haven` package, specifically its `read_dta()` function, in order to read Stata-formatted data files.

## Basic Use
The main function, `s2r()`, translates a single line of Stata code. Users input stata code as a string in single quotes (`''`). The function will parse the string, identify the corresponding R code, and return the translated code as well as any output. For example, to load a Stata-formatted data file, the user might input the following:
~~~~
s2r('use "data.dta", clear')
~~~~
*stata2r* will return:
~~~~
mydata <- read_dta("data.dta")
~~~~

As Stata only permits one active data set, Stata syntax does not permit the user interact with a particular R data frame. The workaround is to use one, pre-defined data frame for all Stata instructions. Thus, in *stata2r* all data-related functions use a data frame called `mydata`. If you already have data loaded in R and you want *stata2r* to be able to use it, you need to assign your data frame to `mydata`.
~~~~
mydata <- otherdata
~~~~

Please note that *stata2r* assumes that user input is valid Stata code. Invalid code may produce opaque error messages referencing local variables temporarily created by the package functions. If you receive an error, a good first step is to make sure your Stata input contains no errors.

A list of Stata commands that work with *stata2r* appears at the bottom of this README.


## Supported Stata Commands
The following Stata commands are at least partially supported:

Command | Notes
--- | ---
`cd` | Fully supported.
`generate` | Partially supported: "if" and "in" arguments are not supported; missing values are not supported.
`clear` | Fully supported.
`pwd` | Fully supported.
`replace` | Mostly supported: option "nopromote" is not supported.
`use` | Partially supported: loading subsets not supported; loading Stata value labels is not supported (command functions as if `nolabel` option was used)

## Package Author
Sean Craig ([sean.craig@pitt.edu](mailto:sean.craig@pitt.edu))

## License
[GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.txt) (GNU General Public License, Version 3)



