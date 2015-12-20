## reply.mako
<%page args="reply, side, group"/>

<%!
    import markupsafe
    def br(text):
        return text.replace('\n', markupsafe.Markup('<br />'))
%>

<%def name='create_reply(reply, side, group)'>


<div class="post-container row" class="reply-${side}" id="r${reply['id']}-reply-to-${reply['parent_id']}"><!--/div3--> 			

%if side=='right':
			<ul class='post-user  col-lg-1 col-md-1 col-sm-1 col-xs-1 list-unstyled' class="reply-user-${side}" id="user-${reply['user']['id']}">
				<li class='user-picture'>
		<img src="${request.static_url('english:/static/uploads/pictures/{0}.thumb'.format(reply['user']['profile_picture']))}">				
				</li>
				<li class='user-country-flag'>
		<img class='img-responsive' src="${request.static_url('english:/static/images/flags/32/{0}'.format(reply['user']['country_pic']))}">
				</li>
			  </ul>
			<div class="post-text-box inside-bubble  col-lg-10 col-md-10 col-sm-10 col-xs-10">
                	  <span class="post-text  col-lg-11 col-md-11 col-sm-11 col-xs-11">
                              ${reply['content'] | br}


			   <br></br><small>
			   <span class='user-name'> 
                	   --${reply['user']['name']}
			   </span>
			   </small>
                          </span>
			  <span class=" col-lg-1 col-md-1 col-sm-1 col-xs-1">
			  <i class="icon-comments-alt icon-3x text-info"></i>
			  </span>

			  <span class='post-footer  col-lg-12 col-md-12 col-sm-12 col-xs-12 row'>
			        %if group == 'admin': 
                                <span class='delete-post  col-lg-2 col-md-2 col-sm-2 col-xs-2'><small>
			  <a href="${request.route_url('delete_post', post_id=reply['id'], post_type ='reply')}">Delete</a>				
				</small></span>
				%endif				
				<span class ="date-time"><small>${reply['time']}</small></span>
				<span class="reply-prompt col-lg-offset-2 col-md-offset-2 col-sm-offset-2"><small>Reply to this post</small></span>		
			  </span>
                	</div>

%else:
			<div class="post-text-box inside-bubble  col-lg-offset-1 col-md-offset-1 col-sm-offset-1 col-lg-10 col-md-10 col-sm-10 col-xs-10">
                	  
			<span class=" col-lg-1 col-md-1 col-sm-1 col-xs-1">
			  <i class="icon-comments icon-3x text-info"></i>
			  </span>
			 <span class="post-text  col-lg-11 col-md-11 col-sm-11 col-xs-11">
                              ${reply['content'] | br}
                          
			   <br></br><small>
			   <span class='user-name'> 
                	   --${reply['user']['name']}
			   </span>
			   </small>
                          </span>

			  <span class='post-footer  col-lg-12 col-md-12 col-sm-12 col-xs-12'>
			        %if group == 'admin': 
                                <span class='delete-post  col-lg-2 col-md-2 col-sm-2 col-xs-2'><small>
			  <a href="${request.route_url('delete_post', post_id=reply['id'], post_type ='reply')}">Delete</a>				
				</small></span>
				%endif				
				<span class ="date-time"><small>${reply['time']}</small></span>
				<span class="reply-prompt col-lg-offset-2 col-md-offset-2 col-sm-offset-2"><small>Reply to this post</small></span>		
			  </span>
                	</div>
			<ul class='post-user col-lg-1 col-md-1 col-sm-1 col-xs-1 list-unstyled' class="reply-user-${side}" id="user-${reply['user']['id']}">
				<li class='user-picture'>
		<img src="${request.static_url('english:/static/uploads/pictures/{0}.thumb'.format(reply['user']['profile_picture']))}">				
				</li>
				<li class='user-country-flag'>
		<img src="${request.static_url('english:/static/images/flags/32/{0}'.format(reply['user']['country_pic']))}">
				</li>
				
			  </ul>




%endif
<form method=POST class='profile_form' id="form_r${reply['id']}">
<input type="hidden" name="profile" value="${reply['user']['id']}">
<input type="hidden" name="post_type" value="reply">
<input type="hidden" name="post_id" value="${reply['id']}">
</form>
</div><!--/row--><!--/div3-->	

<script>
    
    
    $("#form_r${reply['id']}").submit(function() {  
    profile_options = { 
        target:  "#r${reply['id']}-reply-to-${reply['parent_id']}",   // target element(s) to be updated with server response  
        url:  "${request.route_url('get_profile')}",
        type: 'post'  
    };    

	$(this).ajaxSubmit(profile_options); 
        return false; 
    });
    $(".post-user").click(function() {
	$(this).siblings("#form_r${reply['id']}").submit();
    });
    
</script>







<div class='clear'></div>



</%def>
${create_reply(reply, side, group)}
