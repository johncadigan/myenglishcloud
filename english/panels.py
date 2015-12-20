from pyramid_layout.panel import panel_config
from models import *

from .layouts import Thing1, Thing2, Thing3, LittleCat



@panel_config(name='debut_content', renderer='english/panels/lessonpanel.mako')
#@panel_config(name='debut_content', renderer='english/panels/readingpanel.mako')
def debut_content(context, request):
    return {'title' : item.title} 

@panel_config(
    name='navbar',
    renderer='english:templates/panels/navbar.mako'
    )
def navbar(context, request):
    def nav_item(name, url):
        active = request.current_route_url() == url
        item = dict(
            name=name,
            url=url,
            active=active
            )
        return item
    nav = [
        nav_item('Mako', request.route_url('home')),
        ]
    
    return {
        'title': 'Demo App',
        'nav': nav
        }


@panel_config(
    name='hero',
    renderer='english:templates/panels/hero.mako'
    )
def hero(context, request, title='Hello, world!'):
    lesson = DBSession.query(Lesson, Content).filter(Lesson.content_id==Content.id, Lesson.id==1).first()
    
    return {'title': lesson.Content.title}


@panel_config(
    name='heading-mako',
    renderer='english:templates/panels/heading.mako'
    )
def heading_mako(context, request):
    return {'title': 'Mako Heading'}


@panel_config(
    name='heading-chameleon',
    renderer='english:templates/panels/heading.pt'
    )
def heading_chameleon(context, request):
    return {'title': 'Chameleon Heading'}

@panel_config("thing", renderer="english:templates/panels/thing.mako")
def thing_mako(context, request):
	return {"title" : "Thing"}

@panel_config(name='headings')
def headings(context, request):
    lm = request.layout_manager
    layout = lm.layout
    if layout.headings:
        return '\n'.join([lm.render_panel(name, *args, **kw)
             for name, args, kw in layout.headings])
    return ''

@panel_config(name='footer')
def footer(context, request):
    return '<p>&copy; Pylons Project 2012</p>'

# Example of class-based panel
class UserPanel(object):
    def __init__(self, context, request):
        self.context = context
        self.request = request

    @panel_config(name='usermenu',
                  renderer='english:templates/panels/usermenu.pt')
    def __call__(self, user_info=None):
        """ Show the username of the passed in user. If None,
        get the current user off the request.  """

        if user_info is None:
            # Presumes request.user has some info, just a demo
            user = self.request.user
            user_info = dict(
                first_name=user['firstname'],
                last_name=user['lastname'],
                username=user['username']
            )

        label = user_info['first_name'] + ' ' + user_info['last_name']
        href = '/profiles/' + user_info['username']
        return dict(
            label=label,
            href=href
        )

@panel_config(context=Thing1, renderer="english:templates/panels/thing.mako")
def thing1(context, request):
    return {'title' : Thing1.title, "content": Thing1.content}
    
@panel_config(name='contextual_panels')
def contextual_panels(context, request):
    lm = request.layout_manager
    layout = lm.layout
    
    return '\n'.join([lm.render_panel(context=portlet)
                      for portlet in layout.portlets])


##@panel_config(context=content.Reading, renderer="english:templates/panels/thing.mako")
@panel_config(context=Content, renderer="english:templates/panels/thing.mako")
def thing3_and_thing2(context, request):
    return {'title': context.title, 'content' : str(dir(context)) }
    


@panel_config(context=LittleCat, renderer="english:templates/panels/littlecat.pt")
def littlecat(context, request):
    return {}

