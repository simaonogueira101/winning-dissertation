# Load packages
source("./analysis/helpers/packages.R")

# Turn off scientific notation
options(scipen = 999)


# ### Crunchbase API and cleanup ###

# Load environment keys
source("./analysis/helpers/ENV_KEYS.R")

# Load API requests
source("./analysis/winning-api.R")
source("./analysis/winning-accelerator-cleanup.R")
source("./analysis/winning-startup-cleanup.R")

accelerator_df <- acceleratorDataCleanUp("accelerator_data__2021-11-22.rds")
saveRDS(accelerator_df, paste0("./data-original/crunchbase_archive/clean__accelerator_data__", Sys.Date(), ".rds"))

startup_df <- startupDataCleanUp("startup_data__2021-11-23.rds")
saveRDS(startup_df, paste0("./data-original/crunchbase_archive/clean__startup_data__", Sys.Date(), ".rds"))

# Get accelerators with at least one startup match
# Save result to .xlsx for completion
matched_accelerator_df <- filter(accelerator_df, accelerator_name %in% names(table(startup_df$accelerator_name)))
write.xlsx(
  matched_accelerator_df,
  paste0("./data-original/matched_accelerator_df_excel__", Sys.Date(), ".xlsx"),
  showNA = FALSE,
  col.names = TRUE,
  row.names = TRUE,
  append = FALSE
)

# ### End Crunchbase API and cleanup ###


# ### Statistical analysis ###

source("./winning-statistics.R")

# ### End statistical analysis ###


# ### Ancient analysis, F6S and match ###
# Not used in favor of Crunchbase API.

# # Load functions
# source("./analysis/helpers/exchange-rates.R")
# 
# # Load analysis
# source("./analysis/ancient/accelerator-analysis.R")
# source("./analysis/ancient/accelerator-match.R")
# source("./analysis/ancient/startup-analysis.R")

# ### End ancient analysis, F6S and match ###
