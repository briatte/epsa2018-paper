# --- pkgs ---------------------------------------------------------------------

library(dplyr)   # loads: tibble
library(ggplot2)
library(strict)  # https://github.com/hadley/strict

# --- data ---------------------------------------------------------------------

load("data/parlnet_frm.rda")

# --- extract coefficients from frm objects ------------------------------------

get_frm_betas <- function(frm_object, digits = 3) {
  
  require(dplyr)
  require(tibble)
  
  # next lines adapted from frm package, by Joaquim J.S. Ramalho
  # https://github.com/cran/frm/blob/master/R/frm.R
  #
  p.sd <- base::diag(frm_object$p.var)^0.5 # note: avoiding strict::strict_diag
  z.ratio <- frm_object$p / p.sd
  p.sig <- 2 * (1 - pnorm(abs(z.ratio)))
  
  # next lines inspired by broom package, by David Robinson et al.
  # https://github.com/tidyverse/broom
  # 
  tibble::data_frame(
    term = frm_object$x.names ,
    b    = frm_object$p       , # estimate
    or   = NA_real_           , # odds ratios (logit only)
    se   = p.sd               , # std.error
    t    = z.ratio            , # statistic
    p    = p.sig              , # p.value
    link = frm_object$link
  ) %>% 
    dplyr::mutate(or = dplyr::if_else(link == "logit", exp(b), or)) %>% 
    dplyr::mutate_if(is.numeric, round, digits = digits)
  
}

# run over the four model objects
#
d <- dplyr::bind_rows(
  tibble::add_column( get_frm_betas( WAG_flogit  ) , DV = "WAG" ),
  tibble::add_column( get_frm_betas( WAG_fprobit ) , DV = "WAG" ),
  tibble::add_column( get_frm_betas( WAP_flogit  ) , DV = "WAP" ),
  tibble::add_column( get_frm_betas( WAP_fprobit ) , DV = "WAP" )
)

# --- legend variables and plot ------------------------------------------------

# names for Y terms
#
y_names <- c(
  "WAP" = "Cosponsorship beyond own party",
  "WAG" = "Cosponsorship beyond own coalition"
)

# names for X terms
#
x_names <- c(
  "t"        = "(Legislature) start year"   ,
  "duration" = "(Legislature) duration"     ,
  "size"     = "(Chamber) statutory size"   ,
  "p_sen"    = "(Party) % senior sponsors"  ,
  "p_fem"    = "(Party) % female sponsors"  ,
  "n_j"      = "(Party) number of sponsors" ,
  "g_j"      = "(Party) is in government"   ,
  "lr_ij_sd" = "(Sponsors) ideological dispersion"
)

# rename link functions
#
d$link <- paste("Fractional", d$link)

# --- extract coefficients from frm objects ------------------------------------

# d <- d[ -which(d$term == "INTERCEPT"), ]
ggplot(
  mutate(d, DV = factor(y_names[ DV ], levels = y_names)),
  aes(x_names[ term ], b, color = link)
) +
  geom_hline(yintercept = 0, color = "grey50", lty = "dotted") +
  geom_pointrange(
    position = position_dodge(width = 0.5),
    aes(ymin = b - 1.96 * se, ymax = b + 1.96 * se),
    fatten = 2.5
  ) +
  scale_color_brewer("Coefficients ± 1.96 (clustered) standard errors", palette = "Set2") +
  facet_wrap(~ DV) +
  coord_flip() +
  labs(x = NULL, y = NULL) +
  theme_bw(base_size = 12) +
  theme(
    #axis.title.x = element_text(size = 10, margin = margin(t = 10)),
    #axis.text = element_text(size = 10, color = "black"),
    axis.ticks.y = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    strip.background = element_rect(fill = "grey90"),
    legend.position = "bottom",
    legend.title = element_text(size = 10, color = "black")
  )

# --- save ---------------------------------------------------------------------

ggsave("plots/parlnet_frm_betas.pdf", width = 9, height = 5)
ggsave("plots/parlnet_frm_betas.png", width = 9, height = 5)

# ----------------------------------------------------- have a nice day --------

rm(list = ls())
gc()

# kthxbye
