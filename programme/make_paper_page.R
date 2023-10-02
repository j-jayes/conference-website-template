library(tidyverse)
library(readxl)


# Load the lookup table from Excel
lookup_df <- read_excel(here::here("programme", "pdf-lookup.xlsx"))

# Specify the source and destination directories for the PDFs
source_dir <- here::here("abstracts/")
dest_dir <- here::here("papers_post/")

# Create destination folder if it doesn't exist
if (!dir.exists(dest_dir)) {
  dir.create(dest_dir)
}

# Loop through the lookup table and copy-rename each PDF
for (i in 1:nrow(lookup_df)) {
  # Original filename
  orig_file <- paste0(source_dir, "/", lookup_df$url_stub[i], ".qmd")
  orig_file_pdf <- paste0(source_dir, "/", lookup_df$url_stub[i], ".pdf")


  # New filename based on URL stub
  new_file <- paste0(dest_dir,"/", lookup_df$url_stub[i], ".qmd")
  new_file_pdf <- paste0(dest_dir,"/", lookup_df$url_stub[i], ".pdf")

  # Check if the original file exists
  if (file.exists(orig_file)) {
    # Copy and rename the file
    file.copy(orig_file, new_file)
    file.copy(orig_file_pdf, new_file_pdf)
  } else {
    cat("File does not exist:", orig_file, "\n")
  }
}
