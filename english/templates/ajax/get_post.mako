## get_post.mako






%if post_type == 'comment':
<%include file="comment.mako" args="comment=post, group=groupname"/>

%else:
<%include file="reply.mako" args="reply=post, side='right', group=groupname"/>

%endif

<script>

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
