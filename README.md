Replication material for "Searching for the Cartel Party: Inter-Party Collusion and Legislative Activity" as presented at [EPSA 2018][epsa2018].

[epsa2018]: http://www.epsanet.org/conference-2018/

The code turns [legislative cosponsorship data][parlnet] into a panel dataset of political parties nested into country-specific parliamentary chambers. Some parties are observed at several points throughout the period under examination. Some aspects of the panel data related to party-specific cosponsorship behaviour are then modelled via (one-part) [fractional response regression models][frm].

[parlnet]: https://github.com/briatte/parlnet
[frm]: https://home.iscte-iul.pt/~jjsro/FRM.htm

# Read

The working paper is [included in the repository](paper.pdf).

# Data

Details on the data can be found in [DATA.md](DATA.md).

# Code

Written in [R][r] 3.3.3 in [`strict`][strict] mode.

[r]: https://cran.r-project.org/
[strict]: https://github.com/hadley/strict

# Make

```r
source("1_extract_cosponsorships.r")  # get the data
source("2_create_unbalanced_panel.r") # panelize it
source("3_fractional_regressions.r")  # estimate FRMs
source("4_export_and_plot_models.r")  # plot results

# session info
sink("session_info.log")
devtools::session_info()
sink()
```

Package dependencies are listed at the top of each script.

> Last updated: June 2018.
