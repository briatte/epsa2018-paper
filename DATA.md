The `parlnet.csv` and `parlnet.rda` files are taken from the [parlnet][parlnet] 
project as of June 2018. Please refer to the [parlnet appendix][parlnet-appndx] 
for detailed construction notes.

[parlnet]: https://github.com/briatte/parlnet
[parlnet-appndx]: https://f.briatte.org/research/parlnet-appendix.pdf

The other data files produced by this project are documented below.

# `parlnet_edges.csv`

Running `1_extract_cosponsorships.r` produces the following CSV dataset:

- `network`  -- `parlnet` ID for the cosponsorship network
- `i`  -- (country/chamber-specific) numeric ID of the cosponsor
- `j`  -- (country/chamber-specific) numeric ID of the sponsor/first author
- `w`  -- raw number of cosponsorships from cosponsor `i` to first author `j`
- `p_i`  -- party affiliation of `i`
- `p_j`  -- party affiliation of `j`
- `lr_i`  -- left/right ideological score of `i` (party-level, time-invariant)
- `lr_j`  -- left/right ideological score of `j` (party-level, time-invariant)
- `ny_i`  -- seniority of `i` (in years)
- `ny_j`  -- seniority of `j` (in years)
- `gd_i`  -- gender of `i` ("M" or "F")
- `gd_j`  -- gender of `j` ("M" or "F")
- `g_i`  -- whether `i` participates in a government coalition
- `g_j`  -- whether `j` participates in a government coalition

See the [parlnet-appendix][parlnet-appendix] paper for measurement details.

[parlnet-appendix]: /

# `parlnet_panel.csv`

Running `2_create_unbalanced_panel.r` produces the following CSV dataset:
 
- `id`     -- panel ID (`country_chamber.party`)
- `t`      -- time period (start year of the legislature)
- `p_j`    -- party
- `g_j`    -- whether party participates in a government coalition 
- `lr_j`   -- left/right ideological score of party (time-invariant)
- `lr_ij_sd` -- mean ideological distance between sponsor and cosponsor parties
- `p_wap`  -- fraction of cosponsorships across (i.e. from other) parties
- `p_wag`  -- fraction of cosponsorships across coalition
- `n_j`    -- number of sponsors in party
- `p_sen`  -- fraction of senior party members (see note)
- `p_fem`  -- fraction of female party members

Note -- senior party members are those who were in office for 1+ year(s) when
the legislature started.

# `parlnet_frm.rda`

Running `3_fractional_regressions.r` produces a serialised R data file that 
contains fractional regression models of class `frm`, as provided by the 
[`frm`][frm] package.

[frm]: https://cran.r-project.org/package=frm

See Joaquim J.S. Ramalho's "[Fractional Regression Models][jjsro]" page for 
code and papers.

[jjsro]: http://home.iscte-iul.pt/~jjsro/FRM.htm
