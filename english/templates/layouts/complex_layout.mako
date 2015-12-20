## layout.mako
<%inherit file="base.mako"/>


<%def name="page_title()">

${next.page_title()}

</%def>

  <%def name="styleSheetIncludes()">

	${next.styleSheetIncludes()}

  </%def>

  <%def name="styleSheet()">
	body {
        padding-top: 60px;
        padding-bottom: 40px;
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
<script src="${request.static_url('english:/static/js/jquery.fitvids.js')}"></script>
      
    ${next.javascriptIncludes()}
	  </%def>

  <%def name="javascript()">
          ${next.javascript()}
	  
  </%def>

  <%def name="documentReady()">

	${next.documentReady()}
  </%def>

   
  <%def name="body()">
 


    <%include file="toolbar.mako" args="groupname=group, current='lesson_index', user=username, flashcards=flashcards"/>
       
    

      

    <div>
      <div class="row">
        
	<div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
	${next.body()}
   	</div><!--/row-->

       </div>
       <div class="row">
	<div class="col-lg-12">
          ${next.bottom()}
        </div><!--/span-->
       </div>



      </div><!--/span-->
   </div><!--/row-->

  <hr>

      <%include file="footer.mako"/>

</div><!--/.fluid-container-->
</%def>
