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
                <div role="tabpanel" class="tab-pane" id="shiny-tab-home">home_page</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-params">params_page</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-demand">demand_page</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-results">results_page</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-surgetab_subpopn">surge_subpopn</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-surgetab_condition">surge_subpopn</div>
                <div role="tabpanel" class="tab-pane" id="shiny-tab-surgetab_service">surge_subpopn</div>
              </div>
            </section>
          </div>
        </div>
      </body>

