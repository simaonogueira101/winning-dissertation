stargazer_t_test = function (data, title, label, table_output, table_font_size) {
  summary = data.frame(
    `t` = data$statistic,
    `df` = data$parameter,
    `p-value` = data$p.value,
    `alternative hypothesis` = paste0("true difference in means is ", data$alternative, " than 0"),
    check.names = FALSE
  )
  
  stargazer(
    summary,
    flip = TRUE,
    notes = paste0("\\textit{Note:} ", data$method),
    summary = FALSE,
    type = table_output,
    title = title,
    header = FALSE,
    single.row = TRUE,
    font.size = table_font_size,
    column.sep.width = "1pt",
    no.space = TRUE,
    covariate.labels = c("T-Test", "Values"),
    label = paste0("tab:", label),
    table.placement = 'H'
  )
}
