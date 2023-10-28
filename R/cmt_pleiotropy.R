#' cmt_pleiotropy
#'
#' This function calculates Complete Mediation Test.
#'
#' @param outcome Outcome variable.
#' @param exposure Exposure variable.
#' @param G List of SNPs.
#' @param data Data frame.
#' @param Bootstrap_times Number of bootstrap times.The default is 50.
#' @param prop Proportion threshold.The default is 0.8.
#' @return List of results.
#'
#' @examples
#' cmt_pleiotropy("outcome", "exposure", c("snp1", "snp2"), mydata)
#' cmt_pleiotropy( outcome="outcome",
#'               exposure="exposure",
#'               G=c("snp1", "snp2", "snp3"),
#'               data=data1,
#'               Bootstrap_times = 100, prop = 0.9)
#' @note The function automatically handles missing values by omitting rows with missing data.


cmt_pleiotropy <- function(outcome,exposure,G,data, Bootstrap_times = 50, prop = 0.8) {
  # Load required libraries
  if (!require("bda")) {
    install.packages("bda")
    library("bda")
  }
  if (!require("multilevel")) {
    install.packages("multilevel")
    library("multilevel")
  }
  if (!require("dplyr")) {
    install.packages("dplyr")
    library("dplyr")
  }
  
  #Check for Column Existence
  if (!all(c(outcome, exposure) %in% colnames(data))) {
    stop("Specified outcome or exposure variable not found in the dataset.")
  }
  
  missing_snps <- G[!G %in% colnames(data)]
  if (length(missing_snps) > 0) {
    stop("The following SNPs are not found in the dataset: ", paste(missing_snps, collapse = ", "))
  }
 # data cleaning  
  data=na.omit(as.data.frame(data)) 
 # sobel test   
  I_Effect <- NULL
  YonG <- NULL
  sob_pvalue <- NULL
  
  for (i in G) {
    sob1 <- sobel(data[, i], data[, exposure], data[, outcome])
    I_Effect[i] <- sob1$Indirect.Effect
    YonG[i] <- sob1$`Mod1: Y~X`[2]
    sob2 <-
      mediation.test(data[, exposure], data[, i], data[, outcome])
    sob_pvalue[i] <- sob2$Sobel[2]
  }
  # Create a matrix for bootstrap results  
  Effect_new <- matrix(NA, Bootstrap_times, length(G))
  
  for (intj in 1:Bootstrap_times) {
    data_d <- data[sample(1:nrow(data), nrow(data), replace = TRUE),]
    
    for (inti in G) {
      Model_YonG <-
        summary(lm(paste0(outcome, "~", sep = "."), data_d[, c(outcome, inti)]))
      Model_XonG <-
        summary(lm(paste0(exposure, "~", sep = "."), data_d[, c(exposure, inti)]))
      Model_YonGX <-
        summary(lm(paste0(outcome, "~", sep = "."), data_d[, c(exposure, inti, outcome)]))
      Effect_new[intj, match(inti, G)] <-
        Model_YonGX$coefficients[2] * Model_XonG$coefficients[2] - Model_YonG$coefficients[2]
    }
  }
  
  se <- function(x)
    sqrt(var(x))
  
  EffectNEW_se <- NULL
  zvalue <- NULL
  Pval <- NULL
  Significant <- NULL
  # Calculate z-values and p-values
  for (jj in seq_along(G)) {
    EffectNEW_se[jj] <- se(Effect_new[, jj])
    zvalue[jj] <- (I_Effect[jj] - YonG[jj]) / se(Effect_new[, jj])
    
    if (zvalue[jj] < 0) {
      Pval[jj] <-
        2 * pnorm(
          q = c(zvalue[jj]),
          mean = 0,
          sd = 1,
          lower.tail = TRUE
        )
    } else {
      Pval[jj] <-
        2 * pnorm(
          q = c(zvalue[jj]),
          mean = 0,
          sd = 1,
          lower.tail = FALSE
        )
    }
    
    Significant[jj] <-
      ifelse((Pval[jj] < 0.05 / length(G) &
                abs(I_Effect[jj] / YonG[jj]) < prop), "*", ".")
  }
  
  
  CMT_pvalue <- data.frame(
    #SNP = G,
    prop.med = round(abs(I_Effect / YonG), 5),
    Statistics = round(zvalue, 4),
    P_Value = round(Pval, 5),
    Signif = Significant
  )
  
  result_list <- list(
    Outcome = outcome,
    Exposure = exposure,
    N = nrow(data),
    SNPs = G,
    CMT_value = CMT_pvalue,
    Signif.level = 0.05 / length(G),
    Note=c("* indicating pleiotropy",
           "prop.med means the proportion of the effect that is mediated.(£\£]/C)",
           "The function automatically handles missing values by omitting rows with missing data."),
    proportion.threshold = prop
  )
  return(result_list)
  
}

