# -*- coding: utf-8 -*-
import logging
import json

from pyramid.config import Configurator
from sqlalchemy import engine_from_config
from pyramid_beaker import session_factory_from_settings
from pyramid_beaker import set_cache_regions_from_settings
from pyramid_mailer.interfaces import IMailer

from sqlalchemy import create_engine

from pyramid.authentication import AuthTktAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from english.security import groupfinder, RootFactory

from pyramid.exceptions import Forbidden
from pyramid.interfaces import IAuthenticationPolicy
from pyramid.interfaces import IAuthorizationPolicy
from pyramid.interfaces import ISessionFactory
from pyramid.security import NO_PERMISSION_REQUIRED, Authenticated
from pyramid.session import UnencryptedCookieSessionFactoryConfig
from pyramid.settings import asbool

import teacher_views
import content_views
import user_views

from models import *
from views import *


from velruse import login_url

log = logging.getLogger(__name__)


#{
    #"profile": {
        #"preferredUsername": "catechi77", 
        #"displayName": "Mike Catechi", 
        #"name": {
            #"givenName": "Mike", 
            #"formatted": "Mike Catechi", 
            #"familyName": "Catechi"
        #}, 
        #"accounts": [
            #{
                #"username": "https://www.google.com/accounts/o8/id?id=AItOawkNzVw6JuT2zSbnkmeKogFGu3Eu4IgA1bk", 
                #"domain": "google.com"
            #}
        #], 
        #"verifiedEmail": "catechi77@gmail.com", 
        #"emails": [
            #"catechi77@gmail.com"
        #]
    #}, 
    #"credentials": {}, 
    #"options": "['__class__', '__delattr__', '__dict__', '__doc__', '__format__', '__getattribute__', '__hash__', '__implemented__', '__init__', '__module__', '__new__', '__providedBy__', '__provides__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', 'credentials', 'profile', 'provider_name', 'provider_type']"
#}

#def id_from_token(request):
	#""" Returns the apex id from the OpenID Token
	#"""
	#payload = {'format': 'json', 'token': request.POST['token']}
	#velruse = requests.get(request.host_url + '/velruse/auth_info', \
		#params=payload)
	#if velruse.status_code == 200:
		#try:
			#auth = velruse.json()
		#except:
			#raise HTTPBadRequest('Velruse error while decoding json')
		#if 'profile' in auth:
			#auth['id'] = auth['profile']['accounts'][0]['userid']
			#auth['provider'] = auth['profile']['accounts'][0]['domain']
			#return auth
		#return None
	#else:
		#raise HTTPBadRequest('Velruse backing store unavailable')
        
@view_config(context='velruse.AuthenticationComplete', renderer='result.mako',)
def login_complete_view(request):
	context = request.context
	Session = DBSession()
	added = 'False'
	added = str(request.POST)
	existing_email = Session.query(AuthUser).filter(AuthUser.email==context.profile['verifiedEmail']).first()
	if existing_email:
		correct_provider = Session.query(AuthUser).filter(AuthUser.provider==context.provider_name).first()
		if correct_provider:
			headers = remember(request, correct_provider.auth_id)
			return HTTPFound(location = request.route_url('home'), headers=headers)
		if correct_provider == None and existing_email.provider != 'local':
			error = 'Your account is registered with another provider: \n {0}'.format(existing_email.provider)
			return HTTPFound(location = request.route_url('login'))
		else:
			error = 'Your account is registered with MyEnglishCloud.com. Try retrieving the password with Forogt Password'
			return HTTPFound(location = request.route_url('login'))
	elif existing_email == None:
		authid = AuthID(display_name = context.profile['displayName'])
		group = DBSession.query(AuthGroup).filter(AuthGroup.name=='users').one()
		
		authid.groups.append(group)
		Session.add(authid)
		authuser = AuthUser(email = context.profile['verifiedEmail'], provider = context.provider_name, login = context.profile['preferredUsername'])
		authid.users.append(authuser)
		Session.flush()
		Session.add(authuser)
		Session.flush()
		headers = remember(request, authid.id)
		return HTTPFound(location = request.route_url('add_profile'), headers=headers)
	result = {
		'added' : added,
		'options' : str(dir(context)),
		'provider' : context.provider_name,
		'profile': context.profile,
		'credentials': context.credentials,
	}
	return {
		'result': json.dumps(result, indent=4),
	}

