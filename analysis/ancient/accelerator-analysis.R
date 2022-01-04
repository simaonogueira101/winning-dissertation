accelerators_Crunchbase_source <- read_excel("./data-original/ancient/Crunchbase - Accelerators, 1-882 COMPLETE.xlsx")

# cohort_size ⚠️
# cohort_composition ✅
# program_duration ✅
# funding_provided
# equity_taken
# mentorship
# advisory_and_managing_directors
# educational_programming
# co_working_space ✅
# graduation_event 
# program_location ✅
# external_stakeholders

accelerators <- accelerators_Crunchbase_source %>%
  mutate(
    # Co-working space
    co_working_space = case_when(
      accelerator_program_type == "On-Site" ~ TRUE,
      TRUE ~ FALSE
    ),
    
    # Program location
    # Spatial Visualization with ggplot:
    # https://egallic.fr/en/european-map-using-r/
    program_location = location,
    
    # Program duration
    program_duration = accelerator_duration_weeks
  )

accelerators_industry_groups <- accelerators[c("name", "industry_groups")] %>%
  mutate(industry_groups = strsplit(industry_groups, ", ")) %>%
  unnest(industry_groups)

generic_industry_groups <- c(
  "—",
  "Administrative Services",
  "Community and Lifestyle",
  "Financial Services",
  "Lending and Investments",
  "Other",
  "Professional Services"
)

# Cohort composition
accelerators <- accelerators %>%
  rowwise() %>%
  mutate(
    cohort_composition = case_when(
      length(
        which(
          accelerators_industry_groups$name == name
          & !accelerators_industry_groups$industry_groups %in% generic_industry_groups
        )
      ) > 0 ~ "focused",
      TRUE ~ "generic"
    )
  )
