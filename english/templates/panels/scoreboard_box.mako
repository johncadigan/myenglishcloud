## scoreboard_box.mako

<%page args="scoreboard, rank"/>

<%def name='add_scoreboard_box(scoreboard, rank)'>
<div class='bubble-container'>
        <div class="head">
	<span class='lead strong'>Leaderboard</span>
	<i class='icon-trophy icon-2x text-info'></i><br>
            <ul class="btn-group pull-left inside-box">
                    <li class="btn score-btn btn-small active" id='week-button' data-period="week">
                        Week
                    </li>

                    <li class="btn score-btn btn-small" id='month-button' data-period="month">
                        Month
                    </li>

                    <li class="btn score-btn btn-small" id='alltime-button' data-period="alltime">
                        All Time
                    </li>
                </ul>
        </div><br><br>

    <div class="rows pull-left">
    
    <table class="stats table table-striped">
            <thead>
                <tr>
                    <th class="col-rank">Rank</th>
                    <th class="col-pic">&nbsp;</th>
                    <th class="col-user">User</th>
                    <th class="col-action">&nbsp;</th>
                    <th class="col-points">Points</th>
                </tr>
            </thead>
            <tbody class='weekly'>

    %for indx, place in enumerate(['1<sup>st</sup>', '2<sup>nd</sup>', '3<sup>rd</sup>', '4<sup>th</sup>', '5<sup>th</sup>', '6<sup>th</sup>', '7<sup>th</sup>', '8<sup>th</sup>', '9<sup>th</sup>', '10<sup>th</sup>']):
    <tr class="self">
        <td class="col-rank">${place | n}</td>
        <td class="col-pic">
            <div class="whitebox pic-wrapper"><img src="${request.static_url('english:/static/uploads/pictures/{0}.thumb'.format(scoreboard['week'][indx]['picture']))}" alt="" class='.img-responsive'></div>
        </td>
        <td class="col-user">${scoreboard['week'][indx]['username']} </td>

        <td class="col-action">
            
        </td>

        <td class="col-points">${scoreboard['week'][indx]['points']}</td>
    </tr>
%endfor
	%if rank['week']:
	<h6 class='weekly lead'>You are ranked #${rank['week']}</h6>
	%endif	
	</tbody>
<tbody class='monthly'>

    %for indx, place in enumerate(['1<sup>st</sup>', '2<sup>nd</sup>', '3<sup>rd</sup>', '4<sup>th</sup>', '5<sup>th</sup>', '6<sup>th</sup>', '7<sup>th</sup>', '8<sup>th</sup>', '9<sup>th</sup>', '10<sup>th</sup>']):
    <tr class="self">
        <td class="col-rank">${place | n}</td>
        <td class="col-pic">
            <div class="whitebox pic-wrapper"><img src="${request.static_url('english:/static/uploads/pictures/{0}.thumb'.format(scoreboard['month'][indx]['picture']))}" alt="" class='.img-responsive'></div>
        </td>
        <td class="col-user">${scoreboard['month'][indx]['username']} </td>

        <td class="col-action">
            
        </td>

        <td class="col-points">${scoreboard['month'][indx]['points']}</td>
    </tr>
%endfor
     %if rank['month']:
	<h6 class='monthly lead'>You are ranked #${rank['month']}</h6>
     %endif
     
     </tbody>

<tbody class='alltime'>

    %for indx, place in enumerate(['1<sup>st</sup>', '2<sup>nd</sup>', '3<sup>rd</sup>', '4<sup>th</sup>', '5<sup>th</sup>', '6<sup>th</sup>', '7<sup>th</sup>', '8<sup>th</sup>', '9<sup>th</sup>', '10<sup>th</sup>']):
    <tr class="self">
        <td class="col-rank">${place | n}</td>
        <td class="col-pic">
            <div class="whitebox pic-wrapper"><img src="${request.static_url('english:/static/uploads/pictures/{0}.thumb'.format(scoreboard['alltime'][indx]['picture']))}" alt="" class='.img-responsive'></div>
        </td>
        <td class="col-user">${scoreboard['alltime'][indx]['username']} </td>

        <td class="col-action">
            
        </td>

        <td class="col-points">${scoreboard['alltime'][indx]['points']}</td>
    </tr>
%endfor
      %if rank['alltime']:
	<h6 class='alltime lead'>You are ranked #${rank['alltime']}</h6>
     %endif

</tbody>
     

     </table>
</div>


</div>


<script type="text/javascript">

$('.monthly').hide()
$('.alltime').hide()
$('#week-button').on('click', function() {
	$('.monthly').hide()
	$('.alltime').hide()     
	$('.weekly').fadeIn(1000);
	$(".score-btn").removeClass('active');
	$(this).addClass('active');
});
$('#month-button').on('click', function() {
	$('.weekly').hide()
	$('.alltime').hide()     
	$('.monthly').fadeIn(1000);
	$(".score-btn").removeClass('active');
	$(this).addClass('active');
});
$('#alltime-button').on('click', function() {
	$('.weekly').hide()
	$('.monthly').hide()     
	$('.alltime').fadeIn(1000);
	$(".score-btn").removeClass('active');
	$(this).addClass('active');
});
</script>

</%def>

${add_scoreboard_box(scoreboard, rank)}


