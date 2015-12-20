# -*- coding: utf-8 -*-

## ajax_views

import json
import os
import shutil
from pyramid.response import Response
from pyramid.request import Request
from pyramid.view import view_config
import uuid
import Image
from sqlalchemy.exc import DBAPIError
from sqlalchemy.orm import aliased
from pyramid.httpexceptions import HTTPFound, HTTPNotFound
from pyramid.security import (authenticated_userid,
							unauthenticated_userid,
							effective_principals,
							forget,
							remember
							)
import time
import datetime
from forms import *
from random import randint
from pyramid.settings import asbool
from pyramid.url import (current_route_url,
						route_url
						)
from models import *
import beaker
from beaker.cache import cache_region
from pyramid.security import NO_PERMISSION_REQUIRED, Authenticated
from cache_functions import *
from content_views import BaseView, ContentView 
from flashcard_views import FlashcardView

#Submit = Non AJAX 
#Add = AJAX

class SubmitViews(ContentView):

	def __init__(self, request):
		self.request = request
		self.response = {}
		self.request = request
		self.response = self.user_info(self.userid)
		headers = ''
		if self.userid: 
			headers = remember(self.request, self.userid)
		self.response['headers'] = headers
		self.cid = request.matchdict['cid']

	
	## Views
	
	def rate_difficulty(self):
		content = DBSession.query(Content).filter(Content.id == self.cid).first()
		user = DBSession.query(AuthID).filter(AuthID.id == self.userid).first()
		if self.request.method=='POST' and self.request.POST.has_key('Difficulty-Rating'):
			beaker.cache.region_invalidate(ContentView.content_stats, None, 'content_stats', (self.cid, self.userid))
			score = float(self.request.params['Difficulty-Rating'])
			vote = DifficultyVote(content_id=content.id, owner=self.userid, score = 100*score)
			DBSession.add(vote)
			content.difficulty_votes.append(vote)
			content.difficulty_rated_by.append(user)
			DBSession.flush()
			difficulty_vote = 'disabled'
			difficulty = 0.0
			for vote in content.difficulty_votes: 
				difficulty += vote.score/(100.0)
			difficulty = difficulty/(len(content.difficulty_votes))
			self.response['show'] = True
			self.response['difficulty'] = difficulty
			self.response['difficulty_vote'] = difficulty_vote
			return self.response
		return self.response

	def rate_quality(self):
		content = DBSession.query(Content).filter(Content.id == self.cid).first()
		user = DBSession.query(AuthID).filter(AuthID.id == self.userid).first()
		if self.request.method=='POST' and self.request.POST.has_key('Quality-Rating'):
			beaker.cache.region_invalidate(ContentView.content_stats, None, 'content_stats', (self.cid, self.userid))
			score = float(self.request.params['Quality-Rating'])
			vote = QualityVote(content_id=content.id, owner=self.userid, score = 100*score)
			DBSession.add(vote)
			content.quality_votes.append(vote)
			content.quality_rated_by.append(user)
			DBSession.flush()
			quality_vote = 'disabled'
			quality = 0.0
			for vote in content.quality_votes: 
				quality += vote.score/(100.0)
			quality = quality/(len(content.quality_votes))
			self.response['show'] = True
			self.response['quality'] = quality
			self.response['quality_vote'] = quality_vote
			return self.response
		return self.response
		
		
	def add_comment(self):
		content = DBSession.query(Content).filter(Content.id == self.cid).first()
		self.response['cid'] = 0
		user = DBSession.query(AuthID).filter(AuthID.id == self.userid).first()
		self.response['title'] = 'Add a comment or question'
		form = CommentQuestionForm(self.request.POST)
		if self.request.method == 'POST' and form.validate():
				post_type, new_post = form.create_post()
				new_post.owner = user.id
				if post_type == 'comment': 
					new_post.content_id=content.id
					if new_post.comment_type == 'Q':
						beaker.cache.region_invalidate(ContentView.content_questions, None, 'content_questions', (self.cid, 'all'))
						beaker.cache.region_invalidate(ContentView.content_questions, None, 'content_questions', (self.cid,  5))
					else:
						beaker.cache.region_invalidate(ContentView.content_comments, None, 'content_comments', (self.cid, 'all'))
						beaker.cache.region_invalidate(ContentView.content_comments, None, 'content_comments', (self.cid,  5))
				else:
					beaker.cache.region_invalidate(ContentView.content_questions, None, 'content_questions', (self.cid, 'all'))
					beaker.cache.region_invalidate(ContentView.content_comments, None, 'content_comments', (self.cid, 'all'))
				DBSession.flush()
				self.response.update(self.content_comments((self.cid, 'all')))
				self.response.update(self.content_questions((self.cid, 'all')))
				self.response['show'] = True
				return self.response
		self.response['show'] = False
		return self.response
	
	def submit_comment(self):
		content = DBSession.query(Content).filter(Content.id == self.cid).first()
		user = DBSession.query(AuthID).filter(AuthID.id == self.userid).first()
		self.response['title'] = 'Add a comment or question'
		form = CommentQuestionForm(self.request.POST)
		if self.request.method == 'POST' and form.validate():
				post_type, new_post = form.create_post()
				new_post.owner = userid
				if post_type == 'comment': 
					new_post.content_id=content.id
					if new_post.comment_type == 'Q':
						beaker.cache.region_invalidate(ContentView.content_questions, None, 'content_questions', (self.cid, 'all'))
						beaker.cache.region_invalidate(ContentView.content_questions, None, 'content_questions', (self.cid,  5))
					else:
						beaker.cache.region_invalidate(ContentView.content_comments, None, 'content_comments', (self.cid, 'all'))
						beaker.cache.region_invalidate(ContentView.content_comments, None, 'content_comments', (self.cid,  5))
				else:
					beaker.cache.region_invalidate(ContentView.content_questions, None, 'content_questions', (self.cid, 'all'))
					beaker.cache.region_invalidate(ContentView.content_comments, None, 'content_comments', (self.cid, 'all'))
				DBSession.flush()
				profile_dict = {}
				if content_type == 'lesson':
					return HTTPFound(location = self.request.route_url('lesson_index', curl=content.url, cid=self.cid))
				elif content_type == 'reading':
					return HTTPFound(location = self.request.route_url('reading_index', curl=content.url, cid=self.cid))
				return self.response
		self.response['show'] = False
		return self.response
		
	
	def report_score(self):
		session = DBSession()
		user = session.query(AuthID).filter(AuthID.id==self.userid).first()
		content = session.query(Content).filter(Content.id == self.cid).first() 
		message = 'You must <a href="/login"> login</a> to record your score'
		if self.request.method == 'POST' and self.request.POST.has_key('activity_type'):
			content.finished_by.append(user)
			beaker.cache.region_invalidate(ContentView.content_stats, None, 'content_stats', (self.cid, self.userid))
			total_score = 0
			source = self.request.params['activity_type'] + self.request.params['activity_id']
			if self.request.params['activity_type'] == 'quiz':
				if self.userid !=None:
					for x in xrange(0, int(self.request.params['length'])):
						total_score += int(self.request.params['score'+str(x)])
			score_totals = self.add_points(self.userid, total_score, source)
			message='Congratulations you scored {0} points!<br>{1}'.format(total_score, score_totals)
			session.flush()
			self.response['message'] = message
			return self.response
		return self.response
	
	## Functions

	def add_points(self, userid, points, activity):
		session = DBSession()
		today = datetime.date.today()
		today_number = today.toordinal()
		this_week = (today_number-(today_number % 7))/7
		this_month = today.month	
		totals = 'But you already scored points with this activity.'
		UP = session.query(UserPoint).filter(UserPoint.user_id==userid, UserPoint.source==activity).first()
		if UP == None:
			session.add(UserPoint(user_id=userid, amount=points, source=activity))
			TUP = session.query(TotalUserPoint).filter(TotalUserPoint.user_id==userid).first()
			if TUP == None:
				TUP = TotalUserPoint(user_id=userid, amount = 0)
				session.add(TUP)
			TUP.amount += points
			MUP = session.query(MonthlyUserPoint).filter(MonthlyUserPoint.user_id==userid, MonthlyUserPoint.month==this_month).first()
			if MUP == None:
				MUP = MonthlyUserPoint(user_id=userid, month=this_month, amount = 0)
				session.add(MUP)
			MUP.amount += points
			WUP = session.query(WeeklyUserPoint).filter(WeeklyUserPoint.user_id==userid, WeeklyUserPoint.week==this_week).first()
			if WUP == None:
				WUP = WeeklyUserPoint(user_id=userid, week=this_week, amount = 0)
				DBSession.add(WUP)
			WUP.amount += points
			session.flush()
			totals = 'New totals:<br> Week: {0}   Month: {1}   Alltime: {2}'.format(WUP.amount, MUP.amount, TUP.amount)
			if randint(1,10000) == 5000:
				point_table_check(this_week, this_month)
		return totals

