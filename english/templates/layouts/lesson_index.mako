## lesson_index.mako
<%inherit file="content_layout.mako"/>

<%def name="page_title()">
   ${content['title']}|Lesson
  </%def>

  <%def name="styleSheetIncludes()">


  </%def>

  <%def name="styleSheet()">
	
  </%def>

  <%def name="javascriptIncludes()">
  <script src="${request.static_url('english:/static/uploads/quizzes/{0}.js'.format(content['quiz']))}"></script>
	
  </%def>

  <%def name="javascript()">

  </%def>

<%def name="documentReady()">

</%def>


<%def name="sidebar()">
<%include file="add_vocab_box.mako" args="vocab_items=vocabulary, error=vb_error, language=language"/>
</%def>


<%def name="body()">

<%include file="lesson_display_box.mako" args="content=content"/>


</%def>

<%def name="bottom()">

<div>

<a name="quiz"></a>

	<div id="slickQuiz" class="col-md-6">
	        <h1 class="quizName"><!-- where the quiz name goes --></h1>	
	        <div class="quizArea">
            		<div class="quizHeader">
                	<!-- where the quiz main copy goes -->
               		 <a class="button startQuiz" href="">Get Started!</a>
            		</div>
            	<!-- where the quiz gets built -->
        	</div>
	
        	<div class="quizResults">
            		<h3 class="quizScore">You Scored: <span><!-- where the quiz score goes --></span></h3>
        	</div>
	</div>

	<div id='point-results' class='lead'>
		<form id="point-form" method=POST>
		<input type="hidden" name="activity_type" value='quiz'>
		<input type="hidden" name="activity_id" value=${content['quiz']}>
		<input type="submit" name="Report" value="Save">
		</form>
	</div>
</div>

<div class='col-lg-12'>
		<div id='posts'>
			<a name="questions"></a>
			<%include file="comments.mako" args="posts=questions, groupname=group, section='Questions', cid=content['cid']"/>
			<a name="comments"></a>
			<%include file="comments.mako" args="posts=comments, groupname=group, section='Comments', cid=content['cid']"/>
		</div>

	</div>

	%if form:
		%if form.errors.has_key('whole_form'):
			%for error in form.errors.get('whole_form'):
			<p class="field_error">${error}</p>
			%endfor
		%endif

	<form method="POST" accept-charset="utf-8" id='frm' action=${request.route_url('submit_comment', cid = content['cid'])}>
	<fieldset>
	<legend id='form_title'>${form_title}</legend>
	<table border="0" cellspacing="0" cellpadding="2">
	%for index, field in enumerate(form):
			<tr class="${field.short_name}">
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
		<input type="submit" class='btn' name="submit" value="Submit" />
	</fieldset>
	</form>
	%else:
	<h4><a href="${request.route_path('login')}">Login</a> to post a comment</h4>
	%endif
</div>


</%def>

