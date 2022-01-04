# ### Location data ###

# Request all locations from Crunchbase
location_data_request <- POST(
  "https://api.crunchbase.com/api/v4/searches/locations",
  query = list(
    "user_key" = CRUNCHBASE_USER_KEY
  ),
  body = '
    {
      "field_ids": [
        "identifier",
        "name",
        "locations",
        "facet_ids"
      ],
      "query": [
        {
          "type": "predicate",
          "field_id": "facet_ids",
          "operator_id": "includes",
          "values": [
            "group", "country"
          ]
        }
      ],
      "limit": 1000
    }
  '
)

# Convert JSON to R data structure
location_data_source <- fromJSON(rawToChar(location_data_request$content))

# Convert initial data structure to tibble for betterhandling
location_data <- location_data_source$entities %>% 
  as_tibble()

# Save for later reference
saveRDS(location_data, paste0("./data-original/crunchbase_archive/location_data__", Sys.Date(), ".rds"))

# Get relevant locations uuids
location_EU_uuid <- location_data %>% filter(properties$name == "European Union (EU)") %>% .$uuid
location_UK_uuid <- location_data %>% filter(properties$name == "United Kingdom") %>% .$uuid

# ### End location data ###


# ### Accelerator data ###

accelerator_data_request = POST(
  "https://api.crunchbase.com/api/v4/searches/organizations",
  query = list(
    "user_key" = CRUNCHBASE_USER_KEY
  ),
  body = sprintf(
    '
      {
        "field_ids": [
          "identifier",
          "name",
          "description",
          "categories",
          "category_groups",
          "company_type",
          "demo_days",
          "diversity_spotlights",
          "founder_identifiers",
          "investor_stage",
          "investor_type",
          "location_identifiers",
          "num_alumni",
          "num_current_advisor_positions",
          "num_current_positions",
          "num_employees_enum",
          "num_enrollments",
          "num_exits",
          "num_exits_ipo",
          "num_founders",
          "num_investments",
          "program_duration",
          "program_type",
          "revenue_range",
          "school_method",
          "school_program",
          "school_type",
          "website"
        ],
        "query": [
          {
            "type": "predicate",
            "field_id": "investor_type",
            "operator_id": "includes",
            "values": [
              "accelerator"
            ]
          },
          {
            "type": "predicate",
            "field_id": "location_identifiers",
            "operator_id": "includes",
            "values": [
              "%s",
              "%s"
            ]
          }
        ],
        "limit": 1000
      }
    ',
    location_EU_uuid,
    location_UK_uuid
  )
)

accelerator_data_source <- fromJSON(rawToChar(accelerator_data_request$content))
accelerator_data <- accelerator_data_source

saveRDS(accelerator_data, paste0("./data-original/crunchbase_archive/accelerator_data__", Sys.Date(), ".rds"))

# ### End accelerator data ###


# ### Investment data ###

investmentDataRequest <- function(accelerator_uuid){
  investment_data_request = POST(
    "https://api.crunchbase.com/api/v4/searches/investments",
    query = list(
      "user_key" = CRUNCHBASE_USER_KEY
    ),
    body = sprintf(
      '
      {
        "field_ids": [
          "identifier",
          "announced_on",
          "funding_round_investment_type",
          "funding_round_money_raised",
          "investor_identifier",
          "money_invested",
          "organization_identifier"
        ],
        "query": [
          {
            "type": "predicate",
            "field_id": "investor_identifier",
            "operator_id": "includes",
            "values": [
              "%s"
            ]
          },
          {
            "type": "predicate",
            "field_id": "funding_round_investment_type",
            "operator_id": "includes",
            "values": [
              "seed",
              "pre_seed"
            ]
          }
        ],
        "limit": 1000
      }
    ',
      accelerator_uuid
    )
  )
  
  temp_investment_data_source <- fromJSON(rawToChar(investment_data_request$content))
  temp_investment_data <- temp_investment_data_source$entities %>% 
    as_tibble()
  
  return(temp_investment_data)
}

accelerator_uuids <- accelerator_data$entities$uuid

# Request first accelerator's investments for data structure
first_investment_data <- investmentDataRequest(accelerator_uuids[1])
investment_data <- first_investment_data

# Request rest of accelerator's investments
accelerator_investments_index <- 1
for (accelerator_uuid in accelerator_uuids[2:length(accelerator_uuids)]) {
  n_investment_data <- investmentDataRequest(accelerator_uuid)
  investment_data <- bind_rows(investment_data, n_investment_data)
  
  # Wait 1 second to prevent resource max
  Sys.sleep(1)
  
  accelerator_investments_index <- accelerator_investments_index + 1
  print(paste0(accelerator_investments_index, " / ", length(accelerator_uuids)))
}

saveRDS(investment_data, paste0("./data-original/crunchbase_archive/investment_data__", Sys.Date(), ".rds"))

# ### End investment data ###


# ### Startup data ###

startupDataRequest <- function(startup_uuid){
  startup_data_request = GET(
    paste0("https://api.crunchbase.com/api/v4/entities/organizations/", startup_uuid),
    query = list(
      "user_key" = CRUNCHBASE_USER_KEY,
      "field_ids" = "identifier,name,description,categories,category_groups,contact_email,diversity_spotlights,funding_stage,funding_total,funds_total,location_identifiers,revenue_range,valuation,website",
      "card_ids" = "acquirer_acquisitions,founders,raised_investments,ipos"
    )
  )
  
  temp_startup_data_source <- fromJSON(rawToChar(startup_data_request$content))
  temp_startup_data <- temp_startup_data_source
  
  return(temp_startup_data)
}

startup_uuids <- investment_data$properties$organization_identifier$permalink

startup_data <- list()

first_startup_data <- startupDataRequest(startup_uuids[1])
startup_data[startup_uuids[1]] <- list(first_startup_data)

startup_index <- 1
for (startup_uuid in startup_uuids[2:length(startup_uuids)]) {
  n_startup_data <- startupDataRequest(startup_uuid)
  
  startup_data[startup_uuid] <- list(n_startup_data)
  
  # Large dataset, better save soon
  saveRDS(startup_data, paste0("./data-original/crunchbase_archive/startup_data__", Sys.Date(), ".rds"))
  
  startup_index <- startup_index + 1
  print(paste0(startup_index, " / ", length(startup_uuids), " - ", startup_uuid))
}

# ### End startup data ###


# ### Accelerator founder data ###

acceleratorFounderDataRequest <- function(accelerator_founder_uuid){
  accelerator_founder_data_request = GET(
    paste0("https://api.crunchbase.com/api/v4/entities/people/", accelerator_founder_uuid),
    query = list(
      "user_key" = CRUNCHBASE_USER_KEY,
      "field_ids" = "identifier,name,description,num_founded_organizations,num_investments,num_jobs",
      "card_ids" = "degrees,jobs"
    )
  )
  
  temp_accelerator_founder_data_source <- fromJSON(rawToChar(accelerator_founder_data_request$content))
  temp_accelerator_founder_data <- temp_accelerator_founder_data_source
  
  return(temp_accelerator_founder_data)
}

# ### End accelerator founder data ###

