## add_forms.mako


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
  </%def>

  <%def name="javascript()">

	  
  </%def>

  <%def name="documentReady()">


  </%def>

<%def name="navbar()">
<%include file="toolbar.mako" args="groupname=group, current='tag_index', user='${username}', flashcard_deck=flashcards"/>
</%def>


<%def name="sidebar()">

</%def>


<%def name="body()">

%for form in forms:
	<a href="${request.route_url('add_form', word_form=form)}">${form}</a>
        <br>
%endfor

	        
</%def>
