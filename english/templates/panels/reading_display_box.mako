## reading_display_box.mako

<%page args="content"/>

<%!
    import markupsafe
    def br(text):
        return text.replace('\n', markupsafe.Markup('<br />'))
%>

<%def name='create_reading_display_box(content)'>

<div class="bubble-container col-lg-12 col-xs-12 col-sm-12 col-md-12"><!--/div1-->
	<h1 class='text-center'>${content['title']}</h1>
	<div class='span10 inside-bubble' id="text">
	        ${content['text'] | br}
		<br></br>
		<strong><small>Sources</small></strong><br>
		%for source in content['sources']:
		%if source['author']:
		<small>${source['author']}, "<a href="${source['url']}">${source['title']}</a>" - <i>${source['source']}</i>; ${source['date']}</small><br>
		%else:
		<small>"<a href="${source['url']}">${source['title']}</a>" - <i>${source['source']}</i>; ${source['date']}</small><br>
		%endif
		%endfor
	</div>
		
		<br>
		<div class="content-info-box col-lg-12  col-md-12 col-sm-12 col-xs-12"><!--/div3-2-->
			<div class="row">
			<span class="share-content-box col-lg-3 col-md-4 col-sm-4 col-xs-4">
				<span class = 'row'>
				<a id='facebook-btn' class="btn btn-primary col-lg-5  col-md-5 col-sm-5 col-xs-5" href="#">
  				<span class="icon-stack">
  				<i class="icon-check-empty icon-stack-base"></i>
  				<i class="icon-facebook"></i> 
				</span>	
				Share </a>
				<span class = " col-xs-1 col-lg-1"></span>
				<a id='youtube-btn' class="btn btn-danger col-lg-6 col-md-6 col-sm-6 col-xs-6 col-lg-offset-1 col-md-offset-1 col-sm-offset-1" href=" http://www.youtube.com/subscription_center?add_user=MyEnglishCloud">
  				<span class="icon-stack">
  				<i class="icon-check-empty icon-stack-base"></i>
  				<i class="icon-youtube"></i> 
				</span>	
				Subscribe </a>
				</span>
<%doc>
				<span class="icon-stack icon-2x">
				<i class="icon-check-empty icon-stack-base"></i>
				<i class="icon-twitter"></i>
				</span>
				<span class="icon-stack icon-2x">
				<i class="icon-check-empty icon-stack-base"></i>
				<i class="icon-google-plus"></i>
				</span>
</%doc>
			</span>
			<span class='container col-lg-9 col-md-12 col-sm-12 col-xs-8'>
			<ul class="nav-justified">
			<li class='lead'><a href="${request.route_url('reading_index', curl = content['url'], cid =content['cid'])+'#quiz'}">
			<h3>Quiz</h3>
			</a></li>
			<li class='lead'><a href="${request.route_url('reading_index', curl = content['url'], cid = content['cid'])+'#questions'}">
			 <h3>Questions</h3>
			</a></li>
			<li class='lead'><a href="${request.route_url('reading_index', curl = content['url'], cid = content['cid'])+'#comments'}">
			<h3>Comments</h3>
			</a></li>
			</ul>
			</span>
			</div>
			<div class="row">  			
			<span class="col-lg-3 col-md-4 col-sm-4 col-xs-4 inside-bubble">
 			<i class="icon-tags icon-2x"></i><span class="lead"> Tags:</span><br>
   				<ul class="list-inline  ">
   				%for tag in content['tags']:
   					<li class='lead'><a href="${request.application_url}/tags/${tag}">${tag}</a></li>
   				%endfor
   				</ul>
			</span>
			<ul class="list-inline col-lg-3 col-md-3 col-sm-3 col-xs-4">
  				<li class="lead">Views: ${content['views']}</li>
 				<li class="lead">Flashcards: ${content['cflashcards']}</li>
  				<li class="lead">Finished:
  				%if content['finished']:
  					<i class="icon-check"></i>
  				%else:
  					<i class="icon-check-empty"></i>
  				%endif
  				</li>
  			</ul>
			
 			<span class="col-lg-6 col-md-2 col-sm-2 col-xs-4"> 
			<%include file="difficulty_rating_box.mako" args="difficulty_score=content['vote']['d_score'], difficulty_vote_enabled=content['vote']['d_vote'], display=6"/>
			<%include file="quality_rating_box.mako" args="quality_score=content['vote']['q_score'], quality_vote_enabled=content['vote']['q_vote'], display=6"/>
  			</span>
			
				
			
			</div>
		</div>
	</div>
</div>

</%def>

${create_reading_display_box(content)}

