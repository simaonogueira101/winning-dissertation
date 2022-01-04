# ### Get clean and complete data ###

matched_accelerator_df_data_path <- "matched__accelerator_data__2021-11-23_ANON.rds"
matched_accelerator_df <- readRDS(paste0("./data-anonymized/", matched_accelerator_df_data_path))

clean_startup_df_data_path <- "clean__startup_data__2021-11-23_ANON.rds"
clean_startup_df <- readRDS(paste0("./data-anonymized/", clean_startup_df_data_path))

matched_accelerator_df <- matched_accelerator_df %>% mutate(
  cohort_composition = as.factor(cohort_composition),
  internal_mentorship = as.factor(internal_mentorship),
  external_mentorship = as.factor(external_mentorship),
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

matched_accelerator_df <- matched_accelerator_df[complete.cases(matched_accelerator_df), ]

clean_startup_df <- clean_startup_df %>% mutate(
  received_500k = as.factor(received_500k),
  exit_of_1m = as.factor(exit_of_1m)
)

merged_df <- merge(clean_startup_df, matched_accelerator_df, by = "accelerator_name")

# ### End get clean and complete data ###


# ### Test for incomplete rows ###

subset_merged_df <- select(
  merged_df,
  c(
    accelerator_name,
    cohort_size,
    cohort_composition,
    program_duration,
    funding_provided,
    equity_taken,
    external_mentorship,
    advisory_and_managing_directors_prior_investor,
    advisory_and_managing_directors_prior_entrepreneur,
    advisory_and_managing_directors_prior_corporate_exp,
    advisory_and_managing_directors_prior_university_exp,
    educational_programming,
    co_working_space,
    graduation_event,
    external_stakeholders_corporations,
    external_stakeholders_governments,
    external_stakeholders_academia,
    external_stakeholders_investors
  )
)

incomplete_subset_merged_df <- subset_merged_df %>% filter(!complete.cases(.))
sort(table(incomplete_subset_merged_df$accelerator_name))

# ### End test for incomplete rows ###


# ### Accelerator Founding Managing Director Backgrounds ###

md_backgrounds <- matched_accelerator_df %>% select(
  c(
    advisory_and_managing_directors_prior_investor,
    advisory_and_managing_directors_prior_entrepreneur,
    advisory_and_managing_directors_prior_corporate_exp,
    advisory_and_managing_directors_prior_university_exp
  )
)

md_backgrounds_verbose <- c(
  "Prior Investor Exp.",
  "Prior Entrepreneur Exp.",
  "Prior Corporate Exp.",
  "Prior Academic Exp."
)

md_backgrounds_desc <- md_backgrounds %>%
  lapply(function(x) {as.numeric(as.character(x))}) %>%
  as.data.frame()

md_backgrounds_corr <- corstarsl(md_backgrounds, md_backgrounds_verbose)

# ### End Accelerator Founding Managing Director Backgrounds ###


# ### Accelerator Founding Sponsors ###

founding_sponsors <- matched_accelerator_df %>% select(
  c(
    external_stakeholders_corporations,
    external_stakeholders_governments,
    external_stakeholders_academia,
    external_stakeholders_investors
  )
)

founding_sponsors_verbose <- c(
  "Corporation Sponsor",
  "Government Sponsor",
  "Academia Sponsor",
  "Investor Sponsor"
)

founding_sponsors_desc <- founding_sponsors %>%
  lapply(function(x) {as.numeric(as.character(x))}) %>%
  as.data.frame()

founding_sponsors_corr <- corstarsl(founding_sponsors, founding_sponsors_verbose)

# ### End Accelerator Founding Sponsors ###


# ### Accelerator Founding Sponsors ~ Accelerator Founding Managing Director Backgrounds ###

acc_spon_md_back_m1 <- glm(
  external_stakeholders_corporations ~
    advisory_and_managing_directors_prior_investor +
    advisory_and_managing_directors_prior_entrepreneur +
    advisory_and_managing_directors_prior_corporate_exp +
    advisory_and_managing_directors_prior_university_exp,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

acc_spon_md_back_m2 <- glm(
  external_stakeholders_governments ~
    advisory_and_managing_directors_prior_investor +
    advisory_and_managing_directors_prior_entrepreneur +
    advisory_and_managing_directors_prior_corporate_exp +
    advisory_and_managing_directors_prior_university_exp,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

acc_spon_md_back_m3 <- glm(
  external_stakeholders_academia ~
    advisory_and_managing_directors_prior_investor +
    advisory_and_managing_directors_prior_entrepreneur +
    advisory_and_managing_directors_prior_corporate_exp +
    advisory_and_managing_directors_prior_university_exp,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

acc_spon_md_back_m4 <- glm(
  external_stakeholders_investors ~
    advisory_and_managing_directors_prior_investor +
    advisory_and_managing_directors_prior_entrepreneur +
    advisory_and_managing_directors_prior_corporate_exp +
    advisory_and_managing_directors_prior_university_exp,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

# ### End Accelerator Founding Sponsors ~ Accelerator Founding Managing Director Backgrounds ###


# ### Accelerator Design Choices ###

acc_design_choices <- matched_accelerator_df %>%
  select(
    cohort_size,
    cohort_composition,
    program_duration,
    funding_provided,
    equity_taken,
    external_mentorship,
    educational_programming,
    co_working_space,
    graduation_event
  ) %>%
  mutate(
    cohort_composition = as.numeric(as.character(cohort_composition)),
    external_mentorship = as.numeric(as.character(external_mentorship)),
    educational_programming = as.numeric(as.character(educational_programming)),
    co_working_space = as.numeric(as.character(co_working_space)),
    graduation_event = as.numeric(as.character(graduation_event))
  )

acc_design_choices_verbose <- c(
  "Cohort Size",
  "Focused Cohort Composition",
  "Program Duration (in number of weeks)",
  "Funding Provided (in thousands of \\$)",
  "Equity Taken",
  "Provides External Mentors",
  "Provides Formal Education",
  "Provides Workspace",
  "Graduation Event"
)

acc_design_choices_verbose_html <- c(
  "Cohort Size",
  "Focused Cohort Composition",
  "Program Duration (in number of weeks)",
  "Funding Provided (in thousands of \t\b$)",
  "Equity Taken",
  "Provides External Mentors",
  "Provides Formal Education",
  "Provides Workspace",
  "Graduation Event"
)

acc_design_choices_desc <- acc_design_choices %>%
  as.data.frame()

# ### End Accelerator Design Choices ###


# ### Accelerator Geographic Distribution ###

register_google(key = GOOGLE_API_KEY)

acc_geo_locations <- matched_accelerator_df$program_location %>%
  table() %>%
  as.data.frame() %>%
  `names<-`(c("Cities", "Freq")) %>%
  mutate(
    Cities = as.character(Cities)
  )

acc_geo_countries <- lapply(
  matched_accelerator_df$program_location,
  function(x) {
    loc_split <- strsplit(x, ", ")[[1]]
    loc_country <- loc_split[3]
    return(loc_country)
  }
) %>%
  unlist() %>%
  table() %>%
  as.data.frame() %>%
  arrange(desc(Freq)) %>%
  `names<-`(c("Countries", "#"))


# Uses paid resources from Google.
# Do not uncomment.
# 
# acc_geo_latlong <- geocode(acc_geo_locations$Cities)
# acc_geo_latlong <- as.data.frame(acc_geo_latlong)
# 
# acc_geo_df <- acc_geo_locations
# acc_geo_df$lon <- acc_geo_latlong$lon
# acc_geo_df$lat <- acc_geo_latlong$lat
# saveRDS(acc_geo_df, paste0("./data-original/crunchbase_archive/accelerator_latlong_data__", Sys.Date(), ".rds"))

accelerator_latlong_data_path <- "accelerator_latlong_data__2021-12-04.rds"
acc_geo_df <- readRDS(paste0("./data-anonymized/", accelerator_latlong_data_path))

# European map
acc_geo_map <- get_map(c(lon = 9.0000, lat = 53.0000), zoom = 4)
acc_geo_map_points <- ggmap(acc_geo_map) +
  geom_point(aes(x = lon, y = lat, size = sqrt(Freq)), data = acc_geo_df, alpha = .5) +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(), 
    axis.ticks = element_blank(),
    legend.position = "none"
  )

# ### End Accelerator Geographic Distribution ###


# ### Accelerator Industry Clusters ###

acc_industry_clusters_data_path <- "accelerator_industry_clusters_data__2021-11-22.rds"
acc_industry_clusters <- readRDS(paste0("./data-anonymized/", acc_industry_clusters_data_path))

acc_industry_clusters_list <- c()
for (category_group in acc_industry_clusters) {
  for (category in category_group$value) {
    acc_industry_clusters_list <- c(acc_industry_clusters_list, category)
  }
}

acc_industry_clusters_verbose <- c(
  "Industry Cluster",
  "Percentage"
)

acc_industry_clusters_df <- as.data.frame(table(acc_industry_clusters_list)) %>%
  mutate(
    Percentage = Freq / sum(.$Freq)
  ) %>%
  arrange(desc(Percentage)) %>%
  add_row(
    acc_industry_clusters_list = "All Other Clusters",
    Freq = sum(filter(., .$Percentage < 0.01)$Freq) + filter(., .$acc_industry_clusters_list == "Other")$Freq,
    Percentage = sum(filter(., .$Percentage < 0.01)$Percentage) + filter(., .$acc_industry_clusters_list == "Other")$Percentage
  ) %>%
  filter(
    (.$Percentage >= 0.01 & .$acc_industry_clusters_list != "Other")
  ) %>%
  mutate(
    Percentage = percent(Percentage)
  )

# ### End Accelerator Industry Clusters ###


# ### Accelerator Founding Managing Director Backgrounds ~ Accelerator Design Choices ###

md_back_acc_design_m1 <- glm(
  advisory_and_managing_directors_prior_investor ~
    cohort_size +
    cohort_composition +
    program_duration +
    funding_provided +
    equity_taken +
    external_mentorship +
    educational_programming +
    co_working_space +
    graduation_event,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

md_back_acc_design_m2 <- glm(
  advisory_and_managing_directors_prior_entrepreneur ~
    cohort_size +
    cohort_composition +
    program_duration +
    funding_provided +
    equity_taken +
    external_mentorship +
    educational_programming +
    co_working_space +
    graduation_event,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

md_back_acc_design_m3 <- glm(
  advisory_and_managing_directors_prior_corporate_exp ~
    cohort_size +
    cohort_composition +
    program_duration +
    funding_provided +
    equity_taken +
    external_mentorship +
    educational_programming +
    co_working_space +
    graduation_event,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

md_back_acc_design_m4 <- glm(
  advisory_and_managing_directors_prior_university_exp ~
    cohort_size +
    cohort_composition +
    program_duration +
    funding_provided +
    equity_taken +
    external_mentorship +
    educational_programming +
    co_working_space +
    graduation_event,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

# ### End Accelerator Founding Managing Director Backgrounds ~ Accelerator Design Choices ###


# ### Accelerator Founding Sponsors ~ Accelerator Design Choices ###

acc_spon_acc_design_m1 <- glm(
  external_stakeholders_corporations ~
    cohort_size +
    cohort_composition +
    program_duration +
    funding_provided +
    equity_taken +
    external_mentorship +
    educational_programming +
    co_working_space +
    graduation_event,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

acc_spon_acc_design_m2 <- glm(
  external_stakeholders_governments ~
    cohort_size +
    cohort_composition +
    program_duration +
    funding_provided +
    equity_taken +
    external_mentorship +
    educational_programming +
    co_working_space +
    graduation_event,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

acc_spon_acc_design_m3 <- glm(
  external_stakeholders_academia ~
    cohort_size +
    cohort_composition +
    program_duration +
    funding_provided +
    equity_taken +
    external_mentorship +
    educational_programming +
    co_working_space +
    graduation_event,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

acc_spon_acc_design_m4 <- glm(
  external_stakeholders_investors ~
    cohort_size +
    cohort_composition +
    program_duration +
    funding_provided +
    equity_taken +
    external_mentorship +
    educational_programming +
    co_working_space +
    graduation_event,
  family = binomial(link = "probit"),
  data = matched_accelerator_df
)

# ### End Accelerator Founding Sponsors ~ Accelerator Design Choices ###


# ### Accelerator Company Performance ###

acc_company_performance <- merged_df %>%
  select(
    received_500k,
    total_raised,
    max_valuation,
    exit_of_1m
  ) %>%
  mutate(
    received_500k = as.numeric(as.character(received_500k)),
    logged_total_raised = log(total_raised + 1),
    logged_max_valuation = log(max_valuation + 1),
    exit_of_1m = as.numeric(as.character(exit_of_1m))
  ) %>%
  relocate(logged_total_raised, .after = total_raised) %>%
  relocate(logged_max_valuation, .after = max_valuation)

acc_company_performance_verbose <- c(
  "Received > \\$500K within 1 year",
  "Total Raised (in millions of \\$)",
  "Logged Total Raised",
  "Max Valuation (in millions of \\$)",
  "Logged Max Valuation",
  "Exit of \\$1M or more"
)

acc_company_performance_verbose_html <- c(
  "Received > \t\b$500K within 1 year",
  "Total Raised (in millions of \t\b$)",
  "Logged Total Raised",
  "Max Valuation (in millions of \t\b$)",
  "Logged Max Valuation",
  "Exit of \t\b$1M or more"
)

acc_company_performance_desc <- acc_company_performance %>%
  as.data.frame()

# ### End Accelerator Company Performance ###


# ### Accelerator Company Performance ~ Accelerator Design Choices ###

acc_design_choices_complete_verbose <- c(
  "Investor Sponsor",
  "Corporation Sponsor",
  "Government Sponsor",
  "Academia Sponsor",
  
  "Prior Investor Exp.",
  "Prior Entrepreneur Exp.",
  "Prior Corporate Exp.",
  "Prior Academic Exp.",
  
  "Program Duration (in number of weeks)",
  "Funding Provided (in thousands of \\$)",
  "Equity Taken",
  "Cohort Size",
  "Focused Cohort Composition",
  "Provides External Mentors",
  "Provides Workspace",
  "Provides Formal Education",
  "Graduation Event"
)

acc_design_choices_complete_verbose_kable <- c(
  "Investor Sponsor",
  "Corporation Sponsor",
  "Government Sponsor",
  "Academia Sponsor",
  
  "Prior Investor Exp.",
  "Prior Entrepreneur Exp.",
  "Prior Corporate Exp.",
  "Prior Academic Exp.",
  
  "Program Duration (in number of weeks)",
  "Funding Provided (in thousands of $)",
  "Equity Taken",
  "Cohort Size",
  "Focused Cohort Composition",
  "Provides External Mentors",
  "Provides Workspace",
  "Provides Formal Education",
  "Graduation Event"
)

acc_design_choices_complete_verbose_html <- c(
  "Investor Sponsor",
  "Corporation Sponsor",
  "Government Sponsor",
  "Academia Sponsor",
  
  "Prior Investor Exp.",
  "Prior Entrepreneur Exp.",
  "Prior Corporate Exp.",
  "Prior Academic Exp.",
  
  "Program Duration (in number of weeks)",
  "Funding Provided (in thousands of \t\b$)",
  "Equity Taken",
  "Cohort Size",
  "Focused Cohort Composition",
  "Provides External Mentors",
  "Provides Workspace",
  "Provides Formal Education",
  "Graduation Event"
)

acc_company_performance_lm_verbose <- c(
  "\\shortstack{Received > \\$500K \\\\ within 1 year}",
  "\\shortstack{Logged \\\\ Total Raised}",
  "\\shortstack{Logged \\\\ Max Valuation}",
  "\\shortstack{Exit of \\$1M \\\\ or more}"
)

acc_company_performance_lm_verbose_html <- c(
  "Received > \t\b$500K within 1 year",
  "Logged Total Raised",
  "Logged Max Valuation",
  "Exit of \t\b$1M or more"
)

acc_company_performance_acc_design_m1 <- lm(
  as.numeric(as.character(received_500k)) ~
    external_stakeholders_investors +
    external_stakeholders_corporations +
    external_stakeholders_governments +
    external_stakeholders_academia +
    
    advisory_and_managing_directors_prior_investor +
    advisory_and_managing_directors_prior_entrepreneur +
    advisory_and_managing_directors_prior_corporate_exp +
    advisory_and_managing_directors_prior_university_exp +
    
    program_duration +
    funding_provided +
    equity_taken +
    cohort_size +
    cohort_composition +
    external_mentorship +
    co_working_space +
    educational_programming +
    graduation_event,
  data = merged_df
)

acc_company_performance_acc_design_m2 <- lm(
  log(total_raised + 1) ~
    external_stakeholders_investors +
    external_stakeholders_corporations +
    external_stakeholders_governments +
    external_stakeholders_academia +
    
    advisory_and_managing_directors_prior_investor +
    advisory_and_managing_directors_prior_entrepreneur +
    advisory_and_managing_directors_prior_corporate_exp +
    advisory_and_managing_directors_prior_university_exp +
    
    program_duration +
    funding_provided +
    equity_taken +
    cohort_size +
    cohort_composition +
    external_mentorship +
    co_working_space +
    educational_programming +
    graduation_event,
  data = merged_df
)

acc_company_performance_acc_design_m3 <- lm(
  log(max_valuation + 1) ~
    external_stakeholders_investors +
    external_stakeholders_corporations +
    external_stakeholders_governments +
    external_stakeholders_academia +
    
    advisory_and_managing_directors_prior_investor +
    advisory_and_managing_directors_prior_entrepreneur +
    advisory_and_managing_directors_prior_corporate_exp +
    advisory_and_managing_directors_prior_university_exp +
    
    program_duration +
    funding_provided +
    equity_taken +
    cohort_size +
    cohort_composition +
    external_mentorship +
    co_working_space +
    educational_programming +
    graduation_event,
  data = merged_df
)

acc_company_performance_acc_design_m4 <- lm(
  as.numeric(as.character(exit_of_1m)) ~
    external_stakeholders_investors +
    external_stakeholders_corporations +
    external_stakeholders_governments +
    external_stakeholders_academia +
    
    advisory_and_managing_directors_prior_investor +
    advisory_and_managing_directors_prior_entrepreneur +
    advisory_and_managing_directors_prior_corporate_exp +
    advisory_and_managing_directors_prior_university_exp +
    
    program_duration +
    funding_provided +
    equity_taken +
    cohort_size +
    cohort_composition +
    external_mentorship +
    co_working_space +
    educational_programming +
    graduation_event,
  data = merged_df
)

# ### End Accelerator Company Performance ~ Accelerator Design Choices ###


# ### Well Designed Accelerator ###

well_designed_df <- merged_df %>%
  filter(
    received_500k == 1,
    total_raised > mean(total_raised),
    max_valuation > mean(max_valuation, na.rm = TRUE),
    exit_of_1m == 1
  ) %>%
  arrange(desc(total_raised)) %>%
  select(
    external_stakeholders_investors,
    external_stakeholders_corporations,
    external_stakeholders_governments,
    external_stakeholders_academia,
    
    advisory_and_managing_directors_prior_investor,
    advisory_and_managing_directors_prior_entrepreneur,
    advisory_and_managing_directors_prior_corporate_exp,
    advisory_and_managing_directors_prior_university_exp,
    
    program_duration,
    funding_provided,
    equity_taken,
    cohort_size,
    cohort_composition,
    external_mentorship,
    co_working_space,
    educational_programming,
    graduation_event
  ) %>%
  mutate_if(
    is.factor, function(x) { as.numeric(as.character(x)) }
  )

ill_designed_df <- merged_df %>%
  filter(
    received_500k == 0,
    total_raised < mean(total_raised),
    max_valuation < mean(max_valuation, na.rm = TRUE),
    exit_of_1m == 0
  ) %>%
  arrange(total_raised) %>%
  select(
    external_stakeholders_investors,
    external_stakeholders_corporations,
    external_stakeholders_governments,
    external_stakeholders_academia,
    
    advisory_and_managing_directors_prior_investor,
    advisory_and_managing_directors_prior_entrepreneur,
    advisory_and_managing_directors_prior_corporate_exp,
    advisory_and_managing_directors_prior_university_exp,
    
    program_duration,
    funding_provided,
    equity_taken,
    cohort_size,
    cohort_composition,
    external_mentorship,
    co_working_space,
    educational_programming,
    graduation_event
  ) %>%
  mutate_if(
    is.factor, function(x) { as.numeric(as.character(x)) }
  )

ill_new <- data.frame(
  external_stakeholders_investors = as.factor(1),
  external_stakeholders_corporations = as.factor(1),
  external_stakeholders_governments = as.factor(0),
  external_stakeholders_academia = as.factor(0),
  
  advisory_and_managing_directors_prior_investor = as.factor(0),
  advisory_and_managing_directors_prior_entrepreneur = as.factor(1),
  advisory_and_managing_directors_prior_corporate_exp = as.factor(1),
  advisory_and_managing_directors_prior_university_exp = as.factor(0),
  
  program_duration = 18,
  funding_provided = 75000 / 1000,
  equity_taken = 7,
  cohort_size = 13,
  cohort_composition = as.factor(1),
  external_mentorship = as.factor(1),
  co_working_space = as.factor(1),
  educational_programming = as.factor(0),
  graduation_event = as.factor(1)
)

well_new <- data.frame(
  external_stakeholders_investors = as.factor(1),
  external_stakeholders_corporations = as.factor(1),
  external_stakeholders_governments = as.factor(1),
  external_stakeholders_academia = as.factor(0),
  
  advisory_and_managing_directors_prior_investor = as.factor(0),
  advisory_and_managing_directors_prior_entrepreneur = as.factor(1),
  advisory_and_managing_directors_prior_corporate_exp = as.factor(1),
  advisory_and_managing_directors_prior_university_exp = as.factor(0),
  
  program_duration = 57,
  funding_provided = 48000 / 1000,
  equity_taken = 2,
  cohort_size = 41,
  cohort_composition = as.factor(1),
  external_mentorship = as.factor(1),
  co_working_space = as.factor(1),
  educational_programming = as.factor(1),
  graduation_event = as.factor(1)
)

ill_well <- rbind(ill_new, well_new) %>%
  transpose() %>%
  `colnames<-`(c("Ill-Designed Accelerator", "Well-Designed Accelerator")) %>%
  `rownames<-`(acc_design_choices_complete_verbose_kable)

ill_predict_received_500k <- predict(acc_company_performance_acc_design_m1, ill_new, interval = "confidence")
ill_predict_total_raised <- predict(acc_company_performance_acc_design_m2, ill_new, interval = "confidence")
ill_predict_max_valuation <- predict(acc_company_performance_acc_design_m3, ill_new, interval = "confidence")
ill_predict_exit <- predict(acc_company_performance_acc_design_m4, ill_new, interval = "confidence")

well_predict_received_500k <- predict(acc_company_performance_acc_design_m1, well_new, interval = "confidence")
well_predict_total_raised <- predict(acc_company_performance_acc_design_m2, well_new, interval = "confidence")
well_predict_max_valuation <- predict(acc_company_performance_acc_design_m3, well_new, interval = "confidence")
well_predict_exit <- predict(acc_company_performance_acc_design_m4, well_new, interval = "confidence")

predict_t_test_500k <- t.test(well_predict_received_500k, ill_predict_received_500k, alternative = "greater")
predict_t_test_total_raised <- t.test(well_predict_total_raised, ill_predict_total_raised, alternative = "greater")
predict_t_test_max_valuation <- t.test(well_predict_max_valuation, ill_predict_max_valuation, alternative = "greater")
predict_t_test_exit <- t.test(well_predict_exit, ill_predict_exit, alternative = "greater")

# ### End Well Designed Accelerator ###
