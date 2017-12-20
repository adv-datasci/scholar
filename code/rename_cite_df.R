
load(here("data/gcite.RData"))

cite_names <- readr::read_csv(here("lastnamefirstname.csv"))

names(l) <- cite_names$names

readr::write_rds(x = l, path = here("data/cite_df_list.rds"), compress = "none")
