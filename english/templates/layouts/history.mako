## index.mako
<%inherit file="layout.mako"/>

<%def name="page_title()">
  History
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
<%include file="toolbar.mako" args="groupname=group, current='lesson_index', user=username, flashcard_deck=flashcards"/>
</%def>
   
<%def name="sidebar()">

</%def>
   
  <%def name="body()">

<h3>Finished Lessons</h3>

<ul id="lessons" class='inline'>
% if contents:
  % for content in contents:
  %if content['type'] == 'lesson':
  <li>
     <a href="${request.application_url}/lesson/${content['url']}">${content['title']}</a>
  </li>
  %elif content['type'] == 'reading':
  <li>
     <a href="${request.application_url}/reading/${content['url']}">${content['title']}</a>
  </li>
  %endif
  % endfor
% else:
  <li>You have not finished any lessons</li>
% endif
</ul>


</%def>


