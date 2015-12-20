## difficulty_rating_box.mako

<%page args="difficulty_score, difficulty_vote_enabled, display"/>

<%def name='make_box(difficulty_score, difficulty_vote_enabled, display)'>

<span id='Difficulty-Box' class='${"col-lg-{0} col-md-{0} col-sm-{0} col-xs-12".format(display)}'>
	<form id='Difficulty-Rating' class='Star-Form' method='POST'>
		<span class="rating-criterium">
    		<span >Difficulty: ${str(difficulty_score)[0:4]}</span><br/>
%if difficulty_vote_enabled != "disabled":
                <input type="number" data-max="5" data-min="1" name="Difficulty-Rating" id="some_id" class="rating" data-active-icon="fa-star" data-icon-lib="fa fa-2x" data-inactive-icon="fa-star-o" value="${int(difficulty_score)}"/>
		<input type="submit" name="submit" value="Vote" class='vote-button'/>

%elif difficulty_vote_enabled == "disabled":
		${"<i class='fa fa-2x fa-star'></i>"*int(difficulty_score) + "<i class='fa fa-2x fa-star-o'></i>"*(5-int(difficulty_score))| n} 
%endif
		</span>
		
	</form>
</span>


</%def>

${make_box(difficulty_score, difficulty_vote_enabled, display)}