class LoadViews(ContentView):

	def __init__(self, request):
		self.request = request
		self.response = {}
		self.request = request
		self.response = self.user_info(self.userid)
		headers = ''
		if self.userid: 
			headers = remember(self.request, self.userid)
		self.response['headers'] = headers
	
	def get_profile(self):
		profileid = self.request.params['profile']
		self.response['post_info'] = {}
		self.response['post_info']['post_type'] = self.request.params['post_type']
		self.response['post_info']['post_id'] = self.request.params['post_id']
		self.response['profile'] = self.get_profile_by_id(profileid)
		return self.response

	def get_post(self):
		profileid = self.request.params['profile']
		self.response['post_type'] = self.request.params['post_type']
		postid = self.request.params['post_id']
		if self.request.params['post_type'] == 'comment':
			self.response['post'] = self.get_comment_by_id(postid)
		else:
			self.response['post'] = self.get_reply_by_id(postid)
		return self.response
	
	def get_all_posts(self):
		cid = self.request.params['content_id']
		section = self.request.params['section']
		if section == 'Comments':
			posts = self.content_comments((cid, 'all'))
			posts = posts['comments']
		elif section == 'Questions':
			posts = self.content_questions((cid,'all'))
			posts = posts['questions']
		self.response['posts'] = posts
		self.response['section'] = section
		return self.response

