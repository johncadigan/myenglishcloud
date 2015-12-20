##flashcard_search_box.mako

<%page args="user, search, action"/>

<%def name='search_flashcards(user, search, action)'>

<form id='search' method='GET' action=${action}>

<fieldset> 
<legend class='lead'>Search</legend>



<strong>Filter</strong><br>
Word type
<select name = 'lemma_type'>
  %for ltype in [u'Noun',u'Pronoun',u'Adjective', u'Adverb', u'Verb', u'Phrasal Verb', u'Preposition', u'Conjunction', u'Collocation', u'Slang', 'any']:
      %if search['lemma_type'] == ltype:
	<option value=${ltype} selected='selected'>${ltype}</option>          
       %else:
	<option value=${ltype}>${ltype}</option>
       %endif
  %endfor
</select>
<br>
Letter
<select name = 'letter'>
  %for letter in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'any']:
      %if search['letter'] == letter:
	<option value=${letter} selected='selected'>${letter}</option>          
       %else:
	<option value=${letter}>${letter}</option>
       %endif
  %endfor
</select>
<br>

Results
<select name = 'results_limit'>
  %for num in ['15', '30', '45']:
      %if search['results_limit'] == num:
	<option value=${num} selected='selected'>${num}</option>          
       %else:
	<option value=${num}>${num}</option>
       %endif
  %endfor
</select>
<br>


<strong>Order by</strong><br>
<select name = 'order_by'>
  %for word, value in [('Frequency', "frequency"), ('Popularity', 'popularity'), ('Newest', 'recent')]:
      %if search['order_by'] == value:
	<option value=${value} selected='selected'>${word}</option>          
       %else:
	<option value=${value}>${word}</option>
       %endif
  %endfor
</select>
<fieldset> 

<input type="submit" name="submit" value="Search" />
</form>

</%def>

${search_flashcards(user, search, action)}

