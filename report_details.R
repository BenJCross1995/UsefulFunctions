report_details <- function(report_location, details_location, save_location,
                           save_version = "N", comment = NULL){
  #' A function to generate information about a markdown file each time it is knit by the user.
  #' The function takes several locations provided in the arguments of the function and also
  #' parameters provided (not necessary) by the user which allow the user to save the file
  #' in a location as a back-up archived version as well as add a comment for the upload.
  #' The final two options are independent and will be ignored if the document is knit
  #' without using parameters.
  #' 
  #' @param report_location - The location of the original .Rmd document which will have the
  #' word count and copy files attributed.
  #' @param details_location - The location of the ready-made csv file for information from
  #' the .Rmd file.
  #' @param save_location - Location to save the archived files.
  #' @param - save_version - Whether to create an archived version or the .Rmd file, "Y" or "y"
  #' will create a new file, anything else wont. default set at N
  #' @param comment - Whether the user would like to enter a comment, if left blank then "No
  #'  Comment" will be returned.
  
  suppressPackageStartupMessages({
    require(dplyr)
    require(stringr)
  })
  
  # Pull user selected save option
  save_version <- params$save_version 
  # Check to see if comment entered, if not return No Comment
  version_comment <- ifelse(params$comment == "Enter Comment", "No Comment", params$comment)
  # Try to load the report info as a dataframe, if doesn't exist then create empty dataframe
  report_info <- try(as.data.frame(read.csv(details_location)),silent = TRUE)
  
  if(class(report_info) == "try-error"){ report_info <- data.frame() }
  
  # IF function to check for saved files and create a latest version for each day depending
  # on the users input for saving the document.
  if(save_version %in% c("y", "Y")){
    
    # Create a dataframe of all files in location, pull the date/version from the file name
    # and filter for current date and maximum version.
    files <- data.frame(file = list.files(save_location)) %>%
      mutate(dates = str_split_fixed(file, " - ", 3)[,2],   # Return the date
             version = gsub(".*V|[\\.].*","\\1", file)) %>% # Regex for everything between V and .
      filter(as.Date(dates, "%d-%m-%Y") == Sys.Date() &
               version == max(as.numeric(version)))
    
    # If there is at least one save for current date then add one to the max value otherwise
    # it is the first version.
    version <- ifelse(nrow(files) == 1,
                      files %>% pull(version) %>% as.numeric(),
                      0) + 1
    
    # Create the report name - obviously change to suit but keep standardised with the date as
    # as the second option.
    report_name <- paste0(
      "Report - ",
      format(Sys.Date(), "%d-%m-%Y"),
      " - V",
      version
    )
    
    # Add a value to show the file has been saved
    save_version <- "Saved"
    
    # Make a copy of the current file and save to location specified.
    file.copy(report_location,
              paste0(save_location,
                     report_name,
                     ".Rmd"))
  } else { 
    
    # If not saved then create some defaults.
    report_name <- "No Name"
    save_version <- "Not Saved"
  }
  
  # Create a dataframe of all the results - wordcountaddin is required here
  results <- data.frame(
    cbind("datetime" = format(Sys.time(), "%d/%m/%Y %H:%M:%S"),
          "wordcount" = wordcountaddin::word_count(report_location),
          "saved" = save_version,
          "report_name" = report_name,
          "comment" = version_comment))
  
  # Bind to the original table
  results <- rbind(report_info, results)
  
  # Write the new file, removing row names
  write.csv(results, details_location, row.names = FALSE)
  
}