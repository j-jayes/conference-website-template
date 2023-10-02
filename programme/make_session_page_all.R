# create_qmd_files.R

library(tidyverse)
library(dplyr)
library(glue)
library(here)
source(here("programme/make_session_page.R"))

papers <- read_rds(here("programme/papers_for_session_pages.rds"))
unique_sessions <- unique(papers$session_id)

for (session_id_in in unique_sessions) {
  session_name <- papers %>%
    filter(session_id == session_id_in) %>%
    distinct(session_name) %>%
    slice_head(n = 1) %>%
    pull()

  # Create a file name based on the session name
  file_name <- glue("session_{session_id_in}.qmd")
  file_name <- URLencode(file_name) # Replace spaces with underscores

  # Set the contents of the .qmd file
  file_contents <- glue('
---
title: "{session_name}"
format:
  html:
    toc: false
execute:
  echo: false
  message: false
  warning: false
# image: "{session_id_in}.jpg"
---

```{{r setup, include=FALSE}}
knitr::opts_chunk$set(echo = TRUE)
library(dplyr)
library(glue)
source(here::here("programme/make_session_page.R"))
papers <- readr::read_rds(here::here("programme/papers_for_session_pages.rds"))

```

```{{r, results="asis", echo = FALSE}}
make_session_page({session_id_in}, papers)

```

')

  writeLines(file_contents, con = here("sessions", file_name))
  message("Writing abstracts for ", session_id_in)
}

