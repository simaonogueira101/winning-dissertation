# Name: name
# Cohort size: cohort_size
# Cohort composition: cohort_composition
# Program duration: program_duration
# Funding provided: funding_provided
# Equity taken: equity_taken
# Internal Mentorship: internal_mentorship
# External Mentorship: external_mentorship
# Advisory and managing directors: advisory_and_managing_directors
# Educational Programming: educational_programming
# Co-working space: co_working_space
# Graduation event, such as Demo day: graduation_event
# Program location: program_location
# External stakeholders – Sponsors: external_stakeholders

# cohort size
# program duration
# minimum and maximum funding given
# maximum equity taken
# external mentorship opportunities
# formal education
# co-working space
# graduation events

acceleratorDataCleanUp <- function(data_path){
  accelerator_data_temp <- readRDS(paste0("./data-original/crunchbase_archive/", data_path))
  accelerator_data_entities_temp <- accelerator_data_temp$entities
  
  generic_category_groups <- c(
    "—",
    "Administrative Services",
    "Community and Lifestyle",
    "Financial Services",
    "Lending and Investments",
    "Other",
    "Professional Services"
  )
  
  temp_accelerator_df <- data.frame(
    "accelerator_name" = accelerator_data_entities_temp$properties$identifier$permalink,   # str
    "website" = accelerator_data_entities_temp$properties$website$value,                   # str
    "cohort_size" = NA,                                                                    # int // HAND-COLLECTED DATA
    "cohort_composition" = 0,                                                              # 0 for generic, 1 for focused
    "program_duration" = accelerator_data_entities_temp$properties$program_duration,       # int
    "funding_provided" = NA,                                                               # int // HAND-COLLECTED DATA, int
    "equity_taken" = NA,                                                                   # int // HAND-COLLECTED DATA, int
    "internal_mentorship" = NA,                                                            # 0 for no, 1 for yes // HAND-COLLECTED DATA
    "external_mentorship" = NA,                                                            # 0 for no, 1 for yes // HAND-COLLECTED DATA
    "advisory_and_managing_directors_prior_investor" = 0,                                  # 0 for no, 1 for yes
    "advisory_and_managing_directors_prior_entrepreneur" = 0,                              # 0 for no, 1 for yes
    "advisory_and_managing_directors_prior_corporate_exp" = 0,                             # 0 for no, 1 for yes
    "advisory_and_managing_directors_prior_university_exp" = 0,                            # 0 for no, 1 for yes
    "educational_programming" = NA,                                                        # 0 for no, 1 for yes // HAND-COLLECTED DATA
    "co_working_space" = NA,                                                               # 0 for no, 1 for yes
    "graduation_event" = NA,                                                               # 0 for no, 1 for yes
    "program_location" = NA,                                                               # str
    "external_stakeholders_corporations" = NA,                                             # 0 for no, 1 for yes // HAND-COLLECTED DATA
    "external_stakeholders_governments" = NA,                                              # 0 for no, 1 for yes // HAND-COLLECTED DATA
    "external_stakeholders_academia" = NA,                                                 # 0 for no, 1 for yes // HAND-COLLECTED DATA
    "external_stakeholders_investors" = NA                                                 # 0 for no, 1 for yes // HAND-COLLECTED DATA
  )
  
  for (temp_accelerator_index in 1:nrow(temp_accelerator_df)) {
    # Cohort composition
    temp_categories <- accelerator_data_temp$entities$properties$category_groups[[temp_accelerator_index]]
    if(length(temp_categories) > 0) {
      for (temp_category_index in 1:nrow(temp_categories)) {
        temp_category <- temp_categories[temp_category_index,]$value
        if(!(temp_category %in% generic_category_groups)) {
          temp_accelerator_df[temp_accelerator_index, "cohort_composition"] <- 1
        } else {
          if(temp_accelerator_df[temp_accelerator_index, "cohort_composition"] != 1) {
            temp_accelerator_df[temp_accelerator_index, "cohort_composition"] <- 0
          }
        }
      }
    }
    
    # Program location
    temp_accelerator_df[temp_accelerator_index, "program_location"] <- paste(
      accelerator_data_temp$entities$properties$location_identifiers[[temp_accelerator_index]]$value, collapse = ", "
    )
    
    # Advisory and managing directors
    temp_founders <- accelerator_data_entities_temp$properties$founder_identifiers[[temp_accelerator_index]]
    if(length(temp_founders) > 0) {

      temp_prior_investor <- 0
      temp_prior_entrepreneur <- 0
      temp_prior_corporate_exp <- 0
      temp_prior_university_exp <- 0

      for (temp_founder_index in 1:nrow(temp_founders)) {
        temp_founder_info <- acceleratorFounderDataRequest(temp_founders[temp_founder_index,]$uuid)

        if(!is.null(temp_founder_info$properties$num_investments)) {
          if(temp_founder_info$properties$num_investments > 0) {
            temp_prior_investor <- 1
          } else {
            if(is.na(temp_prior_investor)) {
              temp_prior_investor <- 0
            }else if(temp_prior_investor != TRUE) {
              temp_prior_investor <- 0
            }
          }
        } else {
          temp_prior_investor <- 0
        }

        if(!is.null(temp_founder_info$properties$num_founded_organizations)) {
          if(temp_founder_info$properties$num_founded_organizations > 0) {
            temp_prior_entrepreneur <- 1
          } else {
            if(is.na(temp_prior_entrepreneur)) {
              temp_prior_entrepreneur <- 0
            }else if(temp_prior_entrepreneur != TRUE) {
              temp_prior_entrepreneur <- 0
            }
          }
        } else {
          temp_prior_entrepreneur <- 0
        }

        if(!is.null(temp_founder_info$properties$num_jobs)) {
          if(temp_founder_info$properties$num_jobs - 1 > 0) {
            temp_prior_corporate_exp <- 1
          } else {
            if(is.na(temp_prior_corporate_exp)) {
              temp_prior_corporate_exp <- 0
            }else if(temp_prior_corporate_exp != TRUE) {
              temp_prior_corporate_exp <- 0
            }
          }
        } else {
          temp_prior_corporate_exp <- 0
        }

        if(length(temp_founder_info$cards$degrees) > 0) {
          if(nrow(temp_founder_info$cards$degrees) > 0) {
            temp_prior_university_exp <- 1
          } else {
            if(is.na(temp_prior_university_exp)) {
              temp_prior_university_exp <- 0
            }else if(temp_prior_university_exp != TRUE) {
              temp_prior_university_exp <- 0
            }
          }
        } else {
          temp_prior_university_exp <- 0
        }

        temp_accelerator_df[temp_accelerator_index, "advisory_and_managing_directors_prior_investor"] <- temp_prior_investor
        temp_accelerator_df[temp_accelerator_index, "advisory_and_managing_directors_prior_entrepreneur"] <- temp_prior_entrepreneur
        temp_accelerator_df[temp_accelerator_index, "advisory_and_managing_directors_prior_corporate_exp"] <- temp_prior_corporate_exp
        temp_accelerator_df[temp_accelerator_index, "advisory_and_managing_directors_prior_university_exp"] <- temp_prior_university_exp
      }

      # Wait 1 second to prevent resource max
      Sys.sleep(1)
    }
    
    # Co-working space
    temp_co_working <- accelerator_data_entities_temp$properties$program_type[[temp_accelerator_index]]
    if(!is.na(temp_co_working)) {
      if(temp_co_working == "on_site") {
        temp_accelerator_df[temp_accelerator_index, "co_working_space"] <- 1
      } else {
        if(temp_co_working == "online") {
          temp_accelerator_df[temp_accelerator_index, "co_working_space"] <- 0
        }
      }
    }
    
    # Graduation event
    temp_graduation <- accelerator_data_entities_temp$properties$demo_days[[temp_accelerator_index]]
    if(!is.na(temp_graduation)) {
      if(temp_graduation) {
        temp_accelerator_df[temp_accelerator_index, "graduation_event"] <- 1
      } else {
        if(!temp_graduation) {
          temp_accelerator_df[temp_accelerator_index, "graduation_event"] <- 0
        }
      }
    }
    
    print(paste0(temp_accelerator_index, " / ", nrow(temp_accelerator_df)))
  }
  
  temp_accelerator_df <- temp_accelerator_df %>% mutate(
    cohort_composition = as.factor(cohort_composition),
    mentorship = as.factor(mentorship),
    advisory_and_managing_directors_prior_investor = as.factor(advisory_and_managing_directors_prior_investor),
    advisory_and_managing_directors_prior_entrepreneur = as.factor(advisory_and_managing_directors_prior_entrepreneur),
    advisory_and_managing_directors_prior_corporate_exp = as.factor(advisory_and_managing_directors_prior_corporate_exp),
    advisory_and_managing_directors_prior_university_exp = as.factor(advisory_and_managing_directors_prior_university_exp),
    educational_programming = as.factor(educational_programming),
    co_working_space = as.factor(co_working_space),
    graduation_event = as.factor(graduation_event),
    external_stakeholders_corporations = as.factor(external_stakeholders_corporations),
    external_stakeholders_governments = as.factor(external_stakeholders_governments),
    external_stakeholders_academia = as.factor(external_stakeholders_academia),
    external_stakeholders_investors = as.factor(external_stakeholders_investors)
  )
  
  return(temp_accelerator_df)
}
