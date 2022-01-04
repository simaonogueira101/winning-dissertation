accelerators_F6S_source <- read_excel("./data-original/ancient/data_F6S EXCEL.xlsx")

# Create matched name column
accelerators_F6S_source <- accelerators_F6S_source %>%
  mutate(
    accelerator_name_match = NA,
    .after = program_name
  )

accelerator_F6S_index <- 1

# Add matched name to dataframe
for (accelerator_F6S in accelerators_F6S_source$program_name) {
  for (accelerator_Crunchbase in accelerators$name) {
    if(!is.na(accelerator_F6S) & !is.na(accelerator_Crunchbase)) {
      if(grepl(accelerator_F6S, accelerator_Crunchbase, fixed = TRUE) | grepl(accelerator_Crunchbase, accelerator_F6S, fixed = TRUE)) {
        accelerators_F6S_source[accelerator_F6S_index, "accelerator_name_match"] = accelerator_Crunchbase
      }
    }
  }
  
  accelerator_F6S_index <- accelerator_F6S_index + 1
}

# Create dataframe with matched accelerators only
matched_accelerators <- filter(accelerators_F6S_source, !is.na(accelerator_name_match))

# Merge rows by matched name
matched_accelerators <- aggregate(
  matched_accelerators,
  list(name = matched_accelerators$accelerator_name_match),
  paste,
  collapse = ", "
)

# ### Clean cohort size ###
cohort_size_index <- 1

for (size in matched_accelerators$cohort_size) {
  if (!is.na(size) && size == "NA") {
    matched_accelerators[cohort_size_index, "cohort_size"] = NA
  }
  
  for (size_split in strsplit(size, ", ")) {
    for (size_split_each in size_split) {
      initial_size = NA
      
      if (!is.na(size_split_each) && size_split_each != "NA") {
        temp_size = as.numeric(size_split_each)
        if(!is.na(initial_size)) {
          if (temp_size > initial_size) {
            initial_size = temp_size
          }
        } else {
          initial_size = temp_size
        }
        matched_accelerators[cohort_size_index, "cohort_size"] = initial_size
      } else {
        matched_accelerators[cohort_size_index, "cohort_size"] = NA
      }
    }
  }
  
  if (length(strsplit(size, ", ")) > 1) {
    print(size)
  }
  
  cohort_size_index = cohort_size_index + 1
}
# ### End clean cohort size ###


# ### Clean funding provided ###
funding_index <- 1

for (funding in matched_accelerators$funding_provided) {
  #    matched_accelerators[funding_index, "funding_provided"] = NA

  
  for (funding_split in strsplit(funding, ", ")) {
    funding_value <- NA
    funding_temp <- NA
    
    for (funding_each in funding_split) {
      if(funding_each != "NA") {
        for (funding_word in strsplit(funding_each, " ")) {
          
          
          for (funding_word_each in funding_word) {
            if(grepl("k", funding_word_each, fixed = TRUE)) {
              funding_temp <- currencyConversion(
                as.numeric(str_remove_all(funding_word_each, "[kKmMbB€£$]")) * 1000,
                "EUR",
                "USD"
              )
            }
            
            if(grepl("m", funding_word_each, fixed = TRUE)) {
              funding_temp <- currencyConversion(
                as.numeric(str_remove_all(funding_word_each, "[kKmMbB€£$]")) * 1000000,
                "EUR",
                "USD"
              )
            }
            
            if(funding_word_each == "0" && !is.na(funding_temp)) {
              funding_temp = 0
            }
          }
          
          if(!is.na(funding_value) && !is.na(funding_temp)) {
            if(funding_temp > funding_value) {
              funding_value <- funding_temp
            }
          }
          
          if(!is.na(funding_temp && is.na(funding_value))) {
            funding_value <- funding_temp
          }
        }
      }
    }
    
    matched_accelerators[funding_index, "funding_provided"] = funding_value
  }
  
  funding_index <- funding_index + 1
}

# ### End clean funding provided ###


# ### Insert matched data into accelerators dataframe ###

accelerators$cohort_size <- matched_accelerators$cohort_size[match(accelerators$name, matched_accelerators$name)]

# ### End insert matched data into accelerators dataframe ###




