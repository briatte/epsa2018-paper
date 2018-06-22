# --- pkgs ---------------------------------------------------------------------

library(dplyr)  # loads: tibble
library(readr)
library(strict) # https://github.com/hadley/strict

# --- data ---------------------------------------------------------------------

d <- readr::read_csv("data/parlnet_edges.csv") %>% 
  #
  # subset to cosponsorship ties under stable or single-party governments
  #
  dplyr::filter(!is.na(g_i), !is.na(g_j)) %>% # n = 257,613
  #
  # remove ties from/to independent MPs (no ideological scores)
  #
  dplyr::filter(!is.infinite(lr_j), !is.infinite(lr_i)) %>% # n = 252,143
  #
  # panel characteristics
  #
  dplyr::mutate(
    #
    # panel id = country_chamber.PARTY
    #
    id = paste0(gsub("net_|\\d", "", network), ".", p_j),
    #
    # time period = start year of legislature
    #
    t = as.integer(gsub("\\D", "", network))
  ) %>%
  dplyr::select(id, t, everything(), -network)

# --- prepare panel covariates -------------------------------------------------

#
# grouping over (id, t, p_j)
#
#   - ( id  ) panel : country-chamber
#   - ( t   ) time  : start year of legislature
#   - ( p_j ) unit  : party-level (party)
#
# preserving existing country/chamber-level covariates:
#
#   - ( size     ) statutory size of legislature
#   - ( duration ) duration of legislature
#
# preserving existing party-level covariates:
#
#   - ( g_j  ) participation in government
#   - ( lr_j ) left-right ideological score
#
d <- dplyr::group_by(d, id, t, size, duration, p_j, g_j, lr_j) %>%
  #
  # measure party-level covariates of interest
  #
  dplyr::summarise(
    #
    # fractional responses:
    #   WAP: weighted fraction of cosponsorship ties across party lines
    #   WAG: weighted fraction of cosponsorship ties across gov/opp line
    #
    p_wap = sum(w[ p_i != p_j ]) / sum(w),
    p_wag = sum(w[ g_i != g_j ]) / sum(w),
    #
    # covariates:
    #
    #   total number of sponsors (first authors)
    n_j = dplyr::n_distinct(j),
    #
    #   fraction of senior sponsors
    p_sen = n_distinct(j[ ny_j > 0 ]) / n_j,
    #
    #   fraction of female sponsors
    p_fem = n_distinct(j[ gd_j == "F" ]) / n_j,
    #
    #   mean ideological distance of sponsors
    lr_ij_sd = sd(lr_i - lr_j)
  ) %>% 
  na.omit # n = 610 (617 complete j observations, -7 without lr_ij_sd scores)

# sanity checks on fractions
stopifnot(d$p_wap >= 0 & d$p_wap <= 1)
stopifnot(d$p_wag >= 0 & d$p_wag <= 1)
stopifnot(d$p_sen >= 0 & d$p_sen <= 1)
stopifnot(d$p_fem >= 0 & d$p_fem <= 1)

# -- (unbalanced) panel structure ----------------------------------------------

p <- group_by(d, id) %>%
  tally

nrow(p)    # n = 246 country-chamber-party observations
table(p$n) # observations per country-chamber-party in (1, 8)

# time structure
table(d$t) # min = 1986, max = 2015
table(d$duration) # in (1, 6) years

# --- data ---------------------------------------------------------------------

readr::write_csv(d, "data/parlnet_panel.csv")

nrow(d) # 610 parties

# ----------------------------------------------------- have a nice day --------

rm(list = ls())
gc()

# kthxbye
