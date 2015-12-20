## add_video.mako
<%inherit file="layout.mako"/>

<%def name="page_title()">
hello
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
<%include file="toolbar.mako" args="groupname=group, current='lesson_index', user=username"/>
</%def>

<%def name="sidebar()">

</%def>


<%def name="body()">
%if form.errors.has_key('whole_form'):
	%for error in form.errors.get('whole_form'):
		<p class="field_error">${error}</p>
	%endfor
%endif

<form method="POST" accept-charset="utf-8">
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
</%def>
