## Basic instructions - please read before starting:

These notes should help you navigate the various tabs and inputs for the model. Additional help notes within each tab
provide extra information on certain elements.

### Home tab
This is where you choose from a default set of model parameters or to upload your own. If you choose 'custom' to upload
your own you will be directed to an excel file template which you will need to populate with your own data, parameters
and variables prior to loading.

### Parameters tab

The main control centre for the model, this will be pre-populated with the parameters and variables for the selection
from the Home tab or the details you have uploaded. You can then manually override information for population groups,
effect sizes, service flows and service behaviours. Note: it is best to apply any changes to all other boxes as you
change the population sub-group to keep track of your inputs as some options will change once you change the population 
group.

### Population groups

Cycle through the various risk populations and set the size of the population for each; an adjustment for
susceptibility/resilience (this is a pragmatic value included to try and mitigate risk of double-counting of populations 
and also accounting for unknown benefits of covid and lockdown on each group. This value is art not science); the
scenario to determine the nature of impacts over time. Unless you upload a parameter file you will have to repeat this 
for each population group.

#### Impacts on population groups

This will change for each population group you select in the previous box as determined by our early literature search.
Change the incidence/prevalence rates (%'s) for each potential impact condition. Please note, we have halved each of the 
published rates on the basis that on average people tend to present with around 2 co-morbid psychiatric issues but our 
model only address problems in a unitary way.

#### Referral/Service flows

This will change for each condition you select at the top of the box. Enter any values for the number of patients (with
the above condition) likely to end up in each service. It is easiest to think of a notional population of 100 or 1000
with that condition and apportion them accordingly. Unless you have uploaded your own service team names in a parameter
file, these will remain as the Service/Team types as per the MHSDS. 

#### Service variables

These options are the same regardless of which service you choose to change and determine the % of referrals that might
require treatment, the typical times spent in treatment, the likelihood of mental health 'recovery' and the typical 
contact volumes per patient per month. For fuller descriptions of these variables please see the help pop-up at bottom 
of the box.

After changing all or even some of your inputs, you may wish to save (by download button) all of the adjusted parameters 
so you can use them again in the future by direct upload. **IMPORTANT**: the parameters will all revert to the national
defaults if your browser timeouts (this is currently set at 15 minutes of inactivity); if you refresh your browser
window or if you go back to the Home tab and change to another pre-set version. You will lose all of your changes!

### Demand tab

This will be pre-populated with the selection from the Home tab or the details you have uploaded. You can overwrite the
data in the underlying tab with your actual referral volumes and/or some other prediction values. The suppressed
activity can also be over-written if local planning dictates a change. It will need to be updated by each service
manually or via the demand tab in the uploaded excel parameter file.

### Results tab

Here the model outputs for all the inputs you have set or changed will be presented. You can choose to cycle through and
review these on screen by each service line, export a basic pdf report of the selected or all services or you could
download a csv file of the full set of model results for use in your own analysis. The outputs show the summary changes
in referral and service demand, the (population) source of the surges and how the demands may vary over time.

### Surge Demand tabs

More detailed counts of the modelled surges for each of the population groups, conditions and services are shown here
respectively. Presented as tables and stacked bar charts for referrals and those likely to receive/need services at
current thresholds.
