## profile_card.mako

<%page args="profile, side, post_info"/>



<%def name='create_profile(profile, side, post_info)'>




<!--/post_profile-->
	   <div class='user-profile row' id="user-profile-${profile['id']}-${post_info['post_type']}-${post_info['post_id']}"><!--/div5-->	     

%if side == 'right':
            <div class='profile-picture col-lg-3 col-md-3 col-sm-3 col-xs-3'><!--/div6-->
	      <img src="${request.static_url('english:/static/uploads/pictures/{0}.thumbnail'.format(profile['profile_picture']))}">				
	     </div><!--/div6-->
	     <div class='inside-bubble profile-information col-lg-6 col-md-6 col-sm-6 col-xs-6'><!--/div7-->	
		<span class='profile-name lead'>${profile['name']}</span><br>
		<ul class='profile-languages list-inline'><strong>Languages: </strong>
		%for language in profile['languages']:
		<li>${language}</li>
		%endfor
		</ul>
		<span class='profile-about'><strong>About me: </strong>${profile['about_me']}</span>
	     </div><!--/div7-->
	     <div class='profile-location col-lg-3 col-md-3 col-sm-3 col-xs-3'><!--/div8-->
		<span class='profile-country-flag'>
		<img src="${request.static_url('english:/static/images/flags/64/{0}'.format(profile['country_pic']))}"><br>
		</span>
		<small><span class='city'> ${profile['city']}, </span>
		<span class='profile-country-name'>${profile['country_name']}</span></small></br>
 	    </div><!--/div8-->
%else:
            <div class='profile-location col-lg-3 col-md-3 col-sm-3 col-xs-3'><!--/div8-->
		<span class='profile-country-flag'>
		<img src="${request.static_url('english:/static/images/flags/64/{0}'.format(profile['country_picture']))}"><br>
		</span>
		<small><span class='city'> ${profile['city']}, </span>
		<span class='profile-country-name'>${profile['country_name']}</span></small></br>
 	     </div><!--/div8-->
	     <div class='inside-bubble profile-information col-lg-6 col-md-6 col-sm-6 col-xs-6'><!--/div7-->	
		<span class='profile-name lead'>${profile['name']}</span><br>
		<ul class='profile-languages list-inline'><strong>Languages: </strong>
		%for language in profile['languages']:
		<li>${language}</li>
		%endfor
		</ul>
		<span class='profile-about'><strong>About me: </strong>${profile['about_me']}</span>
	     </div><!--/div7-->
	     <div class='profile-picture col-lg-3 col-md-3 col-sm-3 col-xs-3'><!--/div6-->
	      <img src="${request.static_url('english:/static/uploads/pictures/{0}.thumbnail'.format(profile['profile_pic']))}">				
	     </div><!--/div6-->	        
%endif





<form method=POST class='profile_form' id="form_p${profile['id']}-${post_info['post_type']}-${post_info['post_id']}">
<input type="hidden" name="profile" value="${profile['id']}">
<input type="hidden" name="post_type" value="${post_info['post_type']}">
<input type="hidden" name="post_id" value="${post_info['post_id']}">
</form>

</div><!--/div5-->

<script>
  
    $("#form_p${profile['id']}-${post_info['post_type']}-${post_info['post_id']}").submit(function() {  
    profile_options = { 
        target:  "#user-profile-${profile['id']}-${post_info['post_type']}-${post_info['post_id']}",   // target element(s) to be updated with server response  
        url:  "${request.route_url('get_post')}",
        type: 'post'  
    };    

	$(this).ajaxSubmit(profile_options); 
        return false; 
    });
    $(".profile-picture").click(function() {
	$(this).siblings("#form_p${profile['id']}-${post_info['post_type']}-${post_info['post_id']}").submit();
    });
    
</script>















</%def>

${create_profile(profile, side, post_info)}

