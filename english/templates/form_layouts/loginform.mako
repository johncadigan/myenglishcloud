## add_video.mako
<%inherit file="layout.mako"/>

<%def name="page_title()">

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
<%include file="toolbar.mako" args="groupname=group, current='lesson_index', user='${username}', flashcard_deck=flashcards"/>
</%def>

<%def name="authform(name, title, **kw)">
%if name in providers:
<form id="${name}" action="${login_url(request, name)}" method="post">
    % for k, v in kw.items():
<input type="hidden" name="${k}" value="${v}" />
    % endfor
</form>
% else:
<form id="${name}" method="post">
</form>
% endif
<input type="hidden" name="display" value="popup" />
</%def>


<%def name="sidebar()">


${authform('facebook', 'Login with Facebook',
scope='email,publish_stream,read_stream,create_event,offline_access')}

${authform('google', 'Login with Google',
use_popup='false',
openid_identifier='google.com')}

<span class='container'>
<a id='facebook-btn' class="btn btn-large btn-primary col-lg-6  col-md-6 col-sm-6 col-xs-6" href="#">
  <i class="icon-facebook"></i>	Login with Facebook</a><br><br>
<button id='google-btn' class="btn btn-large btn-danger col-lg-6  col-md-6 col-sm-6 col-xs-6" href="#">
  <i class="icon-google-plus"></i> Login with Google</button>
</span>

<%doc>
${authform('github', 'Login with Github')}
${authform('twitter', 'Login with Twitter')}
${authform('bitbucket', 'Login with Bitbucket')}

${authform('yahoo', 'Login with Yahoo',
oauth='true',
openid_identifier='yahoo.com')}
${authform('live', 'Login with Windows Live')}
</%doc>

<script>
$('#facebook-btn').click(function() {
	$('#facebook').submit();
});

$('#google-btn').click(function() {
	$('#google').submit();
});
</script>

</%def>

<%def name="body()">

%if form.errors.has_key('whole_form'):
	%for error in form.errors.get('whole_form'):
		<p class="field_error">${error}</p>
	%endfor
%endif

<form method="POST" action="${action}" accept-charset="utf-8">
<fieldset>
<legend>${title}</legend>

<table border="0" cellspacing="0" cellpadding="2">
%for index, field in enumerate(form):
			<tr class="${['odd', 'even'][index % 2]}">
				<td class="label_col">${field.label} 
				%if field.flags.required:
					<span class="required_star">*</span>
				%endif
				</td>
				<td class="field_col">${field}
					%if field.description:
						<span class="help_text">${field.description}</span>
					%endif
					%for error in field.errors:
						<span class="field_error">${error}</span>
					%endfor
				</td>
			</tr>
%endfor
	</table>
	<input type="submit" name="submit" value="Submit" />
</form>
<br><br>
<ul class='list-inline'>
% if action != 'login':
<a href="${request.route_path('login')}">Login</a>
% endif
% if action != 'register':
<li><a href="${request.route_path('register')}">Create an Account</a></li>
% endif
% if action != 'forgot':
<li><a href="${request.route_path('forgot')}">Forgot my Password</a></li>
% endif
</ul>
</%def>
