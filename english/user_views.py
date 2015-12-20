## user_views.py
import json
import os
import shutil
import hmac
import base64

from pyramid.response import Response
from pyramid.request import Request
from pyramid.decorator import reify

from pyramid.view import view_config
import uuid
from velruse import login_url
import Image
from sqlalchemy.exc import DBAPIError
from pyramid.httpexceptions import HTTPFound, HTTPNotFound
from pyramid.security import (authenticated_userid,
							unauthenticated_userid,
							effective_principals,
							forget,
							remember,
							)
import time
from forms import *
from pyramid.settings import asbool
from pyramid.url import (current_route_url,
						route_url
						)
from models import *
from pyramid.security import NO_PERMISSION_REQUIRED
from beaker.cache import cache_region
from security import email_forgot
from cache_functions import *

"""LOGISTICAL VIEWS"""

#def login_callback(request):
		#token = request.form['token']
		## the request must contain 'format' and 'token' params
		#payload = {'format': 'json', 'token': token}
		## sending a GET request to /auth_info
		#response = requests.get(request.host_url + 'velruse/auth_info', params=payload)
		#auth_info = response.json
		#return render_template('logged_in.mako', result=auth_info)
		
#def login_complete_view(request):
	#context = request.context
	#result = {
		#'provider_type': context.provider_type,
		#'provider_name': context.provider_name,
		#'profile': context.profile,
		#'credentials': context.credentials,
	#}
	#return {
		#'result': json.dumps(result, indent=4)
	#}

