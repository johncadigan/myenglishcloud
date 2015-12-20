## add_comment.mako


%if show:
<div id='posts'>
<a name="questions"></a>
<%include file="comments.mako" args="posts=questions, groupname=group, section='Questions', cid =cid"/>
<a name="comments"></a>
<%include file="comments.mako" args="posts=comments, groupname=group, section='Comments', cid=cid"/>
</div>


<script type="text/javascript">
$('#frm').html('<h2>Thank you for your comment</h2>);
</script>
%else:
<h1>Access Denied</h1>
%endif
