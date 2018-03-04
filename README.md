stata2r
======
This R package contains functions for translating Stata instructions into executable R code as painlessly as possible. The main function is `stata2r()`, which allows the user to execute individual stata instructions.

## Who Should Use stata2r?
* Users who want to use common Stata functions but lack a current license.
* Primary R users who prefer Stata syntax for certain common functions (e.g. data manipulation, or OLS regression).
* Primary Stata users who would like to learn R gradually while maintaining a familiar workflow.
* Primary Stata users who need to collaborate with R users.

## Usage
The main function, `stata2r()`, allows the user to a line of Stata code as a string (in single quotes). The package will parse the string, identify corresponding R functions, and output both the translated code and its result. For example,
~~~~
stata2r('use "data.dta", clear')
~~~~
outputs
~~~~
mydata <- read_dta("data.dta")
~~~~

As Stata only permits one active data source, whereas R permits many active data frames, stata2r executes all data-related functions with reference to a data frame called `mydata`. If you have data loaded in R and you want stata2r to be able to see it, you need to assign your data frame to `mydata`.

~~~~
mydata <- your.data.frame
~~~~

## Dependencies
Package | Notes
--- | ---
`haven` | `read_dta` function is needed for reading Stata-formatted data files with `use`.

## Current functionality
#### stata2r is compatible with the following Stata commands:

Command | Description/Notes
--- | ---
`cd`| Change working directory.
`clear`| Clear data from memory.
`pwd`| Print working directory.

#### stata2r is partially compatible with the following Stata commands:
Command | Description/Notes
--- | ---
`use` | Loading full `.dta` is currently supported (e.g., `use "data.dta"`). Loading subsets of data is not supported (e.g., `use x y using "data.dta"`). Loading Stata variable labels is not supported; the command functions as if the user specifies the `nolabel` option in Stata.
