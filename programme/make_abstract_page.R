# create_qmd_files.R

library(tidyverse)
library(dplyr)
library(glue)
library(here)
library(readxl)

# Load the lookup table from Excel
lookup_df <- read_excel(here::here("programme", "pdf-lookup.xlsx"))

# Specify the source and destination directories for the PDFs
source_dir <- here::here("papers/")
dest_dir <- here::here("abstracts/")

# Create destination folder if it doesn't exist
if (!dir.exists(dest_dir)) {
  dir.create(dest_dir)
}

# Loop through the lookup table and copy-rename each PDF
for (i in 1:nrow(lookup_df)) {
  # Original filename
  orig_file <- paste0(source_dir, "/", lookup_df$pdf_filename[i])

  # New filename based on URL stub
  new_file <- paste0(dest_dir,"/", lookup_df$url_stub[i], ".pdf")

  # Check if the original file exists
  if (file.exists(orig_file)) {
    # Copy and rename the file
    file.copy(orig_file, new_file)
  } else {
    cat("File does not exist:", orig_file, "\n")
  }
}

# Print message to indicate script completion
cat("PDF files have been copied and renamed.\n")

papers <- readxl::read_excel(here::here("programme/SEHM23_Schedule_5_September.xlsx"), sheet = 1) %>%
  janitor::clean_names()

# url encode for paper

papers <- papers %>%
  mutate(url = str_c(authors_name, "_", title),
         url = str_replace_all(url, " ", "_"),
         url = str_remove_all(url, "[^\\w\\s]"),
         url = str_to_lower(url),
         url = stringi::stri_trans_general(url, "Latin-ASCII"),
         url = URLencode(str_sub(url, start = 1, end = 50)),
         url_stub = url,
         url = str_c("https://sehm2023.com/abstracts/", url))

venues <- tibble(venue_name = c(
  "Gustafscenen",
  "Källarsalen",
  "Lilla salen",
  "Nya Fest",
  "Sångsalen",
  "Lilla Sparbanksfoajén",
  "Kerstins Rum"
)) %>% mutate(room = row_number())

papers <- papers %>%
  inner_join(venues)

paper_refs <- readxl::read_excel(here("programme", "pdf-lookup.xlsx"))
unique_papers <- unique(papers$url_stub)
dest_dir <- here("abstracts") # Define your destination directory here


# Define the function to check for PDF existence
check_pdf_exists <- function(url_stub_in, lookup_df, dest_dir) {
  matching_row <- which(lookup_df$url_stub == url_stub_in)
  if (length(matching_row) == 0) {
    return("no pdf")
  }
  expected_pdf_name <- paste0(lookup_df$url_stub[matching_row], ".pdf")
  expected_pdf_path <- paste0(dest_dir, "/", expected_pdf_name)
  if (file.exists(expected_pdf_path)) {
    return(expected_pdf_name)
  } else {
    return("no pdf")
  }
}


for (paper_url_in in unique_papers) {
  paper_title <- papers %>%
    filter(url_stub == paper_url_in) %>%
    mutate(title = str_replace_all(title, '"', "'")) %>%
    pull(title)

  paper_author <- papers %>%
    filter(url_stub == paper_url_in) %>%
    mutate(multi_authors = case_when(
      is.na(coauthors) ~ authors_name,
      TRUE ~ str_c(authors_name, ", ", coauthors)
    )) %>%
    pull(multi_authors)

  paper_abstract <- papers %>%
    filter(url_stub == paper_url_in) %>%
    mutate(abstract = str_replace_all(abstract, '"', "'")) %>%
    pull(abstract)

  paper_subtitle <- papers %>%
    filter(url_stub == paper_url_in) %>%
    mutate(subtitle = glue::glue("{venue_name} Session {slot}: {session_name} organized by {organizer}")) %>%
    pull(subtitle)

  pdf_status <- check_pdf_exists(paper_url_in, paper_refs, dest_dir)
  pdf_section <- ifelse(pdf_status == "no pdf", "No PDF available.", paste0("{{< pdf ", pdf_status, " width=100% height=800 >}}"))

  # Create a file name based on the session name
  file_name <- glue("{paper_url_in}.qmd")
  file_name <- URLencode(file_name) # Replace spaces with underscores

  # Set the contents of the .qmd file
  file_contents <- glue('
---
title: "{paper_title}"
author: "{paper_author}"
subtitle: "{paper_subtitle}"
format:
  html:
    toc: false
execute:
  echo: false
  message: false
  warning: false
# image: "{paper_url_in}.jpg"
---

## Abstract

{paper_abstract}

## PDF

{pdf_section}

')

  writeLines(file_contents, con = here("abstracts", file_name))
  message("Writing abstracts for ", paper_url_in)
}

