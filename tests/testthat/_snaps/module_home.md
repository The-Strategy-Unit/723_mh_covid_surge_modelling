# it generates the UI correctly

    Code
      ui
    Output
      <a href="https://www.strategyunitwm.nhs.uk/">
        <img src="https://www.strategyunitwm.nhs.uk/themes/custom/ie_bootstrap/logo.svg" title="The Strategy Unit" alt="The Strategy Unit Logo" align="right" height="80"/>
      </a>
      <h1>Mental Health Surge Modelling</h1>
      <p>
        This is a system dynamic simulation of the potential impacts of covid-19 on mental health services in England.
        The model was developed and designed initially with and for staff at Mersey Care NHS Foundation Trust and
        subsequently as part of the
        <a href="https://www.strategyunitwm.nhs.uk/covid19-and-coronavirus">national analytical Collaboration for Covid-19</a>
        .
      </p>
      <p>
        The application applies evidence-based effects to segmented populations, then maps the flows of referrals and
        service use to a basket of likely service destinations.
      </p>
      <p>
        The tool can support areas to estimate effects for their own population and services by either adapting the
        default data and parameters (e.g. England) or uploading their own to run within the model.
      </p>
      <div class="col-sm-12">
        <div class="box box-solid box-primary">
          <div class="box-header">
            <h3 class="box-title">Select parameters</h3>
          </div>
          <div class="box-body">
            <div class="form-group shiny-input-container">
              <label class="control-label" for="a-params_select">Default Parameters</label>
              <div>
                <select id="a-params_select"><option value="params_a.xlsx" selected>params_a.xlsx</option>
      <option value="params_b.xlsx">params_b.xlsx</option>
      <option value="params_c.xlsx">params_c.xlsx</option>
      <option value="custom">Custom</option></select>
                <script type="application/json" data-for="a-params_select" data-nonempty="">{}</script>
              </div>
            </div>
            <div class="form-group shiny-input-container shinyjs-hide">
              <label class="control-label shiny-label-null" for="a-user_upload_xlsx"></label>
              <div class="input-group">
                <label class="input-group-btn input-group-prepend">
                  <span class="btn btn-default btn-file">
                    Browse...
                    <input id="a-user_upload_xlsx" name="a-user_upload_xlsx" type="file" style="display: none;" accept=".xlsx"/>
                  </span>
                </label>
                <input type="text" class="form-control" placeholder="Previously downloaded parameters" readonly="readonly"/>
              </div>
              <div id="a-user_upload_xlsx_progress" class="progress active shiny-file-input-progress">
                <div class="progress-bar"></div>
              </div>
            </div>
            <div class="shiny-html-output shinyjs-hide" id="a-user_upload_xlsx_msg"></div>
          </div>
        </div>
      </div>
      <h2>Basic instructions - please read before starting:</h2>
      <p>
        These notes should help you navigate the various tabs and inputs for the model. Additional help notes within
        each tab provide extra information on certain elements.
      </p>
      <h3>Home tab</h3>
      <p>
        This is where you choose from a default set of model parameters or to upload your own. If you choose 'custom'
        to upload your own you will be directed to an excel file template which you will need to populate with your
        own data, parameters and variables prior to loading.
      </p>
      <h3>Parameters tab</h3>
      <p>
        The main control centre for the model, this will be pre-populated with the parameters and variables for the
        selection from the Home tab or the details you have uploaded. You can then manually override information for
        population groups, effect sizes, service flows and service behaviours. Note: it is best to apply any changes to
        all other boxes as you change the population sub-group to keep track of your inputs as some options will
        change once you change the population group.
      </p>
      <h3>Population groups</h3>
      <p>
        Cycle through the various risk populations and set the size of the population for each; an adjustment for
        susceptibility/resilience (this is a pragmatic value included to try and mitigate risk of double-counting of
        populations and also accounting for unknown benefits of covid and lockdown on each group. This value is art not
        science); the scenario to determine the nature of impacts over time. Unless you upload a parameter file you
        will have to repeat this for each population group.
      </p>
      <h4>Impacts on population groups</h4>
      <p>
        This will change for each population group you select in the previous box as determined by our early
        literature search. Change the incidence/prevalence rates (%'s) for each potential impact condition. Please
        note, we have halved each of the published rates on the basis that on average people tend to present with
        around 2 co-morbid psychiatric issues but our model only address problems in a unitary way.
      </p>
      <h4>Referral/Service flows</h4>
      <p>
        This will change for each condition you select at the top of the box. Enter any values for the number of
        patients (with the above condition) likely to end up in each service. It is easiest to think of a notional
        population of 100 or 1000 with that condition and apportion them accordingly. Unless you have uploaded your
        own service team names in a parameter file, these will remain as the Service/Team types as per the MHSDS.
      </p>
      <h4>Service variables</h4>
      <p>
        These options are the same regardless of which service you choose to change and determine the % of referrals
        that might require treatment, the typical times spent in treatment, the likelihood of mental health 'recovery'
        and the typical contact volumes per patient per month. For fuller descriptions of these variables please see
        the help pop-up at bottom of the box.
      </p>
      <p>
        After changing all or even some of your inputs, you may wish to save (by download button) all of the adjusted
        parameters so you can use them again in the future by direct upload.
        <strong>IMPORTANT: </strong>
        the parameters will all revert to the national defaults if your browser timeouts (this is currently set at 15
        minutes of inactivity); if you refresh your browser window or if you go back to the Home tab and change to
        another pre-set version. You will lose all of your changes!
      </p>
      <h3>Demand tab</h3>
      <p>
        This will be pre-populated with the selection from the Home tab or the details you have uploaded. You can
        overwrite the data in the underlying tab with your actual referral volumes and/or some other prediction
        values. The suppressed activity can also be over-written if local planning dictates a change. It will need to
        be updated by each service manually or via the demand tab in the uploaded excel parameter file.
      </p>
      <h3>Results tab</h3>
      <p>
        Here the model outputs for all the inputs you have set or changed will be presented. You can choose to cycle
        through and review these on screen by each service line, export a basic pdf report of the selected or all
        services or you could download a csv file of the full set of model results for use in your own analysis. The
        outputs show the summary changes in referral and service demand, the (population) source of the surges and how
        the demands may vary over time.
      </p>
      <h3>Surge Demand tabs</h3>
      <p>
        More detailed counts of the modelled surges for each of the population groups, conditions and services are
        shown here respectively. Presented as tables and stacked bar charts for referrals and those likely to
        receive/need services at current thresholds.
      </p>

