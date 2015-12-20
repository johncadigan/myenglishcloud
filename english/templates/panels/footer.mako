##footer.mako
<%page args=""/>

<%def name='footer()'>
<nav class="navbar navbar-inverse" role="navigation">
<div id='footer' class="">
	<div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <li class="navbar-brand">&copy; My English Cloud 2013</li>
        </div>
	<ul class="nav navbar-nav">
	<li><a href="${request.route_url('terms_of_service')}">
	Terms of Service			
	</a></li>
	<li><a href="${request.route_url('privacy_policy')}">
	Privacy Policy
	</a></li>
</ul
</div>
</nav>
</%def>

${footer()}