class AJAXCards(FlashcardView):
	
	def __init__(self, request):
		self.request = request
		self.response = {}
		self.request = request
		self.response = self.user_info(self.userid)
		headers = ''
		if self.userid: 
			headers = remember(self.request, self.userid)
		self.response['headers'] = headers
	
	
	#Functions
	def add_vocab_translation(self, cardid, flemma):
		card = DBSession.query(Card).filter(Card.id==cardid).first()
		existing_f_lemma = DBSession.query(ForeignLemma).filter(ForeignLemma.form==flemma, ForeignLemma.language_id==card.language_id).first() 
		if existing_f_lemma == None:
			existing_f_lemma = ForeignLemma(form=flemma, language_id=int(card.language_id))
			DBSession.add(existing_f_lemma)
		DBSession.flush()
		existing_translation = DBSession.query(Translation).filter(Translation.card_id ==card.id, Translation.foreign_lemma_id==existing_f_lemma.id).first()
		if existing_translation == None:
			existing_translation = Translation(card_id=card.id, foreign_lemma_id=existing_f_lemma.id, count = 0)
			DBSession.add(existing_translation)
		existing_translation.count += 1
		card.translations.append(existing_translation)
		DBSession.flush()
	
	def add_vocab_item(self, (cardid, userid)):
		user = DBSession.query(AuthID).filter(AuthID.id == userid).first()
		beaker.cache.region_invalidate(BaseView.user_info, None, 'user_info', userid)
		existing_flashcard = DBSession.query(Flashcard).filter(Flashcard.card_id==cardid, Flashcard.owner ==userid).first()
		if existing_flashcard == None:
			flashcard = Flashcard(card_id=cardid, owner=userid, due=datetime.datetime.today())
			user.flashcards.append(flashcard)
			DBSession.flush()

	
	
	#AJAX and normal requests
	
	
	def add_flashcards(self):
		user = DBSession.query(AuthID).filter(AuthID.id == self.userid).first()
		vocab_items = [int(self.request.params['vocab_items'])]
		if int(self.request.params['vocab_len']) > 1:
			map(self.add_vocab_item, [(item, user.id) for item in vocab_items])
		else:
			self.add_vocab_item((int(self.request.params['vocab_items']), user.id))
		#self.response['response'] = self.add_vocab_item((vocab_items, user.id))
		return {'response' : 'hi'}
	
	
	def submit_flashcards(self):
		user = DBSession.query(AuthID).filter(AuthID.id == self.userid).first()
		vocabulary = self.content_vocab(self.cid, user.preferred_language)
		self.response['language'] = self.language_by_id(user.preferred_language)
		self.response['vocabulary'] = vocabulary
		if self.request.method=='POST':
			beaker.cache.region_invalidate(BaseView.user_info, None, 'user_info', user.id)
			results = []
			error = None
			for item in vocabulary:
				results.append(self.request.params[str(item['id'])])
			if results.count('') == 0:
				content.vocab_added_by.append(user)
				DBSession.flush()
				add_vocab_list(self.request, vocabulary)
				self.response['vocabulary'] = None
				self.response['language'] = None
			else:
				error = 'Missing translation(s)'
				response['vb_error'] = error
			if content_type == 'lesson':
				return HTTPFound(location = self.request.route_url('lesson_index', curl=content.url, cid=self.cid))
			elif content_type == 'reading':
				return HTTPFound(location = self.request.route_url('reading_index', curl=content.url, cid=self.cid))
			
			return self.response
		return self.response


