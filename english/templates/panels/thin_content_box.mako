## content_box.mako

<%page args="content"/>


<%def name='make_box(content)'>
<div class="row bubble-container">
	<div class='col-lg-3 col-md-3 col-sm-3 col-xs-3'>
		<span class='col-lg-3 col-md-3 col-sm-3 col-xs-3'>
		%if content['type'] == 'lesson':
			<i class="fa fa-file-o fa-3x text-info"></i>			
		%elif content['type'] == 'reading':
			<i class="fa fa-book fa-3x text-info"></i>
  		%endif
				
  		</span>
		<span class='col-lg-8 col-md-8 col-sm-8 col-xs-8 inside-bubble'> 
			<small>Tags:</small>
			<ul class='list-inline'>
			%for tag in content['tags']:
				<li><a href="${request.application_url}/tags/${tag}"><small> ${tag} </small></a></li>
			%endfor
			</ul>
		</span>
		<ul class='list-inline col-lg-12 col-md-12 col-sm-12 col-xs-12'>
			<li>Views: ${content['views']}</li>
			<li><i class="fa fa-bolt fa-2x"></i>: ${content['cflashcards']}</li> 
			<li>
			%if content['finished']:
  				<i class="fa fa-check-square-o fa-2x"></i> 
 			%else:
  				<i class="fa fa-square-o fa-2x"></i>
  			%endif
  			</li>
  		</ul>
   		<%include file="difficulty_rating_box.mako" args="difficulty_score=content['vote']['d_score'], difficulty_vote_enabled='disabled', display=6"/>
   		<%include file="quality_rating_box.mako" args="quality_score=content['vote']['q_score'], quality_vote_enabled='disabled', display=6"/>
  	</div>
   	<div class='inside-bubble col-lg-9 col-md-9 col-sm-9 col-xs-9 row'>	   
   		<span class='lesson-picture col-lg-2 col-md-2 col-sm-2 col-xs-2'>
		<img class='img-responsive' src="${request.static_url('english:/static/uploads/pictures/256x256/{0}.jpeg'.format(content['picture']))}">
    		</span>
    	<span>
		<a href="${'{0}/{1}/{2}/{3}'.format(request.application_url, content['type'], content['cid'], content['url'])}"><h2>${content['title'] + ': '}</h2></a>
    		<span>${content['description']}</span><br>
   	</span>
   	</div>
</div><!--/row--><br>
</%def>

${make_box(content)}
