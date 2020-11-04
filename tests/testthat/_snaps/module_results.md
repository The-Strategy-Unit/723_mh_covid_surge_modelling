# it generates the UI correctly

    Code
      ui
    Output
      <div class="row">
        <div class="col-sm-2">
          <div class="box box-solid box-primary">
            <div class="box-header">
              <h3 class="box-title">Service</h3>
            </div>
            <div class="box-body">
              <div class="form-group shiny-input-container">
                <label class="control-label" for="a-services">Service</label>
                <div>
                  <select id="a-services"></select>
                  <script type="application/json" data-for="a-services" data-nonempty="">{}</script>
                </div>
              </div>
              <div id="a-download_choice" class="form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline">
                <label class="control-label" for="a-download_choice">Download option</label>
                <div class="shiny-options-group">
                  <label class="radio-inline">
                    <input type="radio" name="a-download_choice" value="selected" checked="checked"/>
                    <span>Selected Service</span>
                  </label>
                  <label class="radio-inline">
                    <input type="radio" name="a-download_choice" value="all"/>
                    <span>All Services</span>
                  </label>
                </div>
              </div>
              <a id="a-download_report" class="btn btn-default shiny-download-link " href="" target="_blank" download>
                <i class="fa fa-download"></i>
                Download report (.pdf)
              </a>
              <br/>
              <br/>
              <a id="a-download_output" class="btn btn-default shiny-download-link " href="" target="_blank" download>
                <i class="fa fa-download"></i>
                Download model output (.csv)
              </a>
            </div>
          </div>
        </div>
        <div class="col-sm-5">
          <div class="box box-solid box-primary">
            <div class="box-header">
              <h3 class="box-title">Summary</h3>
            </div>
            <div class="box-body" id="results_value_boxes">
              <div class="shiny-html-output col-sm-4" id="a-total_referrals"></div>
              <div class="shiny-html-output col-sm-4" id="a-total_demand"></div>
              <div class="shiny-html-output col-sm-4" id="a-total_newpatients"></div>
              <div class="shiny-html-output col-sm-4" id="a-pcnt_surgedemand"></div>
              <div id="a-pct_surgedemand_table" class="shiny-html-output"></div>
              <div id="a-pcnt_surgedemand_note" class="shiny-text-output"></div>
            </div>
          </div>
        </div>
        <div class="col-sm-5">
          <div class="box box-solid box-primary">
            <div class="box-header">
              <h3 class="box-title">Population group source of 'surge'</h3>
            </div>
            <div class="box-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-fbd120925e91eabe312236e54aa7bcd3" class="loader">Loading...</div>
                </div>
                <div id="a-results_popgroups" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-6">
          <div class="box box-solid box-primary">
            <div class="box-header">
              <h3 class="box-title">Modelled referrals and treatments</h3>
            </div>
            <div class="box-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-0381391acfcd27e1455da7ea6844e96b" class="loader">Loading...</div>
                </div>
                <div id="a-referrals_plot" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
              </div>
            </div>
          </div>
        </div>
        <div class="col-sm-6">
          <div class="box box-solid box-primary">
            <div class="box-header">
              <h3 class="box-title">Modelled service contacts (demand)</h3>
            </div>
            <div class="box-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-d92492aea63370e31f2e5515b7d034ae" class="loader">Loading...</div>
                </div>
                <div id="a-demand_plot" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
              </div>
            </div>
          </div>
        </div>
        <div class="col-sm-12">
          <div class="box box-solid box-primary">
            <div class="box-header">
              <h3 class="box-title">Combined modelled and projected referrals to service</h3>
            </div>
            <div class="box-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-f2deac5c7c6e4fd87b2918695ba7bd58" class="loader">Loading...</div>
                </div>
                <div id="a-combined_plot" style="width:100%; height:600px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
              </div>
            </div>
          </div>
        </div>
        <div class="col-sm-12">
          <div class="box box-solid box-primary">
            <div class="box-header">
              <h3 class="box-title">Flows from population groups to conditions to service</h3>
            </div>
            <div class="box-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-3185d3971080c0a04af007f451976f75" class="loader">Loading...</div>
                </div>
                <div id="a-graph" style="width:100%; height:600px; " class="plotly html-widget html-widget-output shiny-report-size"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