class BaseView(object):
	
	def __init__(self,request):
		self.response = {}
		self.request = request
		self.response = self.user_info(self.userid)
		headers = ''
		if self.userid: 
			headers = remember(self.request, self.userid)
		self.response['headers'] = headers
	
	
	@reify
	def userid(self):
		return authenticated_userid(self.request)
	
	@cache_region('twentymins', 'user_info')
	def user_info(self, userid):
		if userid:
			today = datetime.date.today()
			today_number = today.toordinal()
			this_week = (today_number-(today_number % 7))/7
			this_month = today.month
			auth_id = DBSession.query(AuthID).filter(AuthID.id==userid).first()
			username = auth_id.display_name
			user_group = str(auth_id.groups[0])
			user_flashcards = auth_id.sorted_flashcards()
			flashcards = {'due#': user_flashcards['due#'], 'toAdd#': user_flashcards['toAdd#'], 'toPractice#': user_flashcards['toPractice#']}
			weekscore = DBSession.query(WeeklyUserPoint.amount).filter(WeeklyUserPoint.week==this_week, WeeklyUserPoint.user_id==userid).cte(name='weekscore')
			week_rank = DBSession.query(func.count(WeeklyUserPoint.id)).filter(WeeklyUserPoint.amount >= weekscore).scalar()
			monthscore = DBSession.query(MonthlyUserPoint.amount).filter(MonthlyUserPoint.month==this_month, MonthlyUserPoint.user_id==userid).cte(name='monthscore')
			month_rank = DBSession.query(func.count(MonthlyUserPoint.id)).filter(MonthlyUserPoint.amount >= monthscore).scalar()
			allscore = DBSession.query(TotalUserPoint.amount).filter(TotalUserPoint.user_id==userid).cte(name='allscore')
			total_rank = DBSession.query(func.count(TotalUserPoint.id)).filter(TotalUserPoint.amount >= allscore).scalar()
			rank = {'week' : week_rank, 'month' : month_rank, 'alltime' : total_rank}
		else:
			username = ''
			user_group = ''
			flashcards = {'due#': 0, 'toAdd#': 0, 'toPractice#': 0}
			rank = {'week' : '', 'month' : '', 'alltime' : ''}
		user_info = {'username':username, 'group':user_group,'flashcards':flashcards, 'rank': rank}
		DBSession.expunge_all()
		return user_info

	@cache_region('hour', 'get_profile')
	def get_profile_by_id(self, authid):
		profile_all = DBSession.query(AuthID, Profile, Country, Picture).filter(AuthID.id==authid, Profile.owner==AuthID.id, Profile.country_id==Country.id,Profile.picture_id==Picture.id).first()
		languages = [language.english_name for language in profile_all.Profile.languages]
		profile_dict = {'id' : profile_all.AuthID.id, 'name' : profile_all.AuthID.display_name, 'country_name': profile_all.Country.name, 'group': str(profile_all.AuthID.groups[0]), 'city': profile_all.Profile.city, 'languages': languages,'about_me': profile_all.Profile.about_me, 'country_pic': profile_all.Country.image, 'profile_picture' : profile_all.Picture.name}
		return profile_dict

	##VIEWS
	def login(self):
		#came_from = get_came_from(request)
		form = LoginForm(self.request.POST)
		self.response['login_url'] = login_url
		self.response['form'] = form
		self.response['title'] = 'Login'
		self.response['providers'] =  self.request.registry.settings['login_providers']
		self.response['action'] = 'login'
		if self.request.method == 'POST' and form.validate() and form.clean() == []:
			username = form.data.get('login')
			if username:
				user = AuthUser.get_by_login(username)
				headers = remember(self.request, user.auth_id)
				return HTTPFound(location = self.request.route_url('home'), headers=headers)
		elif self.request.method == 'POST' and form.validate() and form.clean():
			self.response['title'] = form.clean()[0]
			return self.response
		return self.response
	
	
		
	def logout(self):
		headers = forget(self.request)
		#came_from = get_came_from(self.request)
		return HTTPFound(location=self.request.route_url('home'), headers=headers)


	def register(self):
		title = 'Register'
		#came_from = get_came_from(request)
		form = RegisterForm(self.request.POST)
		if self.request.method == 'POST' and form.validate():
			user = form.save()
			headers = remember(self.request, user.auth_id)
			return HTTPFound(location = self.request.route_url('add_profile'), headers=headers)
		self.response.update({'title': title, 'login_url': login_url, 'providers': self.request.registry.settings['login_providers'], 'form': form, 'action': 'register'})
		return self.response



	def add_profile(self):
		headers = remember(self.request, self.userid)
		form = AddProfileForm(self.request.POST)
		self.response['title']= 'Add your profile'
		self.response['form'] = form
		if self.request.method == 'POST' and form.validate():
			profile = form.create_profile(self.userid)
			if form.data.has_key('picture_id'):
				picture = form.data['picture_id']
				pic_id = add_image(self.request, picture, self.userid, situation='profile')
				profile.picture_id = pic_id
			else:
				profile.picture_id = 1
			return HTTPFound(location = self.request.route_url('home'), headers = headers)
		return self.response
	
	
	def edit_profile(self):
		headers = remember(self.request, self.userid)
		
		user = DBSession.query(AuthID).filter(AuthID.id == self.userid).first()
		profile = DBSession.query(Profile).filter_by(owner=self.userid).first()
		form = EditProfileForm(self.request.POST, display_name = user.display_name, preferred_language=user.preferred_language, name = profile.name, country=profile.country_id, city = profile.city, languages = [language.id for language in profile.languages], birthday = {'year': profile.date_of_birth.year, 'month': profile.date_of_birth.month, 'day': profile.date_of_birth.day}, about_me=profile.about_me)
		if self.request.method == 'POST' and form.validate():
			profile = form.edit_profile(profile)
			profile.owner = self.userid
			if form.data['picture_id'] != '':
				if profile.picture_id != 1:
					picture = form.data['picture_id']
					imageid = profile.picture_id
					pic_id = replace_image(self.request, picture, imageid, situation='profile')
				else:
					picture = form.data['picture_id']
					pic_id = add_image(self.request, picture, self.userid, situation='profile')
					profile.picture_id = pic_id
				DBSession.flush()
			return HTTPFound(location = self.request.route_url('home'), headers=headers)
		self.response['form'] = form
		self.response['title'] = 'Edit your profile'
		return self.response

	def view_history(self):
		user = DBSession.query(AuthID).filter(AuthID.id == self.userid).first()
		contentlist = user.finished_content
		contents = []
		for link in contentlist:
			contents.append({'title': link.title, 'type' : link.type, 'description': link.description, 'url': link.url})
		self.response['contents'] = contents
		return self.response
		
	def forgot(self):
		""" forgot_password(request):
		no return value, called with route_url('apex_forgot_password', request)
		"""
		self.response['title'] = 'Forgot my password'
		form = ForgotForm(self.request.POST)
		self.response['form'] = form
		self.response['login_url'] = login_url
		self.response['providers'] = self.request.registry.settings['login_providers']
		self.response['action'] = 'forgot'
		if self.request.method == 'POST' and form.validate():
			""" Special condition - if email imported from OpenID/Auth, we can
				direct the person to the appropriate login through a flash
				message.
			"""
			if form.data['email']:
				user = AuthUser.get_by_email(form.data['email'])
				if user.provider != 'local':
					provider_name = user.provider
					title = 'You used %s as your login provider'.format(provider_name)
					
					return self.response
			if form.data['login']:
				user = AuthUser.get_by_login(form.data['login'])
			if user:
				timestamp = time.time()+3600
				hmac_key = hmac.new('%s:%s:%d' % (str(user.id), request.registry.settings['auth_secret'], timestamp), user.email).hexdigest()[0:10]
				time_key = base64.urlsafe_b64encode('%d' % timestamp)
				email_hash = '%s%s' % (hmac_key, time_key)
				email_forgot(request, user.id, user.email, email_hash)
				Response = ('Password Reset email sent.')
				return HTTPFound(location=route_url('login', request))
		return self.response
		
	def change_password(request):
		""" change_password(request):
		no return value, called with route_url('apex_change_password', request)
		FIXME doesn't adjust auth_user based on local ID, how do we handle multiple
			IDs that are local? Do we tell person that they don't have local
			permissions?
		"""
		self.response['title'] = 'Change your Password'
		user = DBSession.query(AuthUser).filter(AuthUser.auth_id==authenticated_userid(self.request)).filter(AuthUser.provider=='local').first()
		form = ChangePasswordForm(request.POST, owner=user.id)
		self.response['form'] = form
		self.response['action'] = 'changepass'
		if self.request.method == 'POST' and form.validate():
			user = AuthUser.get_by_id(authenticated_userid(self.request))
			user.password = form.data['password']
			DBSession.merge(user)
			DBSession.flush()
			return HTTPFound(request.route_url('home'), headers=self.response['headers'])
		return self.response
	
	def reset_password(self):
	    """ reset_password(request):
	    no return value, called with route_url('apex_reset_password', request)
	    """
	    self.response['title'] = 'Reset My Password'

	    form = ResetPasswordForm(request.POST, \
	               captcha={'ip_address': request.environ['REMOTE_ADDR']})
	    self.response['form'] = form
	    self.response['action'] = 'reset'
	    if self.request.method == 'POST' and form.validate():
	        user_id = request.matchdict.get('user_id')
	        user = AuthUser.get_by_id(user_id)
	        submitted_hmac = request.matchdict.get('hmac')
	        current_time = time.time()
	        time_key = int(base64.b64decode(submitted_hmac[10:]))
	        if current_time < time_key:
	            hmac_key = hmac.new('%s:%s:%d' % (str(user.id), \
	                                apex_settings('auth_secret'), time_key), \
	                                user.email).hexdigest()[0:10]
	            if hmac_key == submitted_hmac[0:10]:
	                #FIXME reset email, no such attribute email
	                user.password = form.data['password']
	                DBSession.merge(user)
	                DBSession.flush()
	                flash('Password Changed. Please log in.')
	                return HTTPFound(location=route_url('login', \
	                                                    self.request))
	            else:
	                flash('Invalid request, please try again')
	                return HTTPFound(location=route_url('forgot', \
	                                                    self.request))
	    return self.response
		
	def static_page(self):
		return self.response


