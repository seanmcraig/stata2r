#' Translate Stata to R
#'
#' This function translates common Stata instructions into R and executes the resulting code. Stata instructions are recorded as a string, which are broken down and interpreted.
#' @param code Enter code as you would in Stata, surrounded by single quotes.
#' @keywords stata
#' @export
#' @examples
#' stata2r('pwd')
#' 
stata2r <- function(
  code
){
  #Load packages
  library(stringr)
  
  # Define global objects
  vstring <- strsplit(code, " ")
  vstring_df <- data.frame(vstring)
  colnames(vstring_df)[1] <- "v1"
  cmd <- vstring_df$v1[1]
  
  # "cd" Change Directory
  if(cmd == "cd"){
    loc_end <- NROW(vstring_df)
    path <- paste(vstring_df$v1[2:loc_end], collapse=" ")
    setwd(gsub('"',"",path))
    out <- getwd()
    print(noquote(out))
    rm(loc_end, path, out)
  }

  # "pwd" Print Working Directing
  if(cmd == "pwd"){
    out <- getwd()
    print(noquote(out))
    rm(out)
  }
  
  # Remove global objects
  rm(vstring, vstring_df, cmd)
}