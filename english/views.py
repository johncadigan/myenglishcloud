# -*- coding: utf-8 -*-

import json
import os
import shutil
from pyramid.response import Response
from pyramid.request import Request
from pyramid.view import view_config
import uuid
import Image
from sqlalchemy.exc import DBAPIError
from pyramid.httpexceptions import HTTPFound, HTTPNotFound
from pyramid.security import (authenticated_userid,
							unauthenticated_userid,
							effective_principals,
							forget,
							remember
							)
import time

from forms import *
from pyramid.settings import asbool
from pyramid.url import (current_route_url,
						route_url
						)
from models import *
from user_views import BaseView




"""ADMIN VIEWS"""

class AdminViews(BaseView):
	
	def __init__(self,request):
		self.request = request
		super(AdminViews, self).__init__(self.request)
		
	def delete_post(self):
		posttype = self.request.matchdict['post_type']
		postid = self.request.matchdict['post_id']
		if posttype == 'comment':
			postall = DBSession.query(Comment,AuthID).filter(Comment.id==postid).filter(Comment.owner==AuthID.id).first()
			content = postall.Comment.text
			post = postall.Comment
			lessonid = post.content_id
		if posttype == 'reply':
			postall = DBSession.query(CommentReply,AuthID).filter(CommentReply.id==postid).filter(CommentReply.owner==AuthID.id).first()
			content = postall.CommentReply.text
			post = postall.CommentReply
			lessonid = DBSession.query(Comment).filter(id==post.parent_id).first().content_id
		self.response['post'] = content
		self.response['postowner'] = postall.AuthID.display_name		
		if 'submit' in self.request.params:
			delete = self.request.params['delete']
			if delete == 'delete':
				if posttype == 'comment':
					for reply in post.replies:
						DBSession.delete(reply)
				DBSession.delete(post)
				content = DBSession.query(Content).filter_by(id = lessonid).first()
				if content.type == 'lesson':
					lessonurl = self.request.route_url('lesson_index', cid=content.id, curl = content.url)
				elif content.type == 'reading':
					lessonurl = self.request.route_url('reading_index', cid=content.id, curl = content.url)
				return HTTPFound(location = lessonurl, headers=self.response['headers'])
		return	self.response
				
	
	def review_posts(request):
		userid = authenticated_userid(request)
		headers = remember(request, userid)
		auth_id = DBSession.query(AuthID).filter_by(id=userid).first()
		username = auth_id.users[0].login
		user_group = str(DBSession.query(AuthID).filter_by(id=userid).first().groups[0])
		posttype = request.matchdict['post_type']
		postid = request.matchdict['post_id']
		if posttype == 'comment':
			post = DBSession.query(Comment,AuthUser).filter(Comment.id==postid).filter(Comment.owner==AuthUser.id).first()
			content = post.Comment.content
		if posttype == 'reply':
			post = DBSession.query(CommentReply,AuthUser).filter(CommentReply.id==postid).filter(CommentReply.owner==AuthUser.id).first()
			content = post.CommentReply.content
		return	{'post': content,
				'postowner': post.AuthUser.login,
				'headers' : headers,
				'username':username,
				'group':user_group,
				}

def includeme(config):


	config.add_route('delete_post', ':post_type/delete_post/:post_id') 
	config.add_view(AdminViews, attr='delete_post', route_name='delete_post', renderer='delete_post.mako', permission=u'add')
	
