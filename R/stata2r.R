#' Translate Stata to R
#'
#' This function translates common Stata instructions into R and executes the resulting code. Stata instructions are recorded as a string, which are broken down and interpreted.
#' @param input Enter code as you would in Stata, surrounded by single quotes.
#' @keywords stata
#' @import stringr haven
#' @export
#' @examples
#' s2r('replace x=5 if y==3')

s2r <- function(input){
  
  # (1) FORMATTING THE INPUT STRING
  
  # Load general packages
  library(stringr)
  
  # Strip internal quotation marks from the input string
  mod_1 <- gsub('"',"",input)
  
  # Ensure that commas are padded on both sides with " "
  mod_2 <- gsub("([A-Za-z]),([A-Za-z])", "\\1 , \\2", mod_1)
  mod_3 <- gsub("([A-Za-z]),", "\\1 ,", mod_2)
  mod_4 <- gsub(",([A-Za-z])", ", \\1", mod_3)
  
  
  # Define the final code string and clean up local variables
  cstring <- mod_4
  
  # Split the code string into a vector
  cvector <- data.frame(strsplit(cstring, " "))
  colnames(cvector)[1] <- "v1"
  
  # Identify the command
  if(cvector$v1[1]=="by"){ 
    return(print('ERROR: "by" is not supported at this time')) 
  } else if (cvector$v1[1]=="bysort"){ 
    return(print('ERROR: "bysort" is not supported at this time')) 
  } else {
    cmd <- as.character(cvector$v1[1])
  }
  
  # Identify important locations
  loc_comma <- which(cvector$v1==",")
  loc_end = NROW(cvector)
  
  # (2) COMMAND DICTIONARY
  
  # "cd"
  if(cmd == "cd"){
    path <- paste(cvector$v1[2:loc_end], collapse=" ")
    setwd(path)
    verb <- paste('setwd("',path,'")')
    print(noquote(verb))
  }
  
  # "generate"
  if(is.element(cmd, c("generate","generat","genera","gener","gene","gen","ge","g"))==TRUE){
    str <- "str"
    set <- c(1:2045)
    strset <- paste0(str,set)
    type <- ifelse(
      is.element(
        cvector$v1[2], c("byte","int","long","float","double","str", strset)
        )==TRUE, cvector$v1[2], "none")
    loc_newvar <- ifelse(type=="none", 2, 3)
    
    # "if" and "in" are currently unsupported
    loc_if <- which(cvector$v1=="if")
    loc_in <- which(cvector$v1=="in")
    if(length(loc_if)>0){return(noquote('ERROR: "if" is unsupported at this time'))}
    if(length(loc_in)>0){return(noquote('ERROR: "in" is unsupported at this time'))}
    
    # Identify the end of the expression
    loc_stop <- ifelse(length(loc_comma)>0, loc_comma-1, loc_end)
    expression <- gsub("=","<-",paste0(na.omit(cvector$v1[loc_newvar:loc_stop]),collapse=""))
    
    # Generate the variable
    if(exists('mydata', envir=.GlobalEnv)==FALSE){newframe <-1} else{newframe <- 0}
    if(newframe==1){mydata <<- data.frame(0)}
    if(type=="none"){verb <- paste0("mydata$",expression)}
    
    if(type!="none"){return(print("ERROR: Specifying data type is not yet supported"))}
    
    # Evaluate the command and produce the output
    eval(parse(text=verb), envir=.GlobalEnv)
    if(newframe==1){mydata$X0 <<- NULL}
    print(noquote(verb))
  }
  
  # "clear"
  if(cmd == "clear"){
    if(exists("mydata", envir = .GlobalEnv)){
      rm(mydata, envir = .GlobalEnv)
    } else(return())
  }
  
  # "pwd"
  if(cmd == "pwd"){
    verb <- "getwd()"
    out <- getwd()
    print(noquote(verb))
    print(noquote(out)) 
  }
  
  # "replace"
  if(cmd == "replace"){
    if(exists("mydata")==FALSE){return(noquote("ERROR: stata2r compatible data is not loaded"))}
    
    # Find the end of the replace, in, and if expressions
    loc_if <- which(cvector$v1=="if")
    loc_in <- which(cvector$v1=="in")
    
    if(length(loc_if)>0 & length(loc_in)>0){
      if(loc_if-loc_in<0){
        loc_stop <- loc_if-1
        loc_ifstop <- loc_in-1
        loc_instop <- ifelse(length(loc_comma)>0, loc_comma-1, loc_end)
      } else {
        loc_stop <- loc_in-1
        loc_instop <- loc_if-1
        loc_ifstop <- ifelse(length(loc_comma)>0, loc_comma-1, loc_end)
      }
    } else if (length(loc_if)>0 & length(loc_in)<1) {
      loc_stop <- loc_if-1
      loc_ifstop <- ifelse(length(loc_comma)>0, loc_comma-1, loc_end)
    } else if (length(loc_if)<1 & length(loc_in)>0) {
      loc_stop <- loc_in-1
      loc_instop <- ifelse(length(loc_comma)>0, loc_comma-1, loc_end)
    } else if (length(loc_comma)>0) {
      loc_stop <- loc_comma-1
    } else {
      loc_stop <- loc_end
    }
    
    # Define the expressions and correct their syntax
    expression <- gsub("=","<-", paste0(cvector$v1[2:loc_stop], collapse=""))
    expression_2 <- sub("^[^<]*","",expression)
    
    
    if(length(loc_if)>0){
      ifrowid <- paste0(loc_if+1,":",loc_ifstop,collapse="")
      ifverb <- paste0("cvector$v1[",ifrowid,"]", collapse="")
      if_exp <- eval(parse(text=ifverb))
    }
    if(length(loc_in)>0){
      inrowid <- paste0(loc_in+1,":",loc_instop,collapse="")
      inverb <- paste0("cvector$v1[",inrowid,"]", collapse="")
      in_exp <- eval(parse(text=inverb))
      in_exp <- gsub("f","1",in_exp)
      in_exp <- gsub("l",NROW(mydata),in_exp)
      in_exp <- gsub("[^0-9]/[^0-9]","\\1,\\2",in_exp)
    }
    if(exists("if_exp")==FALSE){if_exp <- ""}
    if(exists("in_exp")==FALSE){in_exp <- ""}
    
    # Determine the correct command, execute, and return output
    oldvar <- sub("*=.","", cvector$v1[2])
    ifvar <- gsub("=.*","",if_exp)
    ifvar <- gsub("<.*","",ifvar)
    ifvar <- gsub(">.*","",ifvar)
    if(length(loc_if)>0 && length(loc_in)>0){
      in_exp_mod <- sub("([0-9]):([0-9])","c(\\1:\\2)",in_exp)
      if_exp_mod <- if(grepl("<",if_exp)==TRUE){sub("^[^<]*","",if_exp)} else{if_exp_mod <- if_exp}
      if_exp_mod <- if(grepl(">",if_exp)==TRUE){sub("^[^>]*","",if_exp)} else{if_exp_mod <- if_exp_mod}
      if_exp_mod <- if(grepl("=",if_exp)==TRUE 
                       && grepl(">",if_exp)==FALSE 
                             && grepl("<",if_exp)==FALSE){sub("^[^=]*","",if_exp)
                               } else{if_exp_mod <- if_exp_mod}
        
      if_test<- paste0("which(mydata$",if_exp,")", collapse="")
      if_satisfied <- paste0(eval(parse(text=if_test)),sep=",",collapse="")
      if_satisfied <- paste0(substr(if_satisfied,1,nchar(if_satisfied)-1), collapse="")
      if_satisfied2 <- paste0("c(",if_satisfied,")")
      if_set <- eval(parse(text=if_satisfied2))
      ifin_test <- paste0("which(is.element(",if_satisfied2,",",in_exp_mod,")==TRUE)", collapse="")
      ifin_satisfied <- eval(parse(text=ifin_test))
      rowid_test <- paste0(if_satisfied2,"[",ifin_satisfied,"]")
      rowid <- eval(parse(text=rowid_test))
      
      #Error escape
      if(length(rowid)<1){return("Request produced no real changes")}
        
      verb <- paste0("mydata$",oldvar,"[",rowid,"]", expression_2, collapse="")
    } else if(length(loc_if)>0 && length(loc_in)<1){
      verb <- paste0("mydata$",oldvar,"[mydata$",if_exp,"]", expression_2, collapse="")
    } else if(length(loc_if)<1 && length(loc_in)>0){
      verb <- paste0("mydata$",oldvar,"[",in_exp,"]",expression_2, collapse="")
    } else {
      verb <- paste0("mydata$",expression, collapse="")
    }
    eval(parse(text=verb), envir=.GlobalEnv)
    print(noquote(verb))
  }
  
  # "use"
  if(is.element(cmd, c("use","us","u"))){
    library(haven)
    loc_using <- which(cvector$v1=="using")
    if(length(loc_using)>0){return(print('Subsetting with "use" not supported at this time.'))}
    else{
      loc_stop <- ifelse(length(loc_comma>0),loc_comma-1,loc_end)
      path <- paste(cvector$v1[2:loc_stop],collapse=" ")
      mydata <<- haven::read_dta(path)
      verb1 <- "library(haven)"
      verb2 <- paste('read_dta("',path,'")',sep="")
      print(noquote(verb1))
      print(noquote(verb2))
    }
  }
  # Remove general objects
} 
