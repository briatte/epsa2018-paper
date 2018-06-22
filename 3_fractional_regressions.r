# --- pkgs ---------------------------------------------------------------------

library(frm)    # https://home.iscte-iul.pt/~jjsro/FRM.htm
library(readr)
library(strict) # https://github.com/hadley/strict

d <- readr::read_csv("data/parlnet_panel.csv")

# covariates:
#   - time period (start year of legislature),
#   - duration (of legislature, in years),
#   - statutory size of parliamentary chamber,
#   - number of sponsors (proxy for party size),
#   - participation in government (party-level, 0 or 1)
#   - ideological score (party-level, 0-10 towards right-wing; time-invariant)
#   - fraction of senior MPs in party of sponsor (bounded 0-1)
#   - fraction of female MPs in party of sponsor (bounded 0-1)
#
#   NOTE -- The ideological score should not technically be time-invariant: it
#   was built by aggregating ParlGov that do not vary much throughout the time
#   period under observation, but that do vary still. This limitation makes it
#   impossible to specify 'pure' panel effects for the models, using the frmpd
#   package. [fmrpd]: https://cran.r-project.org/package=frmpd
#
X <- with(d, cbind(t, duration, size, n_j, g_j, lr_ij_sd, p_sen, p_fem))

# --- WAP ----------------------------------------------------------------------

# dependent variable:
#   weighted fraction of cosponsorship ties across PARTY lines
#
Y_WAP <- d$p_wap
length(Y_WAP)                #   N = 617
                             #   n (% N)
table(Y_WAP == 0)            #  70 (.11)
table(Y_WAP > 0 & Y_WAP < 1) # 512 (.83)
table(Y_WAP == 1)            #  35 (.55)

# fractional logit
WAP_flogit <- frm::frm(
  Y_WAP,
  X,
  type = "1P",
  linkfrac = "logit", 
  #
  # clustered standard errors at the country-chamber-party level
  var.type = "cluster",
  var.cluster = factor(d$id),
  intercept = FALSE # no-constant estimates
)

# frm::frm.pe(WAP_flogit) # average partial effects

# RESET tests

# frm::frm.reset(WAP_flogit, 2, version = c("Wald", "LM"))
# frm::frm.reset(WAP_flogit, 3, version = c("Wald", "LM"))
# frm::frm.reset(WAP_flogit, 4, version = c("Wald", "LM"))

# fractional probit
WAP_fprobit <- frm::frm(
  Y_WAP,
  X,
  type = "1P",
  linkfrac = "probit", 
  #
  # clustered standard errors at the country-chamber-party level
  var.type = "cluster",
  var.cluster = factor(d$id),
  intercept = FALSE # no-constant estimates
)

# frm::frm.pe(WAP_fprobit) # average partial effects

# RESET tests

# frm::frm.reset(WAP_fprobit, 2, version = c("Wald", "LM"))
# frm::frm.reset(WAP_fprobit, 3, version = c("Wald", "LM"))
# frm::frm.reset(WAP_fprobit, 4, version = c("Wald", "LM"))

# --- WAG ----------------------------------------------------------------------

# dependent variable:
#   weighted fraction of cosponsorship ties across GOVERNMENT lines
#
Y_WAG <- d$p_wag
length(Y_WAG)                #   N = 617
                             #   n (% N)
table(Y_WAG == 0)            # 151 (.24)
table(Y_WAG > 0 & Y_WAG < 1) # 460 (.74)
table(Y_WAG == 1)            #   6 (.01)

# fractional logit
WAG_flogit <- frm::frm(
  Y_WAG,
  X,
  type = "1P",
  linkfrac = "logit", 
  #
  # clustered standard errors at the country-chamber-party level
  var.type = "cluster",
  var.cluster = factor(d$id),
  intercept = FALSE # no-constant estimates
)

# frm::frm.pe(WAG_flogit) # average partial effects

# RESET tests

# frm::frm.reset(WAG_flogit, 2, version = c("Wald", "LM"))
# frm::frm.reset(WAG_flogit, 3, version = c("Wald", "LM"))
# frm::frm.reset(WAG_flogit, 4, version = c("Wald", "LM"))

# fractional probit
WAG_fprobit <- frm::frm(
  Y_WAG,
  X,
  type = "1P",
  linkfrac = "probit", 
  #
  # clustered standard errors at the country-chamber-party level
  var.type = "cluster",
  var.cluster = factor(d$id),
  intercept = FALSE # no-constant estimates
)

# frm::frm.pe(WAG_fprobit) # average partial effects

# RESET tests

# frm::frm.reset(WAG_fprobit, 2, version = c("Wald", "LM"))
# frm::frm.reset(WAG_fprobit, 3, version = c("Wald", "LM"))
# frm::frm.reset(WAG_fprobit, 4, version = c("Wald", "LM"))

# --- P-tests ------------------------------------------------------------------

# frm::frm.ptest(WAP_flogit, WAP_fprobit, version = c("Wald", "LM"))
# frm::frm.ptest(WAG_flogit, WAG_fprobit, version = c("Wald", "LM"))

# --- Residual standard errors -------------------------------------------------

round(sd(Y_WAP - WAP_flogit$yhat), 2)
round(sd(Y_WAG - WAG_flogit$yhat), 2)

# --- save ---------------------------------------------------------------------

save(list = ls(pattern = "WA?_*"), file = "data/parlnet_frm.rda")

# ----------------------------------------------------- have a nice day --------

# rm(list = ls())
# gc()

# kthxbye
