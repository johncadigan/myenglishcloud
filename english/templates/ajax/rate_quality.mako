## rate_quality.mako

%if show:
<%include file="quality_rating_box.mako" args="quality_score=quality, quality_vote_enabled=quality_vote, display=12"/>

%else:
<h1>Access Denied</h1>
%endif
