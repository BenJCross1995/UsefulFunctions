references.from.markdown <- function(file.location, include.sections = FALSE){
  #' This function takes a filepath as a parameter, scans the file and returns
  #' the references in the form of their BibTex label as a dataframe. This can be
  #' used to compare against references in a raference manager such as Zotero. The
  #' user can also specify to include the main and subsection in the report where
  #' the reference was found.
  #' @param file.location - The location string of the file to scan.
  #' @param include.sections - A logical value TRUE or FALSE indicating whether
  #' to include the sections in the report where the reference occurs.
  #' @return
  
  if(include.sections == FALSE){
    
    # This code returns a one-column dataframe containing the unique reference BibTex values in alphabetical order.
    
    data.frame(reference  = readLines(file.location)) %>%            # Scan the document from location
      mutate(reference = str_extract(reference,
                                     "(?<=\\[@)(.*?)(?=\\])")) %>%   # From each row extract anything in between '[@ ]'
      filter(!is.na(reference)) %>%                                  # Remove any empty rows
      unique() %>%
      arrange(reference) %>%
      return()
  } else {
    
    # This code returns a dataframe containing the references used and the sections the references are used in. This means
    # duplicate reference labels will occur if you use a reference in multiple locations.
    
    data.frame(references.data  = readLines(file.location)) %>%             # Scan the document from location
      filter(!references.data == "") %>%                                    # Remove blank rows (line breaks)                    
      mutate(reference = str_extract(references.data,
                                     "(?<=\\[@)(.*?)(?=\\])"),
             code = str_detect(references.data, "```"),
             codeviewed = cumsum(str_detect(references.data,
                                            "```"))) %>%                    # Extract references and detect start and end of code chunks
      group_by(codeviewed) %>%                                              # Group by the amount of times ``` is seen as odd numbers indicate a code chunk
      mutate(codeseen = row_number()) %>%                                   # Return the row number after each ``` as first row of even codeviewed is code chunk too
      ungroup() %>%
      filter(!(codeviewed %% 2 == 1 | codeseen ==1)) %>%                    # filter out any code chunks with above logic
      mutate(section.type = str_count(references.data, "#"),
             main.section = ifelse(section.type == 1,
                                   str_extract(references.data,
                                               "(?<=# ).*$"), NA),
             sub.section = ifelse(section.type %in% c(1, 2),
                                  str_extract(references.data,
                                              "(?<=# ).*$"), NA)) %>%       # Return section headers
      fill(main.section, sub.section, .direction = "down") %>%              # Fill down to remove the NA values
      select(main.section, sub.section, reference) %>%
      filter(!is.na(reference)) %>%                                         # Only keep rows with references.
      as.data.frame() %>%
      return()
  }
}
