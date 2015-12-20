##add_quiz.mako


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
 $('#btnAdd').click(function(event) {
	event.preventDefault();
        var $question = $('#question');
        var num = $('.clonedAddress').length; // there are 5 children inside each address so the prevCloned address * 5 + original
        var newNum = new Number(num + 1);
        var newElem = $question.clone().attr('id', 'word' + newNum).addClass('clonedAddress');
        current = new Number($('#questions').val())
	$('#questions').val(current+1)
        //set all div id's and the input id's
        newElem.children('div').each (function (i) {
            this.id = 'input' + (newNum*5 + i);
        });
        
        newElem.find('input').each (function () {
            this.id = this.id + newNum;
            this.name = this.name + newNum;
        });
	
        newElem.find('#question-number').html('Question '+$('#questions').val());
        if (num > 0) {
            $('.clonedAddress:last').after(newElem);
        } else {
            $question.after(newElem);
        }
            

        $('#btnDel').removeAttr('disabled');
            
        if (newNum == 10) $('#btnAdd').attr('disabled', 'disabled');
    });
    $('#btnDel').click(function(event) {
	event.preventDefault();
	current = new Number($('#questions').val())
	$('#questions').val(current-1)
        $('.clonedAddress:last').remove();
        $('#btnAdd').removeAttr('disabled');
        if ($('.clonedAddress').length == 0) {
            $('#btnDel').attr('disabled', 'disabled');
        }
    });
    $('#btnDel').attr('disabled', 'disabled');

  </%def>

<%def name="navbar()">
<%include file="toolbar.mako" args="groupname=group, current='tag_index', user='${username}', flashcard_deck=flashcards"/>
</%def>

<%def name="sidebar()">

</%def>
   
  <%def name="body()">

% if form:
%if form.errors.has_key('whole_form'):
	%for error in form.errors.get('whole_form'):
		<p class="field_error">${error}</p>
	%endfor
%endif

<form id="content-form" method="POST" accept-charset="utf-8" enctype="multipart/form-data">
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


<span class="lead"> Questions</span>
<div id="question">

<span id='question-number'> Question 1</span>
<div id="input1" style="margin-bottom:4px;" class="input">
Prompt<input id="prompt" type="text" value="" name="prompt"></input>
</div>
<div class='row-fluid'>
<div id="input2" style="margin-bottom:4px;" class="input">
Answer:<br>
<input id="a1text" type="text" value="" name="a1text"></input>
</div>
<div id="input3" style="margin-bottom:4px;" class="input">
Correct<input type='radio' id="a1value" name="a1value" value='true'>
Incorrect<input type='radio' id="a1value" name="a1value" value='false' checked>
</div>
<div id="input4" style="margin-bottom:4px;" class="input">
Answer:<br>
<input id="a2text" type="text" value="" name="a2text"></input>
</div>
<div id="input5" style="margin-bottom:4px;" class="input">
Correct<input type='radio' id="a2value" name="a2value" value='true'>
Incorrect<input type='radio' id="a2value" name="a2value" value='false'checked>
</div>
</div>
<div id="input6" style="margin-bottom:4px;" class="input">
Answer:<br>
<input id="a3text" type="text" value="" name="a3text"></input>
</div>
<div id="input7" style="margin-bottom:4px;" class="input">
Correct<input type='radio' id="a3value" name="a3value" value='true'>
Incorrect<input type='radio' id="a3value" name="a3value" value='false' checked>
</div>
<div id="input8" style="margin-bottom:4px;" class="input">
Answer:<br>
<input id="a4text" type="text" value="" name="a4text"></input>
</div>
<div id="input9" style="margin-bottom:4px;" class="input">
Correct<input type='radio' id="a4value" name="a4value" value='true'>
Incorrect<input type='radio' id="a4value" name="a4value" value='false' checked>
</div>
<div id="input10" style="margin-bottom:4px;" class="input">
Message when correct:<br>
<input id="cmessage" type="textarea" value="" name="cmessage"></input>
</div>
<div id="input11" style="margin-bottom:4px;" class="input">
Message when incorrect:<br>
<input id="icmessage" type="textarea" value="" name="icmessage"></input>
</div>
<br>
<br>
<br>




</div>

<br>
<button id="btnAdd">Add Question</button>
<button id="btnDel">Delete Question</button><br>


<input type="submit" name="submit" value="Submit" ></input>

</form>

%endif





</%def>
