# --- pkgs ---------------------------------------------------------------------

library(dplyr)   # loads: tibble
library(network)
library(purrr)
library(readr)
library(strict) # https://github.com/hadley/strict

# --- data ---------------------------------------------------------------------

# both datasets used below were imported from parlnet
# https://github.com/briatte/parlnet

# bill cosponsorships
load("data/parlnet.rda")

# party coalitions
g <- readr::read_csv("data/parlnet.csv") %>%
  select(size, duration, network, government, coalition)

d <- tibble::data_frame() # initialize master data frame

# --- extract edgelists and (co)sponsor attributes -----------------------------

# extract from all networks but Austria
for (i in ls()[ grepl("^net", ls()) & !grepl("net_at", ls()) ]) {
  
  n <- get(i)
  
  # sanity check: vertex names and edgelist names are identically ordered
  stopifnot(
    network::network.vertex.names(n) == attr(network::as.edgelist(n), "vnames")
  )
  
  # extract directed edgelist from (i = cosponsor) to (j = first author)
  # weight w = raw number of cosponsorships from i to j
  e <- network::as.edgelist(n, attrname = "raw", directed = TRUE) %>% 
    tibble::as_data_frame() %>% 
    setNames(c("i", "j", "w"))
  
  # party
  e$p_i <- network::get.vertex.attribute(n, "party")[ e$i ]
  e$p_j <- network::get.vertex.attribute(n, "party")[ e$j ]

  # left-right ideology (party-level)
  e$lr_i <- network::get.vertex.attribute(n, "lr")[ e$i ]
  e$lr_j <- network::get.vertex.attribute(n, "lr")[ e$j ]
  
  # seniority
  e$ny_i <- network::get.vertex.attribute(n, "nyears")[ e$i ]
  e$ny_j <- network::get.vertex.attribute(n, "nyears")[ e$j ]

  # gender
  e$gd_i <- network::get.vertex.attribute(n, "sex")[ e$i ]
  e$gd_j <- network::get.vertex.attribute(n, "sex")[ e$j ]
  
  # add to master data frame
  d <- rbind(d, tibble::add_column(e, network = i, .before = "i"))
  
}

# --- add coalition membership of both sponsors --------------------------------

# sanity check: all networks covered
stopifnot(d$network %in% g$network)

d <- left_join(d, g, by = "network")

# whether (co)sponsors are in government (1) or opposition (0)
in_government <- function(x, y) {
  x %in% unlist(strsplit(y, ";"))
}

d$g_i <- purrr::map2_lgl(d$p_i, d$coalition, in_government)
d$g_j <- purrr::map2_lgl(d$p_j, d$coalition, in_government)

# remove dummy when there is no coalition, i.e. when government == "mixed"
d$g_i <- dplyr::if_else(is.na(d$coalition), NA_integer_, as.integer(d$g_i))
d$g_j <- dplyr::if_else(is.na(d$coalition), NA_integer_, as.integer(d$g_j))

# --- save ---------------------------------------------------------------------

# save CSV dataset
readr::write_csv(select(d, -government, -coalition), "data/parlnet_edges.csv")

nrow(d) # 491,749 edges

# ----------------------------------------------------- have a nice day --------

rm(list = ls())
gc()

# kthxbye
