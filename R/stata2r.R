#' Translate Stata to R
#'
#' This function translates common Stata instructions into R and executes the resulting code. Stata instructions are recorded as a string, which are broken down and interpreted.
#' @param code Enter code as you would in Stata, surrounded by single quotes.
#' @keywords stata
#' @import stringr haven
#' @export
#' @examples
#' stata2r('pwd')

stata2r <- function(
  code
){
  #Load packages
  library(stringr)
  #Remove all quotation marks from the code string
  code1 <- gsub('"',"",code)
  code2 <- gsub("([A-Za-z]),([A-Za-z])", "\\1 , \\2", code1)
  code3 <- gsub("([A-Za-z]),", "\\1 ,", code2)
  code4 <- gsub(",([A-Za-z])", ", \\1", code3)
  code <- code4
  rm(code1,code2,code3,code4)
  # Define general objects
  vstring <- strsplit(code, " ")
  vstring_df <- data.frame(vstring)
  colnames(vstring_df)[1] <- "v1"
  cmd <- as.character(vstring_df$v1[1])
  loc_comma = which(vstring_df$v1==",")
  loc_end = NROW(vstring_df)
  # "cd" Change Directory
  if(cmd == "cd"){
    path <- paste(vstring_df$v1[2:loc_end], collapse=" ")
    setwd(path)
    verb <- paste("setwd(",path,")")
    print(noquote(verb))
    rm(path, verb)
  }
  # "clear" Clear data
  if(cmd == "clear"){
    if(exists("mydata", envir = .GlobalEnv)){rm(mydata, envir = .GlobalEnv)}
    else(return())
  }
  # "pwd" Print Working Directing
  if(cmd == "pwd"){
    verb <- "getwd()"
    out <- getwd()
    print(noquote(verb))
    print(noquote(out))
    rm(out, verb)
  }
  # "use" Load Stata Dataset
  if(cmd == "use"){
    library(haven)
    loc_using <- which(vstring_df$v1=="using")
    if(length(loc_using)>0){print('Subsetting with "use" not supported at this time.')}
    else{
      loc_stop <- ifelse(length(loc_comma>0),loc_comma-1,loc_end)
      path <- paste(vstring_df$v1[2:loc_stop],collapse=" ")
      mydata <<- haven::read_dta(path)
      verb1 <- "library(haven)"
      verb2 <- paste('read_dta("',path,'")',sep="")
      print(noquote(verb1))
      print(noquote(verb2))
      rm(path,verb1, verb2,loc_stop,loc_using)
    }
  }
  # Remove general objects
  rm(vstring, vstring_df, cmd, code, loc_comma, loc_end)
} 

