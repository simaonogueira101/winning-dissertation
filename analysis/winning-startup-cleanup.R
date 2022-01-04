# Name: name
# Received > $500 K within 1 year: received_500k
# Total Raised: total_raised
# Max valuation: max_valuation
# Exit of $ 1 M or more: exit_of_1m

investedAccelerator <- function(startup){
  temp_raised_investments <- startup$cards$raised_investments %>% 
    filter(investor_identifier$permalink %in% accelerator_df$accelerator_name)
  
  temp_raised_investments_ordered <- temp_raised_investments[
    order(as.Date(temp_raised_investments$announced_on)),
  ]
  
  return(temp_raised_investments_ordered[1,]$investor_identifier$permalink)
}

received500k <- function(startup){
  temp_raised_investments <- startup$cards$raised_investments %>% 
    filter(grepl("accelerator", investor_type))
  
  temp_raised_investments_ordered <- temp_raised_investments[
    order(as.Date(temp_raised_investments$announced_on)),
  ]
  
  temp_raised_investments_init_date <- as.Date(
    temp_raised_investments_ordered[1,]$announced_on, "%Y-%m-%d"
  )
  
  temp_raised_investments_last_date <- temp_raised_investments_init_date + 365
  
  temp_raised_investments_range <- filter(
    startup$cards$raised_investments,
    announced_on >= temp_raised_investments_init_date & announced_on <= temp_raised_investments_last_date
  )
  
  temp_raised_investments_range_ordered <- temp_raised_investments_range[
    order(as.Date(temp_raised_investments_range$announced_on)),
  ]
  
  temp_raised_investments_values <- temp_raised_investments_range_ordered[2:nrow(temp_raised_investments_range_ordered), "funding_round_money_raised"]["value_usd"]
  
  temp_raised_investments_sum <- sum(
    temp_raised_investments_values,
    na.rm = TRUE
  )
  
  if(temp_raised_investments_sum >= 500000) {
    return(1)
  } else {
    return(0)
  }
}

exitOf1m <- function(startup){
  temp_exit_value <- NA
  
  temp_ipo_exit_value <- NA
  temp_acquisition_exit_value <- NA
  
  temp_ipo_date <- NA
  temp_acquisition_date <- NA
  
  temp_acquisition_value <- NA
  
  if(!is.null(nrow(startup$cards$ipos))) {
    temp_ipo_date <- as.Date(
      startup$cards$ipos$went_public_on,
      "%Y-%m-%d"
    )
  
    if(!is.null(startup$cards$ipos$valuation$value_usd)) {
      temp_ipo_exit_value <- startup$cards$ipos$valuation$value_usd
    }
  }

  if(!is.null(nrow(startup$cards$acquirer_acquisitions))) {
    temp_startup_acquisitions_ordered <- startup$cards$acquirer_acquisitions[
      order(as.Date(startup$cards$acquirer_acquisitions$announced_on$value)),
    ]

    temp_acquisition_date <- as.Date(
      temp_startup_acquisitions_ordered[1,]$announced_on$value,
      "%Y-%m-%d"
    )

    temp_acquisition_value <- temp_startup_acquisitions_ordered[1,]$price$value_usd
  }
  
  if(!is.null(temp_acquisition_value)) {
    if(!is.na(temp_ipo_date) & !is.na(temp_acquisition_date)) {
      if(temp_ipo_date < temp_acquisition_date) {
        temp_exit_value <- temp_ipo_exit_value
      } else {
        temp_exit_value <- temp_acquisition_value
      }
    } else if(!is.na(temp_ipo_date) & is.na(temp_acquisition_date)) {
      temp_exit_value <- temp_ipo_exit_value
    } else if(is.na(temp_ipo_date) & !is.na(temp_acquisition_date)) {
      temp_exit_value <- temp_acquisition_value
    }
  } else if(!is.na(temp_ipo_date)) {
    temp_exit_value <- temp_ipo_exit_value
  }
  
  return(temp_exit_value)
}

startupDataCleanUp <- function(data_path){
  startup_data_temp <- readRDS(paste0("./data-original/crunchbase_archive/", data_path))
  
  temp_startup_df <- data.frame()
  
  temp_startup_df_index <- 1
  for (startup in startup_data_temp) {
    temp_total_raised <- startup$properties$funding_total$value_usd
    if(is_null(temp_total_raised)) {
      temp_total_raised <- NA
    }
    
    temp_max_valuation <- startup$properties$valuation$value_usd
    if(is_null(temp_max_valuation)) {
      temp_max_valuation <- NA
    }
    
    temp_startup_df_temp <- data.frame(
      "startup_name" = startup$properties$identifier$permalink,        # str
      "accelerator_name" = investedAccelerator(startup),               # str
      "received_500k" = received500k(startup),                         # 0 for no, 1 for yes
      "total_raised" = temp_total_raised,                              # int
      "max_valuation" = temp_max_valuation,                            # int
      "exit_of_1m" = exitOf1m(startup)                                 # 0 for no, 1 for yes
    )
    
    temp_startup_df <- bind_rows(temp_startup_df, temp_startup_df_temp)
    
    print(paste0(temp_startup_df_index, " / ", length(startup_data_temp)))
    temp_startup_df_index <- temp_startup_df_index + 1
  }
  
  temp_startup_df <- temp_startup_df %>% mutate(
    max_valuation = case_when(
      exit_of_1m > max_valuation ~ exit_of_1m,
      (is.na(max_valuation) & !is.na(exit_of_1m)) ~ exit_of_1m,
      TRUE ~ max_valuation
    ),
    exit_of_1m = case_when(
      exit_of_1m > 1000000 ~ 1,
      TRUE ~ 0
    )
  )
  
  temp_startup_df <- temp_startup_df %>% mutate(
    received_500k = as.factor(received_500k),
    exit_of_1m = as.factor(exit_of_1m)
  )
}
