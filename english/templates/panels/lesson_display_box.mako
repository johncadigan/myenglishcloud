## lesson_display_box.mako

<%page args="content"/>


<%def name='create_lesson_display_box(content)'>

<div class="col-lg-12 col-xs-12 col-sm-12 col-md-12"><!--/div1-->
	<h1 class='text-center'>${content['title']}</h1>
	<div class='container'><!--/div2-->
                <div>
		<div class="embed-responsive embed-responsive-16by9">
        		${content['video'] | n}
		</div>
		<br>
		<div class="content-info-box container col-lg-12  col-md-12 col-sm-12 col-xs-12"><!--/div3-2-->
			<p>			
			<a id='facebook-btn' type="button" class="btn btn-primary btn-lg" href="#">
  			<i class="fa fa-facebook fa-1x"></i>
			Share </a>
			
			<a id='youtube-btn' type="button" class="btn btn-danger btn-lg" href=" http://www.youtube.com/channel/UC6VUmQxuSxhjCbNLfeQPxog">
  			<i class="fa fa-youtube fa-1x"></i>
			Subscribe </a>
		
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

			<a class='btn btn-default btn-lg col-lg-offset-1 col-md-offset-1 col-sm-offset-1' href="${request.route_url('lesson_index', curl = content['url'], cid =content['cid'])+'#quiz'}">
  			<i class="fa fa-edit fa-1x"></i> 	
			Quiz
			</a>
			<a class='btn btn-default btn-lg' href="${request.route_url('lesson_index', curl = content['url'], cid = content['cid'])+'#questions'}">
			<i class="fa fa-question fa-1x"></i> 
			Questions
			</a></span>
			<a class='btn btn-default btn-lg' href="${request.route_url('lesson_index', curl = content['url'], cid = content['cid'])+'#comments'}">
 			<i class="fa fa-comment-o fa-1x"></i> 
			Comments
			</a>
			</p>
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
<script>
  $(document).ready(function(){
    // Target your .container, .wrapper, .post, etc.
    $("#video").fitVids();
  });
</script>

<script type="text/javascript">
function fbs_click(width, height) {
    var leftPosition, topPosition;
    //Allow for borders.
    leftPosition = (window.screen.width / 2) - ((width / 2) + 10);
    //Allow for title and status bars.
    topPosition = (window.screen.height / 2) - ((height / 2) + 50);
    var windowFeatures = "status=no,height=" + height + ",width=" + width + ",resizable=yes,left=" + leftPosition + ",top=" + topPosition + ",screenX=" + leftPosition + ",screenY=" + topPosition + ",toolbar=no,menubar=no,scrollbars=no,location=no,directories=no";
    u=location.href;
    t=document.title;
    window.open('http://www.facebook.com/sharer.php?u='+encodeURIComponent(u)+'&t='+encodeURIComponent(t),'sharer', windowFeatures);
    return false;
}


$('#facebook-btn').click(function(){
fbs_click(400,300);
});


</script>





</%def>

${create_lesson_display_box(content)}

