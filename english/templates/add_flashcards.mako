##add_flashcards.mako

%if show:
<%include file="add_vocab_box.mako" args="vocab_items=vocabulary, language=language, error=vb_error, action=''"/>

%else:
<h1>${response}</h1>
%endif



