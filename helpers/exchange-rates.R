currencyConversion <- function(amount, from, to){
  rate_symbol <- paste0(from, to, "=X")
  rate <- getQuote(rate_symbol) %>% select(rate = Last)
  rate_value <- rate[rate_symbol,]
  value <- amount * rate_value
  return(value)
}
