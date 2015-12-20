## search_flashcards.mako

<%inherit file="layout.mako"/>

<%def name="page_title()">
  Lessons
</%def>

  <%def name="styleSheetIncludes()">
   <link href="${request.static_url('english:/static/rating/jquery.rating.css')}" media="screen" rel="stylesheet" type="text/css">
  </%def>

  <%def name="styleSheet()">
.bubble-container {
background-color: #E0EEEE;
margin: 0px auto;
padding-right:20px;
padding-left:10px;
padding-top: 10px;
padding-bottom: 10px;
border-radius:10px;
}
.inside-bubble {
background-color: #FFFFFF;
min-height: 50%;
padding-right: 1%;
padding-left: 1%;
padding-top: 1%;
padding-bottom: 1%;
border-radius: 1em;
}

  </%def>

  <%def name="javascriptIncludes()">
   <script src="${request.static_url('english:/static/rating/jquery.MetaData.js')}"></script>
   <script src="${request.static_url('english:/static/rating/jquery.rating.pack.js')}"></script>
   <script src="${request.static_url('english:/static/js/jquery.form.js')}"></script>
  </%def>

  <%def name="javascript()">

	  
  </%def>

  <%def name="documentReady()">
   var vocab_options = { 
        target:  '#test',   // target element(s) to be updated with server response  
        url:  "${request.route_url('add_flashcards')}",
        type: 'post'  
    };
  
  $('.add-vocab').submit(function(event) {
	event.preventDefault();
        $(this).ajaxSubmit(vocab_options);
     	$(this).parent('.add-vocab-box').hide();
	add = new Number($(this).children('.vocab-len').html());
	currentDue = new Number($('#due-flashcards').html());
	currentAdd = new Number($('#intro-flashcards').html());	
	if(isNaN(currentDue)){$('#due-flashcards').html(add);}
	else{$('#due-flashcards').html(currentDue+add);}
	if(isNaN(currentAdd)==true){$('#intro-flashcards').html(add);}
	else{$('#intro-flashcards').html(currentAdd+add);}
    
    });
  </%def>

<%def name="navbar()">
<%include file="toolbar.mako" args="groupname=group, current='tag_index', user='${username}', flashcard_deck=flashcards"/>
</%def>


<%def name="sidebar()">
<%include file="flashcard_search_box.mako" args="user=username, search=search_criteria, action=request.url"/>
</%def>


<%def name="body()">
<div id='test'>test</div>
%for word in words:
   <%include file="flashcard_display_box.mako"  args="cardinfo=word, current='search'"/>
   <br>
%endfor
        
</%def>
