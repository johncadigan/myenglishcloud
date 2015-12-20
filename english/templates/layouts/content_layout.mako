## layout.mako
<%inherit file="base.mako"/>


<%def name="page_title()">

	${next.page_title()}

</%def>

  <%def name="styleSheetIncludes()">
<link href="${request.static_url('english:/static/css/aptquiz.css')}" media="screen" rel="stylesheet" type="text/css">
<!--Quiz-->
<link href="${request.static_url('english:/static/css/slickQuiz.css')}" media="screen" rel="stylesheet" type="text/css">
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

	<!--/AJAX form-->
	<script src="${request.static_url('english:/static/js/jquery.form.js')}"></script>
	<!--/Rating-->
	<script src="${request.static_url('english:/static/js/bootstrap-rating-input-master/src/bootstrap-rating-input.js')}"></script
	<!--Quiz-->
	<script src="${request.static_url('english:/static/js/aptQuiz.js')}"></script>
	<script src="${request.static_url('english:/static/js/master.js')}"></script>
	
          ${next.javascriptIncludes()}
  </%def>

  <%def name="javascript()">
          ${next.javascript()}
	  
  </%def>

  <%def name="documentReady()">
   var difficulty_options = { 
        target:  '#Difficulty-Rating',   // target element(s) to be updated with server response  
        url:  "${request.route_url('rate_difficulty', cid=content['cid'])}",
        type: 'post'  
    };  
    $('#Difficulty-Rating').submit(function() {  
        $(this).ajaxSubmit(difficulty_options); 
        return false; 
    });
    var quality_options = { 
        target:  '#Quality-Rating',   // target element(s) to be updated with server response  
        url:  "${request.route_url('rate_quality', cid = content['cid'])}",
        type: 'post'  
    };  
    $('#Quality-Rating').submit(function() {  
        $(this).ajaxSubmit(quality_options); 
        return false; 
    });
    
    $('.rating').on('change', function(){
          $(this).parents('.Star-Form').submit();
    });
    $(".vote-button").hide();
    
    var comment_options = { 
        target:  '#posts',   // target element(s) to be updated with server response  
        url:  "${request.route_url('add_comment', cid = content['cid'])}",
        type: 'post'  
    };
    $('#frm').submit(function() {  
        $(this).ajaxSubmit(comment_options); 
	$('#frm').hide();
        return false; 
    });
    var vocab_options = { 
        target:  '#add-vocab-box',   // target element(s) to be updated with server response  
        url:  "${request.route_url('add_flashcards', cid = content['cid'])}",
        type: 'post'  
    };
    $('#Add-Vocab').attr('action', "${request.route_url('add_flashcards', cid = content['cid'])}")
    $('#Add-Vocab').submit(function(event) {
	event.preventDefault();  
        $(this).ajaxSubmit(vocab_options); 

     $('#add-vocab-box').hide();
%if vocabulary:
	add = new Number(${len(vocabulary)});
	
	currentDue = new Number($('#due-flashcards').html());
	currentAdd = new Number($('#intro-flashcards').html());	
	if(isNaN(currentDue)){$('#due-flashcards').html(add);}
	else{$('#due-flashcards').html(currentDue+add);}
	if(isNaN(currentAdd)==true){$('#intro-flashcards').html(add);}
	else{$('#intro-flashcards').html(currentAdd+add);}

	
%endif

    });

    $('#point-form').hide();
    var quiz_options = {
       target:  '#point-results',   // target element(s) to be updated with server response  
        url:  "${request.route_url('report_score', cid=content['cid'])}",
        type: 'post' 
	};
    $('#point-form').submit(function() {  
        $(this).ajaxSubmit(quiz_options);
	return false;
	});



	${next.documentReady()}
  </%def>

   
  <%def name="body()">




    <%include file="toolbar.mako" args="groupname=group, current='lesson_index', user=username, flashcards=flashcards"/>
       
    <div>
      <div class="fluid-container">
        
	<div class="col-lg-12">
	${next.body()}
   	</div><!--/row-->

	<div class="col-lg-12">
          ${next.sidebar()}
        </div><!--/span-->
      </div>
      <div class="clearfix"></div>
      <div class="row">
	<div class="col-lg-12">
          ${next.bottom()}
        </div><!--/span-->
       </div>


      </div><!--/span-->
   </div><!--/row-->

  <hr>
	<%include file="footer.mako"/>

</div>

</%def>
