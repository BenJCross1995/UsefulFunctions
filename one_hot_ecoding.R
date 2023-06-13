one_hot_encoding <- function(dataset, vars_to_onehot = names(dataset)){
  #' This function takes a dataframe and a vector of columns (which is defaulted
  #' as all columns in the dataset), and uses carets dummyVars to one-hot encode
  #' the data. I have put it as a function to not store the intermediate variables.
  #' It also combines any columns which are not required to encode back with the 
  #' new encoded values.
  #' 
  #' @param dataset A dataset given by the user.
  #' @param vars_to_onehot A vector of varaibles, defaulted as the dataframes name.
  #' 
  #' @return A dataframe containing all variables not encoded and also encoded vars.
  
  suppressPackageStartupMessages(require(caret))
  
  data_to_onehot <- dataset %>% select(all_of(vars_to_onehot))
  
  dummy <- dummyVars(~., data = data_to_onehot,
                     drop2nd = FALSE, sep = '.')
  
  new_dummy <- data.frame(predict(dummy,
                                  newdata = data_to_onehot))
  
  final_data <- cbind(dataset %>% select(-all_of(vars_to_onehot)), new_dummy)
  
  return(final_data)
}
