<%inherit file="layout.mako"/>


<%def name="page_title()">
  Lessons
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

<h1>My Content</h1>
<h3>Click to edit your content</h3>

<h3>Contents</h3>
<ul id="lessons" class="row-fluid">
% if lessons:
  % for lesson in lessons:

<div class="span4"> 

%if lesson['type'] == 'lesson':
<a href="${request.application_url}/edit_lesson/${lesson['id']}">${lesson['title']}    </a>
%elif lesson['type'] == 'reading':
<a href="${request.application_url}/edit_reading/${lesson['id']}">${lesson['title']}    </a>
%endif
<strong>${lesson['type']}</strong><br>  
${lesson['description']}
</div>

  % endfor
% else:
  You have no lessons
% endif
</ul>



<h3>Flashcards</h3>
<ul id="flashcards" class="inline">
% if myflashcards:
  % for flashcard in myflashcards:
  <li><a href="${request.application_url}/edit_flashcard/${flashcard['id']}">${flashcard['form']}<a></li>
  % endfor
% else:
  You have no flashcards
% endif
</ul>


  </%def>
