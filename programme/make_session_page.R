library(dplyr)
library(glue)

make_session_page <- function(session_id_in, papers) {

  papers_for_session <- papers %>%
    filter(session_id == session_id_in)

  session_name_out <- papers_for_session %>%
    distinct(session_name) %>%
    slice_head(n = 1) %>%
    pull()

  organizer_out <- papers_for_session %>%
    distinct(organizer) %>%
    slice_head(n = 1) %>%
    pull()

  to_print <- papers_for_session %>%
    select(room, slot, title, authors_name, coauthors, abstract) %>%
    mutate(paper_info = glue('### {title}\n\n**Session:** {slot}\n\n**Authors:** {authors_name}\n\n**Co-authors:** {coauthors}\n\n**Abstract:** {abstract}\n<br>'))

  # Return formatted markdown text
  cat("\n**Session organizer/s:**", organizer_out, "\n\n")

  cat(to_print %>%
        pull(paper_info) %>%
        paste(collapse = '\n\n'))


}


