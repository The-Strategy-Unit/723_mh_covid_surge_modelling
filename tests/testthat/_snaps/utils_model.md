# the model returns expected values

    Code
      run_model(params, 1)
    Output
      # A tibble: 63,828 x 6
          time type        group                          condition treatment value
         <dbl> <chr>       <chr>                          <chr>     <chr>     <dbl>
       1     0 no-mh-needs <NA>                           <NA>      <NA>          0
       2     0 at-risk     Children & young people        <NA>      <NA>          0
       3     0 at-risk     Domestic abuse victims         <NA>      <NA>          0
       4     0 at-risk     Elderly alone                  <NA>      <NA>          0
       5     0 at-risk     Family of COVID deceased       <NA>      <NA>          0
       6     0 at-risk     Family of ICU survivors        <NA>      <NA>          0
       7     0 at-risk     General population             <NA>      <NA>          0
       8     0 at-risk     Health and care workers        <NA>      <NA>          0
       9     0 at-risk     ICU survivors                  <NA>      <NA>          0
      10     0 at-risk     Learning disabilities & autism <NA>      <NA>          0
      # ... with 63,818 more rows

