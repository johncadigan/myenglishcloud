<%inherit file="layout.mako"/>


<%def name="page_title()">
  Add Lemma
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
        var $word = $('#word');
        var num = $('.clonedAddress').length; // there are 5 children inside each address so the prevCloned address * 5 + original
        var newNum = new Number(num + 1);
        var newElem = $word.clone().attr('id', 'word' + newNum).addClass('clonedAddress');
        current = new Number($('#vocab_items').val())
	$('#vocab_items').val(current+1)
        //set all div id's and the input id's
        newElem.children('div').each (function (i) {
            this.id = 'input' + (newNum*5 + i);
        });
        
        newElem.find('input').each (function () {
            this.id = this.id + newNum;
            this.name = this.name + newNum;
        });
 
	newElem.find('select').each (function () {
            this.id = this.id + newNum;
            this.name = this.name + newNum;
        });
        
        if (num > 0) {
            $('.clonedAddress:last').after(newElem);
        } else {
            $word.after(newElem);
        }
            

        $('#btnDel').removeAttr('disabled');
            
        if (newNum == 10) $('#btnAdd').attr('disabled', 'disabled');
    });
    $('#btnDel').click(function(event) {
	event.preventDefault();
	current = new Number($('#vocab_items').val())
	$('#vocab_items').val(current-1)
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
${freq}
<br>
${senses}
<br>
%for picture in pictures:
	<span class="lead">${picture}</span>
	<img class="img-responsive" src=${request.static_url("english:/static/to_upload/images/{0}.jpg".format(picture))}></img>
%endfor
</%def>
   
<%def name="body()">
<form method="POST" accept-charset="utf-8" action='' enctype="multipart/form-data">
<input type="hidden" value="1" id="vocab_items" name="vocab_items"></input>
<span class="lead"> ${wordform}</span>

<div id="word">

<div id="input1" style="margin-bottom:4px;" class="input">
Form<input id="form" type="text" value="${wordform}" name="form"></input>
</div>

<div id="input2" style="margin-bottom:4px;" class="input">
Example sentence with word the same as form<br>
<input id="example_sentence" type="text" value="" name="example_sentence"></input>
</div>

<div id="input3" style="margin-bottom:4px;" class="input">
<select id="pos" name="pos">
<option selected="" value="Noun">Noun</option>
<option value="Pronoun">Pronoun</option>
<option value="Adjective">Adjective</option>
<option value="Adverb">Adverb</option>
<option value="Verb">Verb</option>
<option value="Phrasal Verb">Phrasal Verb</option>
<option value="Preposition">Preposition</option>
<option value="Conjunction">Conjunction</option>
<option value="Collocation">Collocation</option>
<option value="Slang">Slang</option>
</select>
</div>

<div id="input4" style="margin-bottom:4px;" class="input">
<select id="picloc" name="picloc">
%for pic in pictures:
<option value="${pic}">${pic}</option>
%endfor
<option selected="" value="other">other</option>
</select>
</div>


<div id="input5" style="margin-bottom:4px;" class="input">
<input id="picture" type="file"name="picture"></input>
</div>

</div>

<br>
<button id="btnAdd">Add Word</button>
<button id="btnDel">Delete Word</button><br>


<input type="submit" name="submit" value="Submit" ></input>
</form>
</%def>