def includeme(config):
	
	config.add_route('terms_of_service', '/terms-of-service')
	config.add_view(BaseView, attr='static_page', route_name='terms_of_service', renderer='terms_of_service.mako', permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('privacy_policy', '/privacy-policy')
	config.add_view(BaseView, attr='static_page', route_name='privacy_policy', renderer='privacy_policy.mako', permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('password', '/changepass')
	config.add_view(BaseView, attr='change_password', route_name='password', renderer='aform.mako', permission='authenticated')

	config.add_route('register', '/register')
	config.add_view(BaseView, attr='register', route_name='register', renderer='loginform.mako', permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('forgot', '/forgot')
	config.add_view(BaseView, attr='forgot', route_name='forgot', renderer='loginform.mako', permission=NO_PERMISSION_REQUIRED)

	config.add_route('login', '/login')
	config.add_view(BaseView, attr='login', route_name='login', renderer='loginform.mako', permission=NO_PERMISSION_REQUIRED)

	#config.add_route('login_callback', '/login/:provider/callback')
	#config.add_view(login_callback, route_name='login_callback', renderer='logged_in.mako', permission=NO_PERMISSION_REQUIRED)
	
	#config.add_route('logged_in_result', '/logged_in')
	#config.add_view(login_complete_view, route_name='logged_in_result', renderer='result.mako', context='velruse.AuthenticationComplete',permission=NO_PERMISSION_REQUIRED)

	config.add_route('reset', '/reset/:user_id/:hmac')
	config.add_view(BaseView, attr ='reset_password', route_name='reset', renderer='aform.mako', permission=NO_PERMISSION_REQUIRED)

	config.add_route('logout', '/logout')
	config.add_view(BaseView, attr='logout', route_name='logout', renderer='index.mako', permission=NO_PERMISSION_REQUIRED)

	config.add_route('add_profile', '/add_profile')
	config.add_view(BaseView, attr='add_profile', route_name='add_profile', renderer='picture_form.mako', permission='authenticated')
	
	config.add_route('edit_profile', '/edit_profile') 
	config.add_view(BaseView, attr='edit_profile', route_name='edit_profile', renderer='picture_form.mako', permission='authenticated')
	
	config.add_route('view_history', '/history')
	config.add_view(BaseView, attr='view_history', route_name= 'view_history', renderer='history.mako', permission=NO_PERMISSION_REQUIRED)
