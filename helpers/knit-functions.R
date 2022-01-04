knit_thesis <- function(input, output_format = "pdf", ...){
  if ("pdf" %in% output_format){
    bookdown::render_book(input, output_format = "bookdown::pdf_document2")
    
    file.remove(list.files(pattern = "*\\.(log|mtc\\d*|maf|aux|bcf|lof|lot|out|toc)$"))
  }
  
  if ("bs4" %in% output_format){
    bookdown::render_book(input, output_format = "bookdown::bs4_book")
    
    # create a .nojekyll file which is needed to deploy on GitHub
    file.create(here::here("docs", ".nojekyll"))
  }
  
  # remove the _bookdown_files folder after the build
  unlink("_bookdown_files", recursive = TRUE)
}