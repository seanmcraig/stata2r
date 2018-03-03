# stata2r - Translate Stata to R
This R package contains functions for translating Stata instructions into executable R code as painlessly as possible. The main function is `stata2r()`, which allows the user to execute individual stata instructions.

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
`use` | Loading full `.dta` is currently supported (e.g., `use "data.dta"`). Loading subsets of data is not supported (e.g., `use x y using "data.dta"`). Loading Stata variable labels is not supported; the command functions as if theuser specifies the `nolabel` Stata option.
