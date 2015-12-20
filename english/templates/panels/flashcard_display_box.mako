##card_display_box.mako

<%page args="cardinfo, current"/>

<%def name='display_flashcard(cardinfo, current)'>

<div class="row bubble-container add-vocab-box">
	<div class="flashcard-picture col-lg-3 col-md-3 col-sm-3 col-xs-3">
		<img class="img-responsive" src=${request.static_url("english:/static/uploads/pictures/{0}.jpeg".format(cardinfo['picturename']))}>
	</div>
	<div class="flashcard-info col-lg-6 col-md-6 col-sm-6 col-xs-6">
		<ul class="translations list-inline lead">
		<li><h2>${cardinfo['answer']}</h2></li>
		</ul>
		<span class="label label-large label-info ">
		${cardinfo['pos']}
		</span>
		<span class="row sentence">
		<h2>${cardinfo['sentence']}</h2>
		</span>
		<span class="row block">
		</span>
	</div>
%if cardinfo.has_key('cardid'):
<form class='add-vocab' method=POST>
<input type="hidden" class='vocab-len' value="${cardinfo['len']}" id="vocab_len" name="vocab_items"></input>
<input type="hidden" value="${cardinfo['cardid']}" id="vocab_items" name="vocab_items"></input>
<button type="submit" id="">Add Flashcard</button>
</form>
%else:
<h4><a href=${request.route_url('login')}>Login</a> to add flashcards</h4>
%endif
</div>
</%def>

${display_flashcard(cardinfo, current)}

