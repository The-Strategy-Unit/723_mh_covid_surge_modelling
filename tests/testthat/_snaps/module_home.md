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
            <div class="shiny-html-output shinyjs-hide" id="a-example_param_file_text"></div>
          </div>
        </div>
      </div>
      documentation