@view_config( context='velruse.AuthenticationDenied', renderer='result.mako',)
def login_denied_view(request):
	return {
		'result': 'denied',
	}

def main(global_config, **settings):
	log = logging.getLogger(__name__)
	engine = engine_from_config(settings)
	session_factory = session_factory_from_settings(settings)
	set_cache_regions_from_settings(settings)
	initialize_sql(engine, settings)
	config = Configurator(settings=settings, session_factory=session_factory)
	config.add_static_view('static', 'static', cache_max_age=3600)
	if not config.registry.queryUtility(IMailer):
		config.include('pyramid_mailer')
	
#	config.set_session_factory(UnencryptedCookieSessionFactoryConfig(settings.get('english.session_secret')))
	
	
	authn_policy = AuthTktAuthenticationPolicy('sosecret', callback=groupfinder)
	authz_policy = ACLAuthorizationPolicy()
	
	config.set_authentication_policy(authn_policy)
	config.set_authorization_policy(authz_policy)

	cache = RootFactory.__acl__
	config.set_root_factory(RootFactory)

# Static asset views    
	
	config.add_static_view(name='css', path='english:/static/css')
	config.add_static_view(name='js', path='english:/static/js')
	config.add_static_view(name='images', path='english:/static/images')
	config.add_static_view(name='rating', path='english:/static/rating')
	config.add_static_view(name='form', path='english:/static/js/form')
	#Uploads
	config.add_static_view(name='pictures', path='english:/static/uploads/pictures')
	config.add_static_view(name='quizzes', path='english:/static/uploads/quizzes')
	config.add_static_view(name='autopictures', path='english:/static/to_upload/images')

#VELRUSE
# determine which providers we want to configure
	providers = settings.get('login_providers', '')
	providers = filter(None, [p.strip()
						  for line in providers.splitlines()
						  for p in line.split(', ')])
	settings['login_providers'] = providers
	if not any(providers):
		log.warn('no login providers configured, double check your ini file and add a few')
	
	
	if 'facebook' in providers:
		config.include('velruse.providers.facebook')
		config.add_facebook_login_from_settings(prefix='velruse.facebook.')
	
	if 'github' in providers:
		config.include('velruse.providers.github')
		config.add_github_login_from_settings(prefix='github.')
	
	if 'twitter' in providers:
		config.include('velruse.providers.twitter')
		config.add_twitter_login_from_settings(prefix='twitter.')
	
	if 'live' in providers:
		config.include('velruse.providers.live')
		config.add_live_login_from_settings(prefix='live.')
	
	if 'bitbucket' in providers:
		config.include('velruse.providers.bitbucket')
		config.add_bitbucket_login_from_settings(prefix='bitbucket.')
	
	if 'google' in providers:
		config.include('velruse.providers.google')
		config.add_google_login(
			consumer_key=settings['velruse.google.consumer_key'],
			consumer_secret=settings['velruse.google.consumer_secret'],
		)
	
	if 'yahoo' in providers:
		config.include('velruse.providers.yahoo')
		config.add_yahoo_login(
			realm=settings['yahoo.realm'],
			consumer_key=settings['yahoo.consumer_key'],
			consumer_secret=settings['yahoo.consumer_secret'],
		)

# User views
	
	config.include('english.user_views')
	
# Content views

	config.include('english.content_views')

# flashcard_views

	config.include('english.flashcard_views')

# AJAX submissions

	config.include('english.ajax_submissions')

# Admin views

	config.include('english.views')
	
#Launch
	
	return config.make_wsgi_app()

