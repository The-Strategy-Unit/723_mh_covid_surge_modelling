# it creates the UI correctly

    Code
      demand_ui("x")
    Output
      <div class="row">
        <div class="col-sm-12">
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
                <label class="control-label" for="x-service">Service</label>
                <div>
                  <select id="x-service"></select>
                  <script type="application/json" data-for="x-service" data-nonempty="">{}</script>
                </div>
              </div>
              <div id="x-container" class="shiny-html-output"></div>
            </div>
          </div>
        </div>
      </div>

# it creates a table correctly when input$service is changed

    Code
      output$container$html
    Output
      <table>
        <tr>
          <th>Month</th>
          <th>Underlying</th>
          <th>Suppressed</th>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>May-20</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-May-20-underlying"></label>
              <input id="proxy1-May-20-underlying" type="number" class="form-control" value="1999" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-May-20-suppressed"></label>
              <input id="proxy1-May-20-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Jun-20</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jun-20-underlying"></label>
              <input id="proxy1-Jun-20-underlying" type="number" class="form-control" value="1872" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jun-20-suppressed"></label>
              <input id="proxy1-Jun-20-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Jul-20</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jul-20-underlying"></label>
              <input id="proxy1-Jul-20-underlying" type="number" class="form-control" value="1847" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jul-20-suppressed"></label>
              <input id="proxy1-Jul-20-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Aug-20</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Aug-20-underlying"></label>
              <input id="proxy1-Aug-20-underlying" type="number" class="form-control" value="1814" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Aug-20-suppressed"></label>
              <input id="proxy1-Aug-20-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Sep-20</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Sep-20-underlying"></label>
              <input id="proxy1-Sep-20-underlying" type="number" class="form-control" value="1933" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Sep-20-suppressed"></label>
              <input id="proxy1-Sep-20-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Oct-20</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Oct-20-underlying"></label>
              <input id="proxy1-Oct-20-underlying" type="number" class="form-control" value="2102" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Oct-20-suppressed"></label>
              <input id="proxy1-Oct-20-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Nov-20</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Nov-20-underlying"></label>
              <input id="proxy1-Nov-20-underlying" type="number" class="form-control" value="1976" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Nov-20-suppressed"></label>
              <input id="proxy1-Nov-20-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Dec-20</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Dec-20-underlying"></label>
              <input id="proxy1-Dec-20-underlying" type="number" class="form-control" value="1735" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Dec-20-suppressed"></label>
              <input id="proxy1-Dec-20-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Jan-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jan-21-underlying"></label>
              <input id="proxy1-Jan-21-underlying" type="number" class="form-control" value="2075" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jan-21-suppressed"></label>
              <input id="proxy1-Jan-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Feb-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Feb-21-underlying"></label>
              <input id="proxy1-Feb-21-underlying" type="number" class="form-control" value="2456" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Feb-21-suppressed"></label>
              <input id="proxy1-Feb-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Mar-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Mar-21-underlying"></label>
              <input id="proxy1-Mar-21-underlying" type="number" class="form-control" value="1843" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Mar-21-suppressed"></label>
              <input id="proxy1-Mar-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Apr-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Apr-21-underlying"></label>
              <input id="proxy1-Apr-21-underlying" type="number" class="form-control" value="1892" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Apr-21-suppressed"></label>
              <input id="proxy1-Apr-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>May-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-May-21-underlying"></label>
              <input id="proxy1-May-21-underlying" type="number" class="form-control" value="1999" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-May-21-suppressed"></label>
              <input id="proxy1-May-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Jun-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jun-21-underlying"></label>
              <input id="proxy1-Jun-21-underlying" type="number" class="form-control" value="1872" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jun-21-suppressed"></label>
              <input id="proxy1-Jun-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Jul-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jul-21-underlying"></label>
              <input id="proxy1-Jul-21-underlying" type="number" class="form-control" value="1847" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jul-21-suppressed"></label>
              <input id="proxy1-Jul-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Aug-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Aug-21-underlying"></label>
              <input id="proxy1-Aug-21-underlying" type="number" class="form-control" value="1814" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Aug-21-suppressed"></label>
              <input id="proxy1-Aug-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Sep-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Sep-21-underlying"></label>
              <input id="proxy1-Sep-21-underlying" type="number" class="form-control" value="1933" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Sep-21-suppressed"></label>
              <input id="proxy1-Sep-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Oct-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Oct-21-underlying"></label>
              <input id="proxy1-Oct-21-underlying" type="number" class="form-control" value="2102" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Oct-21-suppressed"></label>
              <input id="proxy1-Oct-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Nov-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Nov-21-underlying"></label>
              <input id="proxy1-Nov-21-underlying" type="number" class="form-control" value="1976" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Nov-21-suppressed"></label>
              <input id="proxy1-Nov-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Dec-21</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Dec-21-underlying"></label>
              <input id="proxy1-Dec-21-underlying" type="number" class="form-control" value="1735" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Dec-21-suppressed"></label>
              <input id="proxy1-Dec-21-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Jan-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jan-22-underlying"></label>
              <input id="proxy1-Jan-22-underlying" type="number" class="form-control" value="2075" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jan-22-suppressed"></label>
              <input id="proxy1-Jan-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Feb-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Feb-22-underlying"></label>
              <input id="proxy1-Feb-22-underlying" type="number" class="form-control" value="2456" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Feb-22-suppressed"></label>
              <input id="proxy1-Feb-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Mar-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Mar-22-underlying"></label>
              <input id="proxy1-Mar-22-underlying" type="number" class="form-control" value="1843" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Mar-22-suppressed"></label>
              <input id="proxy1-Mar-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Apr-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Apr-22-underlying"></label>
              <input id="proxy1-Apr-22-underlying" type="number" class="form-control" value="1892" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Apr-22-suppressed"></label>
              <input id="proxy1-Apr-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>May-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-May-22-underlying"></label>
              <input id="proxy1-May-22-underlying" type="number" class="form-control" value="1999" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-May-22-suppressed"></label>
              <input id="proxy1-May-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Jun-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jun-22-underlying"></label>
              <input id="proxy1-Jun-22-underlying" type="number" class="form-control" value="1872" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jun-22-suppressed"></label>
              <input id="proxy1-Jun-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Jul-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jul-22-underlying"></label>
              <input id="proxy1-Jul-22-underlying" type="number" class="form-control" value="1847" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jul-22-suppressed"></label>
              <input id="proxy1-Jul-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Aug-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Aug-22-underlying"></label>
              <input id="proxy1-Aug-22-underlying" type="number" class="form-control" value="1814" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Aug-22-suppressed"></label>
              <input id="proxy1-Aug-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Sep-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Sep-22-underlying"></label>
              <input id="proxy1-Sep-22-underlying" type="number" class="form-control" value="1933" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Sep-22-suppressed"></label>
              <input id="proxy1-Sep-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Oct-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Oct-22-underlying"></label>
              <input id="proxy1-Oct-22-underlying" type="number" class="form-control" value="2102" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Oct-22-suppressed"></label>
              <input id="proxy1-Oct-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Nov-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Nov-22-underlying"></label>
              <input id="proxy1-Nov-22-underlying" type="number" class="form-control" value="1976" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Nov-22-suppressed"></label>
              <input id="proxy1-Nov-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Dec-22</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Dec-22-underlying"></label>
              <input id="proxy1-Dec-22-underlying" type="number" class="form-control" value="1735" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Dec-22-suppressed"></label>
              <input id="proxy1-Dec-22-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Jan-23</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jan-23-underlying"></label>
              <input id="proxy1-Jan-23-underlying" type="number" class="form-control" value="2075" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Jan-23-suppressed"></label>
              <input id="proxy1-Jan-23-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Feb-23</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Feb-23-underlying"></label>
              <input id="proxy1-Feb-23-underlying" type="number" class="form-control" value="2456" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Feb-23-suppressed"></label>
              <input id="proxy1-Feb-23-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Mar-23</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Mar-23-underlying"></label>
              <input id="proxy1-Mar-23-underlying" type="number" class="form-control" value="1843" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Mar-23-suppressed"></label>
              <input id="proxy1-Mar-23-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">
            <div>Apr-23</div>
          </td>
          <td style="padding: 0px 2px 0px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Apr-23-underlying"></label>
              <input id="proxy1-Apr-23-underlying" type="number" class="form-control" value="1892" min="0" step="1"/>
            </div>
          </td>
          <td style="padding: 0px 0px 1px 2px;">
            <div class="form-group shiny-input-container">
              <label class="control-label shiny-label-null" for="proxy1-Apr-23-suppressed"></label>
              <input id="proxy1-Apr-23-suppressed" type="number" class="form-control" value="0" min="0" step="1"/>
            </div>
          </td>
        </tr>
      </table>

