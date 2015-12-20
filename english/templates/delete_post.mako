## delete_post.mako
<%inherit file="layout.mako"/>

<%def name="page_title()">
  Delete post
</%def>

  <%def name="styleSheetIncludes()">
   <link href="${request.static_url('english:/static/rating/jquery.rating.css')}" media="screen" rel="stylesheet" type="text/css">
  </%def>

  <%def name="styleSheet()">
   .lesson-container {
background-color: #E0EEEE;
margin: 0px auto;
padding-right:24px;
padding-left:24px;
padding-top: 24px;
padding-bottom: 10px;
border-radius:20px;
}
.inside-box {
background-color: #FFFFFF;
padding-right:10px;
padding-left:10px;
padding-top: 10px;
padding-bottom: 10px;
border-radius: 10px;
}
  </%def>

  <%def name="javascriptIncludes()">

  </%def>

  <%def name="javascript()">

	  
  </%def>

  <%def name="documentReady()">


  </%def>

<%def name="navbar()">
<%include file="toolbar.mako" args="groupname=group, current='lesson_index', user='${username}'"/>
</%def>

<%def name="sidebar()">

</%def>
   
<%def name="body()">

${post}
<br>
by
${postowner}
<form method='POST'>
<input type="checkbox" name="delete" value="delete">Delete post<br>
<input type="submit" class='btn' name="submit" value="Submit" />
</form>


</%def>
