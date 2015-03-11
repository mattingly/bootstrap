###
###Block bootstrapping of clustered data
###Dan Mattingly
###March 2015
###1.0
###



block.boot <- function(formula, data = list(), block, reps, ci=0.95, time=TRUE){
  mf <- model.frame(formula=(formula), data=data)
  data <- cbind(mf, block)
  
  #Resampling function
  block.sample <- function(data, block){
    #Create a new sample by sampling blocks with replacement
    new.sample=do.call("rbind", lapply(sort(sample(unique(block), replace=T)), function(n) subset(data, block==unique(block)[n])))
    #Calculate coefficient for the model and return them
    coeff <- c(coefficients(lm(formula, data=new.sample)))
    return(coeff)
  }
  
  #Function prints an (optional) estimated time message
  if(time==TRUE){
    time.estimate <- system.time(replicate(10, block.sample(data, block)))
    writeLines(paste("Estimated bootstrap time:", round(as.numeric((reps*time.estimate[3])/10)/60, digits=2), "minutes"))}
    
  #Bootstrap, creating a matrix of estimated coefficients
  boot_coef <- replicate(reps, block.sample(data, data$block))
  
  #Warning if some coefficients could not be estimated 
  if(sum(is.na(boot_coef))>0){print("Warning! Some coefficients cannot be computed!")
  }
  
  ##Calculate empirical p-values, point estimates, and confidence intervals 
  pval.randx <- apply(boot_coef, 1, function(x) sum(x<0, na.rm=TRUE)/(ncol(boot_coef)))
  
  #Create confidence interval function
  ci.fun <- function(x){
    quantile(x, probs=c((1-ci)/2, 1-(1-ci)/2), na.rm=TRUE)
  }
  boot.coef=t(boot_coef)
  
  #Calculate confidence interval from empirical distribution
  ci.randx <- t(apply(boot.coef, 2, ci.fun))
  
  #Calculate point estimate from empirical distribution
  pe.randx <- as.matrix(apply(boot.coef, 2, function(x) mean(x, na.rm=TRUE)))
  
  #Calculate standard error from empirical distribution
  std.err <- as.matrix(apply(boot.coef, 2, function(x) sd(x)/sqrt(nrow(x))))
  
  #Place output in a table for display and manipulation
  estimates <- data.frame(cbind(pe.randx, std.err, ci.randx, pval.randx))
  colnames(estimates) <- c("Estimate", "StandardError", "LowerBound", "UpperBound", "p.value")
  estimates$p.value[which(estimates$Estimate<0)] <- 1-estimates$p.value[which(estimates$Estimate<0)]
  estimates$p.value <- estimates$p.value*2
  return(estimates)
}



