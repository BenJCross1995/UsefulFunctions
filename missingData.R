missing.data <- function(dataset){
  #' This function takes a dataset and returns the % of values missing in each
  #' column of the dataset where there is some data missing. Any columns that
  #' do not contain missing data are ignored. The returned dataset is arranged
  #' so that the Variables are in descending order of percent missing.
  #' 
  #' @param dataset The dataset we wish to find the percentage of missing values for.
  #' 
  #' @return A dataset containing a Variable column and a PercentMissing column.
  
  suppressPackageStartupMessages({
    require(dplyr)
    require(tibble)
  })
  missing <- data.frame( PercentMissing = round(colMeans(is.na(dataset))*100,2))  %>%
    filter( PercentMissing > 0 )
  missing <- rownames_to_column(missing, "Variable") %>%
    arrange(desc(PercentMissing))
  return(missing)
}
