# it creats the UI correctly

    Code
      ui
    Output
      <div class="row">
        <div class="col-sm-2">
          <div class="col-sm-12">
            <div class="box box-solid box-primary">
              <div class="box-header">
                <h3 class="box-title">Population Groups</h3>
              </div>
              <div class="box-body">
                <div class="form-group shiny-input-container">
                  <label class="control-label" for="a-popn_subgroup">Choose subgroup</label>
                  <div>
                    <select id="a-popn_subgroup"></select>
                    <script type="application/json" data-for="a-popn_subgroup" data-nonempty="">{}</script>
                  </div>
                </div>
                <div class="form-group shiny-input-container">
                  <label class="control-label" for="a-subpopulation_size">Subpopulation Figure</label>
                  <input id="a-subpopulation_size" type="number" class="form-control" step="100"/>
                </div>
                <div class="form-group shiny-input-container">
                  <label class="control-label" for="a-subpopulation_pcnt">Susceptibility and Resilience adjustment (see help notes)</label>
                  <input class="js-range-slider" id="a-subpopulation_pcnt" data-min="0" data-max="100" data-from="100" data-step="1" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-postfix="%" data-keyboard="true" data-data-type="number"/>
                </div>
                <div id="a-subpopulation_size_pcnt" class="shiny-text-output"></div>
                <div class="form-group shiny-input-container">
                  <label class="control-label" for="a-subpopulation_curve">Choose scenario</label>
                  <div>
                    <select id="a-subpopulation_curve"></select>
                    <script type="application/json" data-for="a-subpopulation_curve" data-nonempty="">{}</script>
                  </div>
                </div>
                <div id="a-subpopulation_curve_plot" style="width:100%; height:100px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
                <a id="a-population_group_help" href="#" class="action-button">
                  <i class="fa fa-question"></i>
                  
                </a>
              </div>
            </div>
          </div>
        </div>
        <div class="col-sm-3">
          <div class="col-sm-12">
            <div class="box box-solid box-primary">
              <div class="box-header">
                <h3 class="box-title">Impacts on population sub-group</h3>
              </div>
              <div class="box-body">
                <a id="a-group_to_cond_params_help" href="#" class="action-button">
                  <i class="fa fa-question"></i>
                  
                </a>
              </div>
            </div>
          </div>
        </div>
        <div class="col-sm-4">
          <div class="col-sm-12">
            <div class="box box-solid box-primary">
              <div class="box-header">
                <h3 class="box-title">Referral/Service flows for impacts</h3>
              </div>
              <div class="box-body">
                <a id="a-cond_to_treat_params_help" href="#" class="action-button">
                  <i class="fa fa-question"></i>
                  
                </a>
              </div>
            </div>
          </div>
        </div>
        <div class="col-sm-3">
          <div class="col-sm-12">
            <div class="box box-solid box-primary">
              <div class="box-header">
                <h3 class="box-title">Service variables</h3>
              </div>
              <div class="box-body">
                <div class="form-group shiny-input-container">
                  <label class="control-label" for="a-treatment_type">Treatment type</label>
                  <div>
                    <select id="a-treatment_type"></select>
                    <script type="application/json" data-for="a-treatment_type" data-nonempty="">{}</script>
                  </div>
                </div>
                <div class="form-group shiny-input-container">
                  <label class="control-label" for="a-slider_treat_pcnt">Referrals typically receiving a service</label>
                  <input class="js-range-slider" id="a-slider_treat_pcnt" data-min="0" data-max="100" data-from="0" data-step="0.01" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-postfix="%" data-keyboard="true" data-data-type="number"/>
                </div>
                <div class="form-group shiny-input-container">
                  <label class="control-label" for="a-slider_tx_months">Months in service (a)</label>
                  <input class="js-range-slider" id="a-slider_tx_months" data-min="0" data-max="24" data-from="1" data-step="0.1" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-keyboard="true" data-data-type="number"/>
                </div>
                <div class="form-group shiny-input-container">
                  <label class="control-label" for="a-slider_decay">Percentage discharged by month (a)</label>
                  <input class="js-range-slider" id="a-slider_decay" data-min="0" data-max="100" data-from="0" data-step="0.01" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-postfix="%" data-keyboard="true" data-data-type="number"/>
                </div>
                <div class="form-group shiny-input-container">
                  <label class="control-label" for="a-slider_success">Percentage of patients recovering</label>
                  <input class="js-range-slider" id="a-slider_success" data-min="0" data-max="100" data-from="0" data-step="0.01" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-postfix="%" data-keyboard="true" data-data-type="number"/>
                </div>
                <div class="form-group shiny-input-container">
                  <label class="control-label" for="a-treatment_appointments">Average contacts per person per month</label>
                  <input class="js-range-slider" id="a-treatment_appointments" data-min="0" data-max="10" data-from="0" data-step="0.01" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-keyboard="true" data-data-type="number"/>
                </div>
                <a id="a-treatment_params_help" href="#" class="action-button">
                  <i class="fa fa-question"></i>
                  
                </a>
              </div>
            </div>
          </div>
          <div class="col-sm-12">
            <div class="box box-solid box-primary">
              <div class="box-header">
                <h3 class="box-title">Download Parameters</h3>
              </div>
              <div class="box-body">
                <a id="a-download_params" class="btn btn-default shiny-download-link " href="" target="_blank" download>
                  <i class="fa fa-download"></i>
                  Download current parameters
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>

