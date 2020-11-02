# main ui is generated correctly

    Code
      app_ui()
    Output
      <link rel="stylesheet" type="text/css" href="www/skin-su.css"/>
      <body class="skin-blue" style="min-height: 611px;">
        <div class="wrapper">
          <header class="main-header">
            <span class="logo">MH Surge Modelling</span>
            <nav class="navbar navbar-static-top" role="navigation">
              <span style="display:none;">
                <i class="fa fa-bars"></i>
              </span>
              <a href="#" class="sidebar-toggle" data-toggle="offcanvas" role="button">
                <span class="sr-only">Toggle navigation</span>
              </a>
              <div class="navbar-custom-menu">
                <img src="https://www.strategyunitwm.nhs.uk/themes/custom/ie_bootstrap/logo.svg" title="The Strategy Unit" alt="The Strategy Unit Logo" align="right" height="40"/>
              </div>
            </nav>
          </header>
          <aside id="sidebarCollapsed" class="main-sidebar" data-collapsed="false">
            <section id="sidebarItemExpanded" class="sidebar">
              <ul class="sidebar-menu">
                <li>
                  <a href="#shiny-tab-home" data-toggle="tab" data-value="home" data-start-selected="1">
                    <i class="fa fa-home"></i>
                    <span>Home</span>
                  </a>
                </li>
                <li>
                  <a href="#shiny-tab-params" data-toggle="tab" data-value="params">
                    <i class="fa fa-dashboard"></i>
                    <span>Parameters</span>
                  </a>
                </li>
                <li>
                  <a href="#shiny-tab-demand" data-toggle="tab" data-value="demand">
                    <i class="fa fa-history"></i>
                    <span>Demand</span>
                  </a>
                </li>
                <li>
                  <a href="#shiny-tab-results" data-toggle="tab" data-value="results">
                    <i class="fa fa-th"></i>
                    <span>Results</span>
                  </a>
                </li>
                <li class="treeview">
                  <a href="#">
                    <span>Surge Demand</span>
                    <i class="fa fa-angle-left pull-right"></i>
                  </a>
                  <ul class="treeview-menu menu-open" style="display: block;" data-expanded="SurgeDemand">
                    <li>
                      <a href="#shiny-tab-surgetab_subpopn" data-toggle="tab" data-value="surgetab_subpopn">
                        <i class="fa fa-angle-double-right"></i>
                        Population Group
                      </a>
                    </li>
                    <li>
                      <a href="#shiny-tab-surgetab_condition" data-toggle="tab" data-value="surgetab_condition">
                        <i class="fa fa-angle-double-right"></i>
                        Condition
                      </a>
                    </li>
                    <li>
                      <a href="#shiny-tab-surgetab_service" data-toggle="tab" data-value="surgetab_service">
                        <i class="fa fa-angle-double-right"></i>
                        Service
                      </a>
                    </li>
                  </ul>
                </li>
              </ul>
            </section>
          </aside>
          <div class="content-wrapper">
            <section class="content">
              <div class="tab-content">
                <div role="tabpanel" class="tab-pane" id="shiny-tab-home">
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
                  <div class="col-lg-12">
                    <div class="box box-solid box-primary">
                      <div class="box-header">
                        <h3 class="box-title">Select parameters</h3>
                      </div>
                      <div class="box-body">
                        <div class="form-group shiny-input-container">
                          <label class="control-label" for="home_page-params_select">Default Parameters</label>
                          <div>
                            <select id="home_page-params_select"><option value="C:/Users/thomas.jemmett/dev/R/active_projects/723_mh_covid_surge_modelling/inst/app/data/params_England.xlsx" selected>England</option>
      <option value="C:/Users/thomas.jemmett/dev/R/active_projects/723_mh_covid_surge_modelling/inst/app/data/params_CWP.xlsx">CWP</option>
      <option value="C:/Users/thomas.jemmett/dev/R/active_projects/723_mh_covid_surge_modelling/inst/app/data/params_Mersey-Care.xlsx">Mersey Care</option>
      <option value="custom">Custom</option></select>
                            <script type="application/json" data-for="home_page-params_select" data-nonempty="">{}</script>
                          </div>
                        </div>
                        <div class="form-group shiny-input-container shinyjs-hide">
                          <label class="control-label shiny-label-null" for="home_page-user_upload_xlsx"></label>
                          <div class="input-group">
                            <label class="input-group-btn input-group-prepend">
                              <span class="btn btn-default btn-file">
                                Browse...
                                <input id="home_page-user_upload_xlsx" name="home_page-user_upload_xlsx" type="file" style="display: none;" accept=".xlsx"/>
                              </span>
                            </label>
                            <input type="text" class="form-control" placeholder="Previously downloaded parameters" readonly="readonly"/>
                          </div>
                          <div id="home_page-user_upload_xlsx_progress" class="progress active shiny-file-input-progress">
                            <div class="progress-bar"></div>
                          </div>
                        </div>
                        <div class="shiny-html-output shinyjs-hide" id="home_page-user_upload_xlsx_msg"></div>
                      </div>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-params">
                  <div class="row">
                    <div class="col-lg-3">
                      <div class="col-lg-12">
                        <div class="box box-solid box-primary">
                          <div class="box-header">
                            <h3 class="box-title">Population Groups</h3>
                          </div>
                          <div class="box-body">
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="params_page-popn_subgroup">Choose subgroup</label>
                              <div>
                                <select id="params_page-popn_subgroup"></select>
                                <script type="application/json" data-for="params_page-popn_subgroup" data-nonempty="">{}</script>
                              </div>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="params_page-subpopulation_size">Subpopulation Figure</label>
                              <input id="params_page-subpopulation_size" type="number" class="form-control" step="100"/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="params_page-subpopulation_pcnt">Susceptibility and Resilience adjustment (see help notes)</label>
                              <input class="js-range-slider" id="params_page-subpopulation_pcnt" data-min="0" data-max="100" data-from="100" data-step="1" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-postfix="%" data-keyboard="true" data-data-type="number"/>
                            </div>
                            <div id="params_page-subpopulation_size_pcnt" class="shiny-text-output"></div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="params_page-subpopulation_curve">Choose scenario</label>
                              <div>
                                <select id="params_page-subpopulation_curve"></select>
                                <script type="application/json" data-for="params_page-subpopulation_curve" data-nonempty="">{}</script>
                              </div>
                            </div>
                            <div id="params_page-subpopulation_curve_plot" style="width:100%; height:100px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
                            <a id="params_page-population_group_help" href="#" class="action-button">
                              <i class="fa fa-question"></i>
                              
                            </a>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-3">
                      <div class="col-lg-12">
                        <div class="box box-solid box-primary">
                          <div class="box-header">
                            <h3 class="box-title">Impacts on population sub-group</h3>
                          </div>
                          <div class="box-body">
                            <div id="g2c-container" class="shiny-html-output"></div>
                            <a id="params_page-group_to_cond_params_help" href="#" class="action-button">
                              <i class="fa fa-question"></i>
                              
                            </a>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-3">
                      <div class="col-lg-12">
                        <div class="box box-solid box-primary">
                          <div class="box-header">
                            <h3 class="box-title">Referral/Service flows for impacts</h3>
                          </div>
                          <div class="box-body">
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="c2t-sliders_select_cond">Condition</label>
                              <div>
                                <select id="c2t-sliders_select_cond"></select>
                                <script type="application/json" data-for="c2t-sliders_select_cond" data-nonempty="">{}</script>
                              </div>
                            </div>
                            <div id="c2t-container" class="shiny-html-output"></div>
                            <a id="params_page-cond_to_treat_params_help" href="#" class="action-button">
                              <i class="fa fa-question"></i>
                              
                            </a>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-3">
                      <div class="col-lg-12">
                        <div class="box box-solid box-primary">
                          <div class="box-header">
                            <h3 class="box-title">Service variables</h3>
                          </div>
                          <div class="box-body">
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="params_page-treatment_type">Treatment type</label>
                              <div>
                                <select id="params_page-treatment_type"></select>
                                <script type="application/json" data-for="params_page-treatment_type" data-nonempty="">{}</script>
                              </div>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="params_page-slider_treat_pcnt">Referrals typically receiving a service</label>
                              <input class="js-range-slider" id="params_page-slider_treat_pcnt" data-min="0" data-max="100" data-from="0" data-step="0.01" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-postfix="%" data-keyboard="true" data-data-type="number"/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="params_page-slider_tx_months">Months in service (a)</label>
                              <input class="js-range-slider" id="params_page-slider_tx_months" data-min="0" data-max="24" data-from="1" data-step="0.1" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-keyboard="true" data-data-type="number"/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="params_page-slider_decay">Percentage discharged by month (a)</label>
                              <input class="js-range-slider" id="params_page-slider_decay" data-min="0" data-max="100" data-from="0" data-step="0.01" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-postfix="%" data-keyboard="true" data-data-type="number"/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="params_page-slider_success">Percentage of patients recovering</label>
                              <input class="js-range-slider" id="params_page-slider_success" data-min="0" data-max="100" data-from="0" data-step="0.01" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-postfix="%" data-keyboard="true" data-data-type="number"/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" for="params_page-treatment_appointments">Average contacts per person per month</label>
                              <input class="js-range-slider" id="params_page-treatment_appointments" data-min="0" data-max="10" data-from="0" data-step="0.01" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-keyboard="true" data-data-type="number"/>
                            </div>
                            <a id="params_page-treatment_params_help" href="#" class="action-button">
                              <i class="fa fa-question"></i>
                              
                            </a>
                          </div>
                        </div>
                      </div>
                      <div class="col-lg-12">
                        <div class="box box-solid box-primary">
                          <div class="box-header">
                            <h3 class="box-title">Download Parameters</h3>
                          </div>
                          <div class="box-body">
                            <a id="params_page-download_params" class="btn btn-default shiny-download-link " href="" target="_blank" download>
                              <i class="fa fa-download"></i>
                              Download current parameters
                            </a>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-demand">
                  <div class="row">
                    <div class="col-lg-12">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Demand</h3>
                        </div>
                        <div class="box-body">
                          <p>
                            If you want to plot the surge model outputs alongside your own projections for underlying demand and
                            catch-up of suppressed referrals then please enter the data by month here. Alternatively, this can be
                            uploaded in the 'demand' tab of the whole model parameter file.
                          </p>
                          <div class="form-group shiny-input-container">
                            <label class="control-label" for="demand_page-service">Service</label>
                            <div>
                              <select id="demand_page-service"></select>
                              <script type="application/json" data-for="demand_page-service" data-nonempty="">{}</script>
                            </div>
                          </div>
                          <div id="demand-data"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-results">
                  <div class="row">
                    <div class="col-lg-2">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Service</h3>
                        </div>
                        <div class="box-body">
                          <div class="form-group shiny-input-container">
                            <label class="control-label" for="results_page-services">Service</label>
                            <div>
                              <select id="results_page-services"></select>
                              <script type="application/json" data-for="results_page-services" data-nonempty="">{}</script>
                            </div>
                          </div>
                          <div id="results_page-download_choice" class="form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline">
                            <label class="control-label" for="results_page-download_choice">Download option</label>
                            <div class="shiny-options-group">
                              <label class="radio-inline">
                                <input type="radio" name="results_page-download_choice" value="selected" checked="checked"/>
                                <span>Selected Service</span>
                              </label>
                              <label class="radio-inline">
                                <input type="radio" name="results_page-download_choice" value="all"/>
                                <span>All Services</span>
                              </label>
                            </div>
                          </div>
                          <a id="results_page-download_report" class="btn btn-default shiny-download-link " href="" target="_blank" download>
                            <i class="fa fa-download"></i>
                            Download report (.pdf)
                          </a>
                          <br/>
                          <br/>
                          <a id="results_page-download_output" class="btn btn-default shiny-download-link " href="" target="_blank" download>
                            <i class="fa fa-download"></i>
                            Download model output (.csv)
                          </a>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-5">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Summary</h3>
                        </div>
                        <div class="box-body" id="results_value_boxes">
                          <div class="shiny-html-output col-sm-4" id="results_page-total_referrals"></div>
                          <div class="shiny-html-output col-sm-4" id="results_page-total_demand"></div>
                          <div class="shiny-html-output col-sm-4" id="results_page-total_newpatients"></div>
                          <div class="shiny-html-output col-sm-4" id="results_page-pcnt_surgedemand"></div>
                          <div id="results_page-pct_surgedemand_table" class="shiny-html-output"></div>
                          <div id="results_page-pcnt_surgedemand_note" class="shiny-text-output"></div>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-5">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Population group source of 'surge'</h3>
                        </div>
                        <div class="box-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-240e820e24bbf419e54e9714e90ddb79" class="loader">Loading...</div>
                            </div>
                            <div id="results_page-results_popgroups" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-lg-6">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Modelled referrals and treatments</h3>
                        </div>
                        <div class="box-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-8031f9716cbb60fa15491dcd62f7b14d" class="loader">Loading...</div>
                            </div>
                            <div id="results_page-referrals_plot" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-6">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Modelled service contacts (demand)</h3>
                        </div>
                        <div class="box-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-3b2072dccd0f65fe5bebdcde54d1c5ec" class="loader">Loading...</div>
                            </div>
                            <div id="results_page-demand_plot" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-12">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Combined modelled and projected referrals to service</h3>
                        </div>
                        <div class="box-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-5d45ede33d73a4eeaa2d2264bf09b7ba" class="loader">Loading...</div>
                            </div>
                            <div id="results_page-combined_plot" style="width:100%; height:600px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-12">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Flows from population groups to conditions to service</h3>
                        </div>
                        <div class="box-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-0568215a342e39e713609849a866ed7a" class="loader">Loading...</div>
                            </div>
                            <div id="results_page-graph" style="width:100%; height:600px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-surgetab_subpopn">
                  <div class="row">
                    <div class="col-lg-6">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Surge Table</h3>
                        </div>
                        <div class="box-body">
                          <div id="surge_subpopn-surge_table" class="shiny-html-output"></div>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-6">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Surge Chart</h3>
                        </div>
                        <div class="box-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-4a517c3d80061bb7afb6bd01fa96ee58" class="loader">Loading...</div>
                            </div>
                            <div id="surge_subpopn-surge_plot" style="width:100%; height:600px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-surgetab_condition">
                  <div class="row">
                    <div class="col-lg-6">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Surge Table</h3>
                        </div>
                        <div class="box-body">
                          <div id="surge_condition-surge_table" class="shiny-html-output"></div>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-6">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Surge Chart</h3>
                        </div>
                        <div class="box-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-e4a5ff35585a5b2789687daf71c452d1" class="loader">Loading...</div>
                            </div>
                            <div id="surge_condition-surge_plot" style="width:100%; height:600px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-surgetab_service">
                  <div class="row">
                    <div class="col-lg-6">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Surge Table</h3>
                        </div>
                        <div class="box-body">
                          <div id="surge_service-surge_table" class="shiny-html-output"></div>
                        </div>
                      </div>
                    </div>
                    <div class="col-lg-6">
                      <div class="box box-solid box-primary">
                        <div class="box-header">
                          <h3 class="box-title">Surge Chart</h3>
                        </div>
                        <div class="box-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-f61ea76cd9916b772e167f261a633a28" class="loader">Loading...</div>
                            </div>
                            <div id="surge_service-surge_plot" style="width:100%; height:600px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </section>
          </div>
        </div>
      </body>

