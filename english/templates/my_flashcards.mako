## my_flashcards.mako
<%inherit file="layout.mako"/>

<%def name="page_title()">
  Lessons
</%def>

  <%def name="styleSheetIncludes()">

  </%def>

  <%def name="styleSheet()">
.bubble-container {
background-color: #E0EEEE;
margin: 0px auto;
padding-right:24px;
padding-left:24px;
padding-top: 24px;
padding-bottom: 10px;
border-radius:20px;
}
.inside-bubble {
background-color: #FFFFFF;
min-height: 100%;
padding-right: 5%;
padding-left: 5%;
padding-top: 5%;
padding-bottom: 5%;
border-radius: 1em;
}	
  </%def>

  <%def name="javascriptIncludes()">

  </%def>

  <%def name="javascript()">

	  
  </%def>

  <%def name="documentReady()">


  </%def>

<%def name="navbar()">
<%include file="toolbar.mako" args="groupname=group, current='lesson_index', user='${username}', flashcard_deck=flashcards"/>
</%def>

<%def name="sidebar()">

</%def>
   
<%def name="body()">

<div class='row col-lg-6 col-md-6 col-sm-6 col-xs-6'>
<h2>My Flashcards (${total_flashcards})</h2>


<div id='due-flashcards' class='bubble-container row'>
<span class='row'>
<span class='col-lg-4 col-md-4 col-sm-4 col-xs-4 lead'>Overdue</span>
<span class='col-lg-4 col-md-8 col-sm-8 col-xs-8 lead'>${flashcards_overdue} flashcards to practice  </span>
</span>
<span class='row'>
<span class='col-lg-4 col-md-4 col-sm-4 col-xs-4 lead'>Today</span>
<span class='col-lg-4 col-md-8 col-sm-8 col-xs-8 lead'>${flashcards_today} flashcards to practice  </span>
</span>
<span class='row'>
<span class='col-lg-4 col-md-4 col-sm-4 col-xs-4 lead'>Tomorrow</span>
<span class='col-lg-4 col-md-8 col-sm-8 col-xs-8 lead'>${flashcards_tomorrow} flashcards to practice  </span>
</span>
<span class='row'>
<span class='col-lg-4 col-md-4 col-sm-4 col-xs-4 lead'>This week</span>
<span class='col-lg-4 col-md-8 col-sm-8 col-xs-8 lead'>${flashcards_this_week} flashcards to practice  </span>
</span>
<span class='row'>
<span class='col-lg-4 col-md-4 col-sm-4 col-xs-4 lead'>Next week</span>
<span class='col-lg-4 col-md-8 col-sm-8 col-xs-8 lead'>${flashcards_next_week} flashcards to practice  </span>
</span>
</div>

</div>






 
</%def>
