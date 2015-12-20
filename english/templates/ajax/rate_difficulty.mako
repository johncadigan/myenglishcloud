## rate_difficulty.mako

%if show:
<%include file="difficulty_rating_box.mako" args="difficulty_score=difficulty, difficulty_vote_enabled=difficulty_vote, display = 12"/>

%else:
<h1>Access Denied</h1>
%endif
