## comments.mako
<%page args="posts, groupname, section, cid"/>

<%def name='comment_section(posts, groupname, section, cid)'>

<div class= 'section' id='${section}' ><!--/div1-->
	<h2>${section}</h2>
	%if len(posts) > 0:
		% for comment in posts:
		<div class='conversation-holder'><!--/div2-->
			<div class='post-holder bubble-container' id="comment-container-${comment['id']}"><!--/div3-->
				<%include file="comment.mako" args="comment=comment, group=groupname"/>	
      			</div><!--/div3-->
		<div class='clear'></div>
		<br>
		%if len(comment['children']) > 0:
			%for index, child in enumerate(comment['children']):
				%if index % 2 != 0:		
     				<div class='post-holder bubble-container offset1' id="comment-container-${comment['id']}-${child['id']}"><!--/div3-2-->
					<%include file="reply.mako" args="reply=child, side='right', group=groupname"/>        		
				</div>
				%else:
				<div class='post-holder bubble-container offset1' id="comment-container-${comment['id']}-${child['id']}"><!--/div3-3-->
					<%include file="reply.mako" args="reply=child, side='left', group=groupname"/>		
				</div>

				%endif
		<br>
			%endfor
		%endif
		</div><!--/div2-->
		<br>
		%endfor 
		%if cid != 0:
			<button class="btn btn-info" id="viewAll${section}">See all ${section}</button>
			<form method=POST id="form_${cid}-${section}">
				<input type="hidden" name="content_id" value="${cid}">
				<input type="hidden" name="section" value="${section}">
			</form>
		%endif


<script>
 $("#form_${cid}-${section}").submit(function() {  
    post_options = { 
        target:  "#${section}",   // target element(s) to be updated with server response  
        url:  "${request.route_url('get_all_posts')}",
        type: 'post'  
    };    

	$(this).ajaxSubmit(post_options); 
        return false; 
    });
    $("#viewAll${section}").click(function() {
	$(this).siblings("#form_${cid}-${section}").submit();
    });
</script>

	%elif len(posts) == 0:
	<h5>There are no ${section}</h5>
	%endif
</div>


</%def>
${comment_section(posts, groupname, section, cid)}


<script type="text/javascript">
$('.post-footer').hide();
    $('.post-container').hover(function() {
        $(this).children().children('.post-footer').show();
        },function () {
        $(this).children().children('.post-footer').hide();
        });
    $(".reply-prompt").click(function() {
    data = this.parentNode.parentNode.parentNode.id;
    $(this).parents('.post-holder').append($("#frm"));
    $(this).parent('.post-footer').hide();
    $('#frm input[name=post_type]').val('comment');
    $('input[name=parent_comment]').val(data);
    $('.post_type').hide();
    $('#form_title').hide();      
    });
</script>
