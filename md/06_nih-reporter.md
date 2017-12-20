The data of grants were acquired from the [NIH RePORTER website](https://projectreporter.nih.gov/reporter.cfm) using a custom R script (in the code folder in our [GitHub repo](https://github.com/adv-datasci/scholar)) and the [`fedreporter` R package](https://cran.r-project.org/web/packages/fedreporter/index.html) created by John Muschelli.

The data were obtained in the form of nested list of lists and were processed into an R data frames with the `purrr` and `data.table` packages.

This dataframe was then merged with the [JHSPH faculty website](https://www.jhsph.edu/faculty/directory/list/) data, described in the `JHSPH Faculty` tab, using a `dplyr` join function.

The final combined dataframe, named `course_grant_df.rds` is available in the top level of our [GitHub repo](https://github.com/adv-datasci/scholar).
