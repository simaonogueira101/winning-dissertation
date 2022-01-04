startups_Crunchbase_source <- read_excel("./data-original/ancient/Crunchbase - Companies, 1-8000 COMPLETE.xlsx")

startups = startups_Crunchbase_source %>%
  # Create column for max valuation of range
  mutate(
    most_recent_valuation_max_USD = case_when(
      grepl(" to ", most_recent_valuation_range, fixed = TRUE)
        ~ sapply(str_split(most_recent_valuation_range, " to "),"[", 2),
      TRUE ~ most_recent_valuation_range
    ),
  ) %>%
  
  # Standard notation for money value
  mutate(
    most_recent_valuation_max_USD = case_when(
      grepl("B+", most_recent_valuation_max_USD, fixed = TRUE)
      ~ paste(
        substring(most_recent_valuation_max_USD, 2, nchar(most_recent_valuation_max_USD)-2),
        "000000000",
        sep = ""
      ),
      grepl("B", most_recent_valuation_max_USD, fixed = TRUE)
      ~ paste(
        substring(most_recent_valuation_max_USD, 2, nchar(most_recent_valuation_max_USD)-1),
        "000000000",
        sep = ""
      ),
      grepl("M+", most_recent_valuation_max_USD, fixed = TRUE)
      ~ paste(
        substring(most_recent_valuation_max_USD, 2, nchar(most_recent_valuation_max_USD)-1),
        "000000",
        sep = ""
      ),
      grepl("M", most_recent_valuation_max_USD, fixed = TRUE)
      ~ paste(
        substring(most_recent_valuation_max_USD, 2, nchar(most_recent_valuation_max_USD)-1),
        "000000",
        sep = ""
      ),
      TRUE ~ most_recent_valuation_max_USD
    )
  ) %>%
  
  mutate(
    valuation_at_ipo_initial_currency_symbol = case_when(
      substring(valuation_at_ipo, 1, 1) == "€" ~ "EUR",
      substring(valuation_at_ipo, 1, 1) == "£" ~ "GBP",
      substring(valuation_at_ipo, 1, 1) == "$" ~ "USD"
    ),
    valuation_at_ipo_initial_currency = substring(valuation_at_ipo, 2),
    .after = valuation_at_ipo
  ) %>%
  
  mutate(
    valuation_at_ipo_initial_currency = gsub(',', '', valuation_at_ipo_initial_currency),
  ) %>%
  
  mutate(
    valuation_at_ipo_USD = as.numeric(valuation_at_ipo_initial_currency),
  ) %>%
  
  # Convert all money values to USD
  mutate(
    valuation_at_ipo_USD = currencyConversion(
      valuation_at_ipo_USD,
      valuation_at_ipo_initial_currency_symbol,
      "USD"
    )
  ) %>%
  
  # Merge valuations
  mutate(
    valuation_final_USD = case_when(
      (!is.na(most_recent_valuation_max_USD) & !is.na(valuation_at_ipo_USD)) ~ as.numeric(pmax(most_recent_valuation_max_USD, valuation_at_ipo_USD)),
      (!is.na(most_recent_valuation_max_USD) & is.na(valuation_at_ipo_USD)) ~ as.numeric(most_recent_valuation_max_USD),
      (is.na(most_recent_valuation_max_USD) & !is.na(valuation_at_ipo_USD)) ~ as.numeric(valuation_at_ipo_USD)
    ),
  )


