from pyramid_layout.layout import layout_config
from models import * 

@layout_config(template='english:templates/layouts/layout.mako')
@layout_config(name='user',template='english:templates/layouts/admin_layout.mako')
@layout_config(name='teacher',template='english:templates/layouts/admin_layout.mako')
@layout_config(name='admin',template='english:templates/layouts/admin_layout.mako')
class AppLayout(object):

    def __init__(self, context, request):
        self.context = context
        self.request = request
        self.home_url = request.application_url
        self.headings = []
        content = DBSession.query(Content).all()
        self.portlets = [contenta for contenta in content]

    @property
    def project_title(self):
        return 'Pyramid Layout App!'

    def add_heading(self, name, *args, **kw):
        self.headings.append((name, args, kw))
    
    def is_user_admin(self):
        return True

class Thing1(object):
    title = "Thing 1"
    content = "I am Thing 1!"


class Thing2(object):
    title = "Thing 2"
    content = "I am Thing 2!"

class Thing3(object):
    title = "Thing 3"
    content = "I am Thing 3!"


class LittleCat(object):
    talent = "removing pink spots"

    def __init__(self, name):
        self.name = name