def includeme(config):
	
	config.add_route('rate_difficulty', 'rate_difficulty/:cid')
	config.add_view(SubmitViews, attr='rate_difficulty', route_name='rate_difficulty', renderer="rate_difficulty.mako", permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('rate_quality', 'rate_quality/:cid')
	config.add_view(SubmitViews, attr='rate_quality', route_name='rate_quality', renderer="rate_quality.mako", permission=NO_PERMISSION_REQUIRED)

	config.add_route('add_comment', 'add_comment/:cid')
	config.add_view(SubmitViews, attr='add_comment', route_name='add_comment', renderer="add_comment.mako", permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('submit_comment', 'submit_comment/:cid')
	config.add_view(SubmitViews, attr='submit_comment', route_name='submit_comment', renderer="add_comment.mako", permission=NO_PERMISSION_REQUIRED)
	
	#config.add_route('add_flashcards', 'add_flashcards/:cid')
	#config.add_view(SubmitViews, attr='add_flashcards', route_name='add_flashcards', renderer='add_flashcards.mako', permission=NO_PERMISSION_REQUIRED)

	config.add_route('add_flashcards', 'add_flashcards')
	config.add_view(AJAXCards, attr='add_flashcards', route_name='add_flashcards', renderer='add_flashcards.mako', permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('submit_flashcards', 'submit_flashcards/:cid')
	config.add_view(SubmitViews, attr='submit_flashcards', route_name='submit_flashcards', renderer='add_flashcards.mako', permission=NO_PERMISSION_REQUIRED)

	config.add_route('report_score', 'report_score/:cid') 
	config.add_view(SubmitViews, attr='report_score', route_name='report_score', renderer='score_report.mako', permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('get_profile', 'get_profile')
	config.add_view(LoadViews, attr='get_profile', route_name= 'get_profile', renderer='get_profile.mako', permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('get_post', 'get_post')
	config.add_view(LoadViews, attr='get_post', route_name= 'get_post', renderer='get_post.mako', permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('get_all_posts', 'get_all_posts')
	config.add_view(LoadViews, attr='get_all_posts', route_name= 'get_all_posts', renderer='get_all_posts.mako', permission=NO_PERMISSION_REQUIRED)

