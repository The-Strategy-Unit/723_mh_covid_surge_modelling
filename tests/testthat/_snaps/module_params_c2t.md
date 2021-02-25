# changing the dropdown updates the container

    Code
      output$container$html
    Output
      <table>
        <tr>
          <th style="padding: 0px 5px 0px 0px;">Treatment</th>
          <th style="padding: 0px 5px 0px 0px;">Split</th>
          <th style="padding: 0px 5px 0px 0px;">Split %</th>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">24/7 Crisis Response Line</td>
          <td style="padding: 0px 5px 0px 0px;">
            <div class="form-group shiny-input-container" style="width:75px;">
              <label class="control-label shiny-label-null" for="proxy1-numeric_treat_split_24/7_Crisis_Response_Line" id="proxy1-numeric_treat_split_24/7_Crisis_Response_Line-label"></label>
              <input id="proxy1-numeric_treat_split_24/7_Crisis_Response_Line" type="number" class="form-control" value="3"/>
            </div>
          </td>
          <td style="padding: 0px 5px 0px 0px;">
            <span id="proxy1-pcnt_treat_split_24/7_Crisis_Response_Line" class="shiny-text-output"></span>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">Child &amp; Adolescent Mental Health</td>
          <td style="padding: 0px 5px 0px 0px;">
            <div class="form-group shiny-input-container" style="width:75px;">
              <label class="control-label shiny-label-null" for="proxy1-numeric_treat_split_Child_&amp;_Adolescent_Mental_Health" id="proxy1-numeric_treat_split_Child_&amp;_Adolescent_Mental_Health-label"></label>
              <input id="proxy1-numeric_treat_split_Child_&amp;_Adolescent_Mental_Health" type="number" class="form-control" value="5"/>
            </div>
          </td>
          <td style="padding: 0px 5px 0px 0px;">
            <span id="proxy1-pcnt_treat_split_Child_&amp;_Adolescent_Mental_Health" class="shiny-text-output"></span>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">Crisis Resolution Team/Home Treatment Service</td>
          <td style="padding: 0px 5px 0px 0px;">
            <div class="form-group shiny-input-container" style="width:75px;">
              <label class="control-label shiny-label-null" for="proxy1-numeric_treat_split_Crisis_Resolution_Team/Home_Treatment_Service" id="proxy1-numeric_treat_split_Crisis_Resolution_Team/Home_Treatment_Service-label"></label>
              <input id="proxy1-numeric_treat_split_Crisis_Resolution_Team/Home_Treatment_Service" type="number" class="form-control" value="5"/>
            </div>
          </td>
          <td style="padding: 0px 5px 0px 0px;">
            <span id="proxy1-pcnt_treat_split_Crisis_Resolution_Team/Home_Treatment_Service" class="shiny-text-output"></span>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">General emergency phone lines</td>
          <td style="padding: 0px 5px 0px 0px;">
            <div class="form-group shiny-input-container" style="width:75px;">
              <label class="control-label shiny-label-null" for="proxy1-numeric_treat_split_General_emergency_phone_lines" id="proxy1-numeric_treat_split_General_emergency_phone_lines-label"></label>
              <input id="proxy1-numeric_treat_split_General_emergency_phone_lines" type="number" class="form-control" value="15"/>
            </div>
          </td>
          <td style="padding: 0px 5px 0px 0px;">
            <span id="proxy1-pcnt_treat_split_General_emergency_phone_lines" class="shiny-text-output"></span>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">General Practice</td>
          <td style="padding: 0px 5px 0px 0px;">
            <div class="form-group shiny-input-container" style="width:75px;">
              <label class="control-label shiny-label-null" for="proxy1-numeric_treat_split_General_Practice" id="proxy1-numeric_treat_split_General_Practice-label"></label>
              <input id="proxy1-numeric_treat_split_General_Practice" type="number" class="form-control" value="16"/>
            </div>
          </td>
          <td style="padding: 0px 5px 0px 0px;">
            <span id="proxy1-pcnt_treat_split_General_Practice" class="shiny-text-output"></span>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">IAPT</td>
          <td style="padding: 0px 5px 0px 0px;">
            <div class="form-group shiny-input-container" style="width:75px;">
              <label class="control-label shiny-label-null" for="proxy1-numeric_treat_split_IAPT" id="proxy1-numeric_treat_split_IAPT-label"></label>
              <input id="proxy1-numeric_treat_split_IAPT" type="number" class="form-control" value="39"/>
            </div>
          </td>
          <td style="padding: 0px 5px 0px 0px;">
            <span id="proxy1-pcnt_treat_split_IAPT" class="shiny-text-output"></span>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">Primary Care Mental Health Service</td>
          <td style="padding: 0px 5px 0px 0px;">
            <div class="form-group shiny-input-container" style="width:75px;">
              <label class="control-label shiny-label-null" for="proxy1-numeric_treat_split_Primary_Care_Mental_Health_Service" id="proxy1-numeric_treat_split_Primary_Care_Mental_Health_Service-label"></label>
              <input id="proxy1-numeric_treat_split_Primary_Care_Mental_Health_Service" type="number" class="form-control" value="5"/>
            </div>
          </td>
          <td style="padding: 0px 5px 0px 0px;">
            <span id="proxy1-pcnt_treat_split_Primary_Care_Mental_Health_Service" class="shiny-text-output"></span>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">Psychiatric Liaison Service</td>
          <td style="padding: 0px 5px 0px 0px;">
            <div class="form-group shiny-input-container" style="width:75px;">
              <label class="control-label shiny-label-null" for="proxy1-numeric_treat_split_Psychiatric_Liaison_Service" id="proxy1-numeric_treat_split_Psychiatric_Liaison_Service-label"></label>
              <input id="proxy1-numeric_treat_split_Psychiatric_Liaison_Service" type="number" class="form-control" value="2"/>
            </div>
          </td>
          <td style="padding: 0px 5px 0px 0px;">
            <span id="proxy1-pcnt_treat_split_Psychiatric_Liaison_Service" class="shiny-text-output"></span>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">Psychological Therapy Service (non IAPT)</td>
          <td style="padding: 0px 5px 0px 0px;">
            <div class="form-group shiny-input-container" style="width:75px;">
              <label class="control-label shiny-label-null" for="proxy1-numeric_treat_split_Psychological_Therapy_Service_(non_IAPT)" id="proxy1-numeric_treat_split_Psychological_Therapy_Service_(non_IAPT)-label"></label>
              <input id="proxy1-numeric_treat_split_Psychological_Therapy_Service_(non_IAPT)" type="number" class="form-control" value="5"/>
            </div>
          </td>
          <td style="padding: 0px 5px 0px 0px;">
            <span id="proxy1-pcnt_treat_split_Psychological_Therapy_Service_(non_IAPT)" class="shiny-text-output"></span>
          </td>
        </tr>
        <tr>
          <td style="padding: 0px 5px 0px 0px;">Single Point of Access Service</td>
          <td style="padding: 0px 5px 0px 0px;">
            <div class="form-group shiny-input-container" style="width:75px;">
              <label class="control-label shiny-label-null" for="proxy1-numeric_treat_split_Single_Point_of_Access_Service" id="proxy1-numeric_treat_split_Single_Point_of_Access_Service-label"></label>
              <input id="proxy1-numeric_treat_split_Single_Point_of_Access_Service" type="number" class="form-control" value="5"/>
            </div>
          </td>
          <td style="padding: 0px 5px 0px 0px;">
            <span id="proxy1-pcnt_treat_split_Single_Point_of_Access_Service" class="shiny-text-output"></span>
          </td>
        </tr>
      </table>
      <div id="proxy1-treat_split_plot" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>

