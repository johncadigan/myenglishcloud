## add_vocab_box.mako

<%page args="vocab_items, error"/>

<%def name='add_vocab_box(vocab_items, error)'>

%if vocab_items:
<div class='bubble-container' id='add-vocab-box'>
	<div class='inside-bubble'>
<form id='Add-Vocab' method=POST>
<fieldset>
%if error:
<span class='label label-important'>${error}</span><br>
%endif
%for vocab_item in vocab_items:
	%if vocab_item.has_key('translation'):
	<span class='label label-info'>${vocab_item['pos']}</span>
	<span><strong>${vocab_item['form']}</strong></span><br>
        <span><small>eg: ${' ' +vocab_item['example_sentence']}</small></span>
	<input type="text" name="${vocab_item['id']}" value="${vocab_item['translation']}">
	%else:
	<span class='label label-info'>${vocab_item['pos']}</span>		
	<span><strong>${vocab_item['form']}</strong></span><br>
        <span><small>eg: ${' ' +vocab_item['example_sentence']}</small></span>
	<input type="text" name="${vocab_item['id']}">
	%endif 
	<br>
%endfor
%if language == 'your language':
<h4><a href="${request.route_path('login')}">Login</a> to add flashcards</h4>
%else:
</fieldset>
<button type="submit" name="add" class="btn btn-info">
                <i class="icon-plus icon-large"></i> Add Flashcards
</button><br>
with translations in your language
%endif
</span>
</form>
</div>
</div>
%endif
</%def>

${add_vocab_box(vocab_items, error)}


