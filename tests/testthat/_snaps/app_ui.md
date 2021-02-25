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
                <i class="fa fa-bars" role="presentation" aria-label="bars icon"></i>
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
                    <i class="fa fa-home" role="presentation" aria-label="home icon"></i>
                    <span>Home</span>
                  </a>
                </li>
                <li>
                  <a href="#shiny-tab-params" data-toggle="tab" data-value="params">
                    <i class="fa fa-dashboard" role="presentation" aria-label="dashboard icon"></i>
                    <span>Parameters</span>
                  </a>
                </li>
                <li>
                  <a href="#shiny-tab-demand" data-toggle="tab" data-value="demand">
                    <i class="fa fa-history" role="presentation" aria-label="history icon"></i>
                    <span>Demand</span>
                  </a>
                </li>
                <li>
                  <a href="#shiny-tab-results" data-toggle="tab" data-value="results">
                    <i class="fa fa-th" role="presentation" aria-label="th icon"></i>
                    <span>Results</span>
                  </a>
                </li>
                <li class="treeview">
                  <a href="#">
                    <span>Surge Demand</span>
                    <i class="fa fa-angle-left pull-right" role="presentation" aria-label="angle-left icon"></i>
                  </a>
                  <ul class="treeview-menu menu-open" style="display: block;" data-expanded="SurgeDemand">
                    <li>
                      <a href="#shiny-tab-surgetab_subpopn" data-toggle="tab" data-value="surgetab_subpopn">
                        <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon"></i>
                        Population Group
                      </a>
                    </li>
                    <li>
                      <a href="#shiny-tab-surgetab_condition" data-toggle="tab" data-value="surgetab_condition">
                        <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon"></i>
                        Condition
                      </a>
                    </li>
                    <li>
                      <a href="#shiny-tab-surgetab_service" data-toggle="tab" data-value="surgetab_service">
                        <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon"></i>
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
                <div role="tabpanel" class="tab-pane" id="shiny-tab-home">home_ui</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-params">params_ui</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-demand">demand_ui</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-results">results_ui</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-surgetab_subpopn">surge_subpopn</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-surgetab_condition">surge_condition</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-surgetab_service">surge_service</div>
              </div>
            </section>
          </div>
        </div>
      </body>

