# it returns data as expected

    Code
      download_output(model_output, params)
    Output
      # A tibble: 4,826 x 6
         date       type    group                          condition treatment value
         <date>     <chr>   <chr>                          <chr>     <chr>     <dbl>
       1 2020-05-01 at-risk Children & young people        <NA>      <NA>          0
       2 2020-05-01 at-risk Domestic abuse victims         <NA>      <NA>          0
       3 2020-05-01 at-risk Elderly alone                  <NA>      <NA>          0
       4 2020-05-01 at-risk Family of COVID deceased       <NA>      <NA>          0
       5 2020-05-01 at-risk Family of ICU survivors        <NA>      <NA>          0
       6 2020-05-01 at-risk General population             <NA>      <NA>          0
       7 2020-05-01 at-risk Health and care workers        <NA>      <NA>          0
       8 2020-05-01 at-risk ICU survivors                  <NA>      <NA>          0
       9 2020-05-01 at-risk Learning disabilities & autism <NA>      <NA>          0
      10 2020-05-01 at-risk Newly unemployed               <NA>      <NA>          0
      # ... with 4,816 more rows

