<%inherit file="layout.mako"/>


<%def name="page_title()">
  Update flashcards
</%def>

  <%def name="styleSheetIncludes()">

  </%def>

  <%def name="styleSheet()">

  </%def>

  <%def name="javascriptIncludes()">

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
%for flashcard in display_flashcards:
${flashcard['form']}
<br>
%endfor





</%def>
