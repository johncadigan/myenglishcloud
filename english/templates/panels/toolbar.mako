## toolbar.mako
<%page args="groupname, current, username, flashcards"/>


<%def name='navbar(groupname, current, username, flashcards)'>
<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div>
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="${request.route_path('home')}"><i class="fa fa-cloud"></i> My English Cloud</a>
        </div>
        <div class="navbar-collapse collapse">
<ul class="nav navbar-nav">

 		<li class="dropdown">
		%if flashcards['due#']:                
<a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="fa fa-bolt"></i> Flashcards<b class="caret"></b><span id= 'due-flashcards'class="label label-primary">${flashcards['due#']}</span></a>
		%else:
<a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="fa fa-bolt"></i> Flashcards<b class="caret"></b><span id= 'due-flashcards'class="label label-primary"></span></a>
		%endif

		           
		<ul class="dropdown-menu">
			%if username:		
			<li><a href="${request.route_path('my_flashcards')}">
			<i class="fa fa-calendar"></i>			
			My Flashcards</a></li>
			<li><a href="${request.route_path('introduce_flashcards')}">
			<i class="fa fa-plus"></i>			
			New Flashcards
			%if flashcards['toAdd#']:
			<span id= 'intro-flashcards'class="label label-info">${flashcards['toAdd#']}</span>
			%else:
			<span id= 'intro-flashcards'class="label label-info"></span>
			%endif
			</a></li>
			<li><a href="${request.route_path('practice_flashcards')}">
			<i class="fa fa-signal"></i>			
			Practice Flashcards
			%if flashcards['toPractice#']:
			<span id= 'practice-flashcards'class="label label-info">${flashcards['toPractice#']}</span>
			%endif			
			</a></li>
			%else:
			<li><a href="${request.route_path('flashcards_demo')}">
			<i class="icon-"></i>			
			Flashcards Demo</a></li>
			%endif
		</li>
		</ul>



			
			<li><a href="${request.route_url('search', content_type = 'lesson')}">
			<i class="fa fa-file-o"></i> Lessons			
			</a></li>			
			<li><a href="${request.route_url('search', content_type = 'reading')}">
			<i class="fa fa-book"></i> Readings
			</a></li>
			<%doc>
			<li><a href="${request.route_url('search', content_type = 'resource')}">
			<i class="fa fa-archive"></i> Resources
			</a></li>
			
			<li><a href="${request.route_url('search', content_type = 'unit')}">
			<i class="fa fa-copy"></i><i class="icon-copy"></i>Units
			</a></li>
			</%doc>


</ul>
<ul class="nav navbar-nav navbar-right">
%if username:
       %if groupname == 'admin' or groupname == 'teacher':
                <li class="dropdown">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown">Add Content<b class="caret"></b></a>
                <ul class="dropdown-menu">
		%for option in [['add_lesson', 'Lesson'], ['add_reading', 'Reading']]:
			% if option[0] == current:
			<li class='active'><a href="${request.route_path(option[0])}">${option[1]}</a></li>
			%else:
			<li><a href="${request.route_path(option[0])}">${option[1]}</a></li>
			%endif
		%endfor
		</li>
		</ul>
		<li class="dropdown">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown">My content<b class="caret"></b></a>
                <ul class="dropdown-menu">
		%for option in [['my_content', 'Edit']]:
			% if option[0] == current:
			<li class='active'><a href="${request.route_path(option[0])}">${option[1]}</a></li>
			%else:
			<li><a href="${request.route_path(option[0])}">${option[1]}</a></li>
			%endif
		%endfor
		</li>
		</ul>

	%endif
	
<!--/ A way to highlight current location<li class="active"><a href="#">Link</a></li> -->
              <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">
	      <i class="fa fa-user"></i>		
	      <b class="caret"></b></a>
              <ul class="dropdown-menu">
	      <li><a href="${request.route_path('view_history')}">History
	      <i class="fa fa-bar-chart-o"></i>		
              </a></li>
	      <li><a href="${request.route_path('edit_profile')}">Edit profile
	      <i class="fa fa-pencil"></i>		
              </a></li>
	      <li><a href="${request.route_path('logout')}">Logout   
	      <i class="fa fa-sign-out"></i>			   
              </a></li>	         
	      </li>
	      </ul>
	

%else:
<li>
              <a href="${request.route_path('login')}" class="navbar-link">Login
		<i class="fa fa-sign-in"></i></a>
</li>
%endif
</ul>
</div><!--/.navbar-collapse -->
      </div>
    </nav>
</%def>

${navbar(groupname, current, username, flashcards)}


