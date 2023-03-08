#-------------------------------------------------------------------------------#
#-------------------------GET DATA FROM NOTION DATABASE-------------------------#
#-----------------------------------BEN CROSS-----------------------------------#
#-------------------------------------------------------------------------------#


get.notion.database.data <- function(notion.key, database_id, page_size = 100){
  #' This function retrieves all data from a Notion database, it performs an initial query and 
  #' checks whether there are more than the page_size values in the database. If there are more than
  #' page_size items then a while loop is executed which uses the next_cursor value as the start
  #' point for the next query until this value becomes NULL which is when the last items are recovered.
  #' There is a limit of 3 requests per send so i've set an iterator where if the loop is a multiple of 4
  #' then a 2 second rest is implemented.
  #' 
  #' @param notion.key - The users notion key
  #' @param database_id - The id of the notion database
  #' @param page_size - The amount of items to retrieve, set at 100 as default which is the max.
  #' 
  #' @return 
  
  require(tidyr)
  require(dplyr)
  require(httr)
  require(jsonlite)
  
  # Create the initial request body
  body <- list(page_size = 100)
  
  # The query
  ask <- VERB("POST",
              url = paste0("https://api.notion.com/v1/databases/", database_id, "/query"),
              body = body,
              add_headers("Authorization" = paste("Bearer", notion.key),
                          "Notion-Version" = "2022-06-28"),
              content_type("application/json"),
              accept("application/json"),
              encode = "json")
  
  # Convert the data to a table structure as well as other elements
  notion.data <- fromJSON(rawToChar(ask$content))
  
  # Pull the data and unnest all columns that need it, keeping empty rows for each column
  notion.database <- notion.data$results$properties %>%
    unnest(everything(), keep_empty = TRUE, names_sep = ".")
  
  # TRUE or FALSE if more data remaining than max downloaded
  has_more <- notion.data$has_more
  
  # If TRUE then this will be a character string, else will be NULL - signal to stop loop
  next_cursor <- notion.data$next_cursor
  
  # Time ran the query, important for loop
  iteration <- 1
  
  while (!is.null(next_cursor)) {
    
    # Increase iterator, has to be done at start of the loop.
    iteration <- iteration + 1
    
    # To prevent the query limits from being breached add in a 2 second pause every 3 loops
    if(iteration %% 4 == 0){
      Sys.sleep(2)
    }
    
    # Update the body for the new starting point
    body <- list(start_cursor = next_cursor, page_size = 100)
    
    ask <- VERB("POST",
                url = paste0("https://api.notion.com/v1/databases/", database_id, "/query"),
                body = body,
                add_headers("Authorization" = paste("Bearer", notion.key),
                            "Notion-Version" = "2022-06-28"),
                content_type("application/json"),
                accept("application/json"),
                encode = "json")
    
    notion.data <- fromJSON(rawToChar(ask$content))
    
    new.notion <- notion.data$results$properties %>%
      unnest(everything(), keep_empty = TRUE, names_sep = ".")
    
    # Append the new data to the old data
    notion.database <- rbind(notion.database,new.notion)
    
    # Retrieve new values
    has_more <- notion.data$has_more
    
    next_cursor <- notion.data$next_cursor
    
  }
  
  return(notion.database)
  
}
