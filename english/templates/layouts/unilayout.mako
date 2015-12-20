## unilayout.mako
<%inherit file="base.mako"/>

<%def name="page_title()">

	${next.page_title()}

</%def>

  <%def name="styleSheetIncludes()">

	${next.styleSheetIncludes()}

  </%def>

  <%def name="styleSheet()">
	body {
        padding-top: 0px;
        padding-bottom: 0px;
	background:#F8F8F8;
      }
      .sidebar-nav {
        padding: 9px 0;
      }
      @media (max-width: 980px) {
        /* Enable use of floated navbar text */
        .navbar-text.pull-right {
          float: none;
          padding-left: 5px;
          padding-right: 5px;
	
        }
      }
      
          ${next.styleSheet()}
  </%def>

  <%def name="javascriptIncludes()">
          ${next.javascriptIncludes()}
  </%def>

  <%def name="javascript()">
          ${next.javascript()}
	  
  </%def>

  <%def name="documentReady()">

	${next.documentReady()}
  </%def>

   
  <%def name="body()">
 

    <div class="container-fluid backgrnd">
      <div class="row-fluid">

	${next.body()}


   	</div><!--/span-->
   </div><!--/row-->



</%def>



