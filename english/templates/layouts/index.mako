## index.mako
<%inherit file="complex_layout.mako"/>

<%page cached="True"/>

<%!
    import markupsafe
    def br(text):
        return text.replace('\n', markupsafe.Markup('<br />'))
%>


<%def name="page_title()">
Classroom
</%def>

  <%def name="styleSheetIncludes()">

  </%def>

  <%def name="styleSheet()">

  </%def>

  <%def name="javascriptIncludes()">
<script src="${request.static_url('english:/static/js/bootstrap-rating-input-master/src/bootstrap-rating-input.js')}"></script
   <script src="${request.static_url('english:/static/js/jquery.form.js')}"></script>
  </%def>

  <%def name="javascript()">

	  
  </%def>

  <%def name="documentReady()">
var difficulty_options = { 
        target:  '#Difficulty-Rating',   // target element(s) to be updated with server response  
        url:  "${request.route_url('rate_difficulty', cid=debut_content['cid'])}",
        type: 'post'  
    };  
    $('#Difficulty-Rating').submit(function() {  
        $(this).ajaxSubmit(difficulty_options); 
        return false; 
    });
    var quality_options = { 
        target:  '#Quality-Rating',   // target element(s) to be updated with server response  
        url:  "${request.route_url('rate_quality', cid = debut_content['cid'])}",
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
  </%def>

<%def name="navbar()">
<%include file="toolbar.mako" args="groupname=group, current='lesson_index', user='${username}', flashcard_deck=flashcards"/>
</%def>

<%def name="sidebar()">
<div class='visible-md visible-lg'>
##<%include file="scoreboard_box.mako" args="scoreboard=scoreboard, rank=rank"/>
</div>
</%def>
   
 <%def name="body()">

%if debut_content['type'] == 'lesson':
         <%include file="lesson_display_box.mako" args="content=debut_content"/>
%elif debut_content['type'] == 'reading':
	<%include file="reading_display_box.mako" args="content=debut_content"/>
%else:
<%include file="thin_content_box.mako" args="content=links[0]"/>
%endif

</%def>

<%def name="bottom()">   
<h2 class='span12 text-center'> Recently Added Lessons</h2>
<br><br><br>
%for link in links:    
   <%include file="thin_content_box.mako" args="content=link"/>
%endfor



</%def>
