##comment.mako

<%page args="comment, group"/>

<%!
    import markupsafe
    def br(text):
        return text.replace('\n', markupsafe.Markup('<br />'))
%>



<%def name='create_comment(comment, group)'>
<div class="post-container row" id="c${comment['id']}-reply-to-${comment['id']}"><!--/div1-->	
	<ul class="post-user col-lg-1 col-md-1 col-sm-1 col-xs-1 list-unstyled" id="user-${comment['user']['id']}">
		<li class='user-picture'>
			<img class="img-responsive" src="${request.static_url('english:/static/uploads/pictures/{0}.thumb'.format(comment['user']['profile_picture']))}">				
		</li>				
		<li class='user-country-flag'>
			<img src="${request.static_url('english:/static/images/flags/32/{0}'.format(comment['user']['country_pic']))}">
		</li>								
	</ul>
	<div class="post-text-box inside-bubble col-lg-8 col-md-11 col-sm-11 col-xs-11"><!--/div2-->        	  
		<span class="post-text col-lg-11 col-md-11 col-sm-11 col-xs-11">
                              ${comment['content'] | br}  
			<br></br>
			<small>
				<span class='user-name'> 
		                	--${comment['user']['name']}
				</span>
			</small>
		</span>
               	<span class="col-lg-1">
			%if comment['comment_type'] == 'C':
				<i class="icon-comment-alt icon-3x text-info"></i>
				%elif comment['comment_type'] == 'Q':
				<i class="icon-question-sign icon-3x text-info"></i>
			%endif
		</span>
		<span class='post-footer col-lg-12 col-md-12 col-sm-12 col-xs-12'>
			%if group == 'admin': 
				<span class='delete-post col-lg-2 col-md-2 col-sm-2 col-xs-2'>
					<small>
					<a href="${request.route_url('delete_post', post_id=comment['id'], post_type ='comment')}">Delete</a>				
					</small>
				</span>
			%endif				
			<span class ="date-time">
				<small>
					${comment['time']}
				</small>
			</span>
			<span class="reply-prompt col-lg-offset2 col-md-offset-2 col-sm-offset-2">
				<small>
					Reply to this post
				</small>
			</span>		
		</span>
	</div><!--/div2-->
	<form method=POST class='profile_form' id="form_c${comment['id']}">
		<input type="hidden" name="profile" value="${comment['user']['id']}">
		<input type="hidden" name="post_type" value="comment">
		<input type="hidden" name="post_id" value="${comment['id']}">
	</form>
</div><!--/row-div1-->


<script>
    
    
    $("#form_c${comment['id']}").submit(function() {  
    profile_options = { 
        target:  "#c${comment['id']}-reply-to-${comment['id']}",   // target element(s) to be updated with server response  
        url:  "${request.route_url('get_profile')}",
        type: 'post'  
    };    

	$(this).ajaxSubmit(profile_options); 
        return false; 
    });
    $(".post-user").click(function() {
	$(this).siblings("#form_c${comment['id']}").submit();
    });
    
</script>



</%def>
${create_comment(comment, group)}
