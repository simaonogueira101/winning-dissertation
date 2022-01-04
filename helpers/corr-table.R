corstarsl <- function(x, labels){ 
  require(Hmisc) 
  x <- as.matrix(x)
  colnames(x) <- labels
  
  R <- rcorr(x)$r 
  p <- rcorr(x)$P
  
  ## define notions for significance levels; spacing is important.
  mystars <- ifelse(p < .01, "***", ifelse(p < .05, "** ", ifelse(p < .1, "* ", " ")))
  
  ## truncate the matrix that holds the correlations to three decimal
  R <- format(round(cbind(rep(-1.11, ncol(x)), R), 3))[,-1] 
  
  ## build a new matrix that includes the correlations with their appropriate stars 
  Rnew <- matrix(paste(R, mystars, sep=""), ncol=ncol(x)) 
  diag(Rnew) <- paste(diag(R), " ", sep="") 
  rownames(Rnew) <- colnames(x) 
  colnames(Rnew) <- paste(colnames(x), "", sep="") 
  
  ## remove upper triangle
  Rnew <- as.matrix(Rnew)
  Rnew[upper.tri(Rnew, diag = FALSE)] <- ""
  Rnew <- as.data.frame(Rnew) 

  return(Rnew) 
}