# -*- coding: utf-8 -*-

## content_views

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
from pyramid.decorator import reify
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
from user_views import BaseView

quiz_dir = '/home/user/venv/English/english/static/uploads/quizzes/'

"""CONTENT VIEWS"""

class ContentView(BaseView):
	
	def __init__(self, request):

		super(ContentView, self).__init__(request)
		content = DBSession.query(Content).filter(Content.id == self.cid).first()
		languageid = 0
		self.response.update(self.content_comments((self.cid, 5)))
		self.response.update(self.content_questions((self.cid, 5)))
		if self.userid:
			user = DBSession.query(AuthID).filter(AuthID.id==self.userid).first()
			if content.vocab_added_by.count(user) == 0:
				languageid = user.preferred_language
				vocab =  self.content_vocab((self.cid, languageid))
				self.response.update(vocab)
			self.response['content']  = self.content_stats((self.cid,self.userid))
			if str(user.groups[0]) == 'admin':
				self.response.update(self.content_comments((self.cid, 'all')))
				self.response.update(self.content_questions((self.cid, 'all')))
		else:
			self.response['content']  = self.content_stats((self.cid,0))
			vocab =  self.content_vocab((self.cid, languageid))
			self.response.update(vocab)
		
			
		

	
	@cache_region('hour', 'scoreboard')
	def scoreboard(self, today_number):
		today = datetime.date.today()
		today_number = today.toordinal()
		this_week = (today_number-(today_number % 7))/7
		this_month = today.month
		point_table_check(this_week, this_month)
		scoreboard = {'week': [], 'month': [], 'alltime' : []}
		weektotals = DBSession.query(WeeklyUserPoint,AuthID,Profile,Picture).filter(Profile.owner==WeeklyUserPoint.user_id,WeeklyUserPoint.user_id==AuthID.id, Profile.picture_id==Picture.id).order_by(WeeklyUserPoint.amount.desc()).limit(10)
		monthtotals = DBSession.query(MonthlyUserPoint,AuthID,Profile,Picture).filter(Profile.owner==MonthlyUserPoint.user_id,MonthlyUserPoint.user_id==AuthID.id, Profile.picture_id==Picture.id).order_by(MonthlyUserPoint.amount.desc()).limit(10)
		alltotals = DBSession.query(TotalUserPoint,AuthID,Profile,Picture).filter(Profile.owner==TotalUserPoint.user_id,TotalUserPoint.user_id==AuthID.id, Profile.picture_id==Picture.id).order_by(TotalUserPoint.amount.desc()).limit(10)
		for row in weektotals:
			scoreboard['week'].append({'username': row.AuthID.display_name, 'points': row.WeeklyUserPoint.amount, 'picture' : row.Picture.name})
		for row in monthtotals:
			scoreboard['month'].append({'username': row.AuthID.display_name, 'points': row.MonthlyUserPoint.amount, 'picture' : row.Picture.name})
		for row in alltotals:
			scoreboard['alltime'].append({'username': row.AuthID.display_name, 'points': row.TotalUserPoint.amount, 'picture' : row.Picture.name})
		return scoreboard
	
	
	@reify
	def cid(self):
		return self.request.matchdict['cid']
	
	@reify
	def url(self):
		return self.request.matchdict['curl']
	
	@cache_region('hour', 'content_stats')
	def content_stats(self, (cid, userid)):
		session = DBSession()
		content_stats = session.query(Content, Picture).filter(Content.id==cid, Content.picture_id == Picture.id).first()
		tags = [tag.name for tag in content_stats.Content.tags]
		quality = 0.0
		for vote in content_stats.Content.quality_votes: 
			quality += vote.score/(100.0)
		if len(content_stats.Content.quality_votes) > 0: quality = quality/(len(content_stats.Content.quality_votes))
		difficulty = 0.0
		for vote in content_stats.Content.difficulty_votes: 
			difficulty += vote.score/(100.0)
		if len(content_stats.Content.difficulty_votes) > 0: difficulty = difficulty/(len(content_stats.Content.difficulty_votes))
		flashcards = len(content_stats.Content.vocabulary)
		vote = {'d_score': difficulty, 'd_vote': 'disabled', 'q_score': quality, 'q_vote': 'disabled'}
		finished = False
		if userid !=0:
			user = DBSession.query(AuthID).filter(AuthID.id == self.userid).first()
			if content_stats.Content.quality_rated_by.count(user) == 0:
				vote['q_vote'] = ''
			if content_stats.Content.difficulty_rated_by.count(user) == 0:
				vote['d_vote'] = ''
			if content_stats.Content.finished_by.count(user):
				finished = True
		return {'cid': content_stats.Content.id, 'cflashcards': flashcards, 'finished': finished, 'title': content_stats.Content.title, 'type': content_stats.Content.type, 'description': content_stats.Content.description, 'views': content_stats.Content.views, 'url': content_stats.Content.url, 'picture': content_stats.Picture.name, 'tags': tags, 'vote': vote}
	
	@cache_region('threehours', 'language_by_id')	
	def language_by_id(self, languageid):
		session = DBSession()
		language_name = session.query(Language).filter(Language.id==languageid).first().english_name
		return language_name
	
	
	
	@cache_region('hour', 'content_questions')	
	def content_questions(self, (cid, question_cap)):
		session = DBSession()
		questions = session.query(Content, Comment).filter(Content.id==cid, Content.id==Comment.content_id, Comment.comment_type=='Q').order_by(Comment.time.desc())
		if question_cap != 'all':
			questions = questions.limit(question_cap).all()
		else:
			questions = questions.all()
		question_posts = []
		for question in questions:
			user_dict = self.get_profile_by_id(question.Comment.owner)
			children = []
			for reply in question.Comment.replies:
				replier_dict = self.get_profile_by_id(reply.owner)
				children.append({'time' : reply.time, 'user' : replier_dict, 'content': reply.text, 'id' : reply.id, 'parent_id': reply.parent_id})
			post_dict = {'time' : question.Comment.time, 'user' : user_dict, 'content': question.Comment.text,'id' : question.Comment.id, 'comment_type': 'Q', 'children' : children}
			question_posts.append(post_dict)
		if question_posts == None: question_posts = []
		return {'questions' : question_posts}
	
	@cache_region('hour', 'content_comments')	
	def content_comments(self, (cid, comment_cap)):
		session = DBSession()
		comments = session.query(Content, Comment).filter(Content.id==cid, Content.id==Comment.content_id, Comment.comment_type=='C').order_by(Comment.time.desc())
		if comment_cap != 'all':
			comments = comments.limit(comment_cap).all()
		else:
			comments = comments.all()
		comment_posts = []
		for comment in comments:
			user_dict = self.get_profile_by_id(comment.Comment.owner)
			children = []
			for reply in comment.Comment.replies:
				replier_dict = self.get_profile_by_id(reply.owner)
				children.append({'time' : reply.time, 'user' : replier_dict, 'content': reply.text, 'id' : reply.id, 'parent_id': reply.parent_id})
			post_dict = {'time' : comment.Comment.time, 'user' : user_dict, 'content': comment.Comment.text,'id' : comment.Comment.id, 'comment_type': 'C', 'children' : children}
			comment_posts.append(post_dict)
		if comment_posts == None: comment_posts = []
		return {'comments' : comment_posts}
	
	@cache_region('hour', 'get_comment_by_id')
	def get_comment_by_id(self, commentid):
		session = DBSession()
		comment = session.query(Comment).filter(Comment.id==commentid).first()
		user_dict = self.get_profile_by_id(comment.owner)
		return {'time' : comment.time, 'user' : user_dict, 'content': comment.text,'id' : comment.id, 'comment_type': comment.comment_type}
	
	@cache_region('hour', 'get_reply_by_id')
	def get_reply_by_id(self, replyid):
		session = DBSession()
		reply = session.query(CommentReply).filter(CommentReply.id==replyid).first()
		user_dict = self.get_profile_by_id(reply.owner)
		return {'time' : reply.time, 'user' : user_dict, 'content': reply.text,'id' : reply.id, 'parent_id': reply.parent_id}
	
	@cache_region('hour', 'content_vocab')
	def content_vocab(self, (cid, languageid)):
		session = DBSession()
		content = session.query(Content).filter(Content.id==cid).first()
		language = 'your language'
		if languageid != 0: language = self.language_by_id(languageid)
		vocabulary = []
		for english_lemma in content.vocabulary:
			form = session.query(EnglishForm).filter(EnglishForm.id==english_lemma.form_id).first().form
			example_sentence = re.sub('____', form, english_lemma.example_sentence)
			all_translation = session.query(Card,Translation,ForeignLemma).filter(Card.language_id==languageid).filter(Card.lemma_id==english_lemma.id).filter(Card.id==Translation.card_id).filter(Translation.foreign_lemma_id==ForeignLemma.id).order_by(func.count(Translation.count).desc()).first()
			vocab_item = {'form' : form, 'translation': u"{0}".format(all_translation.ForeignLemma.form), 'id': english_lemma.id, 'example_sentence': example_sentence, 'pos' :english_lemma.pos }
			vocabulary.append(vocab_item)
		return {'vocabulary': vocabulary, 'language':language}
	
class ManageContentViews(BaseView):
	def __init__(self, request):
		self.request = request
		super(ManageContentViews, self).__init__(self.request)
	
	
	
	
	## Views: Add
	def add_reading(self):
		form = AddReadingForm(self.request.POST, type='reading')
		self.response['form'] = form
		form.data['type'] = 'reading'
		self.response['title'] = 'Add a reading'
		self.response['content_type'] = 'reading'
		return self.response
	
	def add_lesson(self):
		form = NewLessonForm(obj=Lesson(), method=self.request.POST)
		self.response['form'] = form
		form.data['type'] = 'lesson'
		self.response['title'] = 'Add a lesson'
		self.response['content_type'] = 'lesson'
		if self.request.method == 'POST' and form.validate():
			j = 1/0
		return self.response
	
	def add_content(self):
		content_type = self.request.matchdict['content_type']
		self.response['title'] ='Add content'
		self.response['content_type'] = content_type
		if content_type == 'lesson':
			form = NewLessonForm(self.request.POST)
		
		elif content_type == 'reading':
			form = AddReadingForm(self.request.POST)
		
		if self.request.method == 'POST' and form.validate():
			q = Quiz()
			DBSession.add(q)
			DBSession.flush()
			form.create(self.userid, q.id)
			DBSession.flush()
			return HTTPFound(location = self.request.route_url('add_quiz', quiz_id=q.id))
		return self.response
	
	def add_quiz(self):
		quizid = self.request.matchdict['quiz_id']
		quiz = DBSession.query(Quiz).filter(Quiz.id==quizid).first()
		form = AddQuizForm(self.request.POST)
		form.title.data = quiz.title
		form.tagline.data = quiz.tagline
		self.response['form'] = form
		self.response['title'] = 'Add a quiz'
		if self.request.method == 'POST' and form.validate():
			form.create(self.request.params)
			return HTTPFound(location = self.request.route_url('my_content'))
		return self.response
	
	#Views: edit
	def edit_content(self):
		content_id = self.request.matchdict['content_id']
		content = DBSession.query(Content).filter(Content.id == content_id).first()
		self.response['title'] ='Edit content'
		self.response['content_id'] = content_id
		if content.type == 'lesson':
			form = EditLessonForm(self.request.POST)
		elif content.type == 'reading':
			form = EditReadingForm(self.request.POST)
		self.response['form'] = form
		if self.request.method == 'POST' and form.validate():
			quiz_id, content = form.edit(content)
			content.owner = self.userid
			if form.data['picture_id']:
				picture = form.data['picture_id']
				imageid = content.picture_id
				pic_id = replace_image(request, picture, imageid, situation='lesson')
			DBSession.flush()
			if form.data['keepquiz'] == 'no': 
				return HTTPFound(location = self.request.route_url('edit_quiz', quiz_id=quiz_id), headers = self.response['headers'])
			else: return HTTPFound(location = self.request.route_url('home'), headers=self.response['headers'])
		return self.response
	
	def edit_quiz(self):
		quizid = self.request.matchdict['quiz_id']
		quiz = DBSession.query(Quiz).filter(Quiz.id==quizid).first()
		form = EditQuizForm(self.request.POST, obj=quiz)
		self.response['form'] = form
		self.response['title'] = "Edit quiz"
		if self.request.method == 'POST' and form.validate():
			form.update()
			return HTTPFound(location = self.request.route_url('my_content'))
		return self.response
	
	
	def my_content(self):
		userlessons = DBSession.query(Lesson, Content).filter(Content.owner==self.userid, Lesson.content_id==Content.id).all()
		userreadings = DBSession.query(Reading, Content).filter(Content.owner==self.userid, Reading.content_id==Content.id).all()
		userflashcards = DBSession.query(EnglishLemma,EnglishForm).filter(EnglishForm.id==EnglishLemma.form_id, EnglishLemma.owner==self.userid).all()
		contents = []
		flashcards = []
		for content in userlessons:
			contents.append({'title': content.Content.title, 'type': 'lesson', 'description': content.Content.description, 'id': content.Lesson.id})
		for content in userreadings:
			contents.append({'title': content.Content.title, 'type': 'reading', 'description': content.Content.description, 'id': content.Reading.id})
		for flashcard in userflashcards:
			flashcards.append({'id' : flashcard.EnglishLemma.id, 'form' :flashcard.EnglishForm.form})
		self.response['lessons'] = contents
		self.response['myflashcards'] = flashcards
		return self.response
		
	def edit_lesson(self):
		lessonid = self.request.matchdict['lesson_id']
		lessonall = DBSession.query(Lesson,Content).filter(Lesson.id==lessonid,Lesson.content_id == Content.id).first()
		title = lessonall.Content.title
		description = lessonall.Content.title
		url = lessonall.Content.url
		tags = lessonall.Content.tags
		tag_string = ''
		for indx in xrange(0, len(tags) -1):
			tag_string += tags[indx].name +' , '
		tag_string += tags[-1].name	
		video = lessonall.Lesson.video
		form = EditLessonForm(self.request.POST, title = title, description = description, slug = url, tags = tag_string, video = video)
		self.response['title'] = 'Edit this lesson'
		self.response['form'] = form
		self.response['content_id'] = lessonall.Content.id
		return self.response
		
	def edit_reading(self):
		readingid = self.request.matchdict['reading_id']
		readingall = DBSession.query(Reading,Content).filter(Reading.id==readingid,Reading.content_id == Content.id).first()
		title = readingall.Content.title
		description = readingall.Content.description
		url = readingall.Content.url
		tags = readingall.Content.tags
		tag_string = ''
		for indx in xrange(0, len(tags) -1):
			tag_string += tags[indx].name +' , '
		tag_string += tags[-1].name	
		text = readingall.Reading.text
		sources = DBSession.query(Source).filter(Source.reading_id == readingid).all()
		if sources == None:
			form = EditReadingForm(self.request.POST, title = title, description = description, slug = url, tags = tag_string, text = text)
		elif len(sources) >= 3:
			form = EditReadingForm(self.request.POST, title = title, description = description, slug = url, tags = tag_string, text = text,
			author=sources[0].author, source=sources[0].source, url=sources[0].url, stitle=sources[0].title,
			au_lethor2=sources[1].author, source2=sources[1].source, url2=sources[1].url, stitle2=sources[1].title,
			author3=sources[2].author, source3=sources[2].source, url3=sources[2].url, stitle3=sources[2].title)
		elif len(sources) == 2:
			form = EditReadingForm(self.request.POST, title = title, description = description, slug = url, tags = tag_string, text = text,
			author=sources[0].author, source=sources[0].source, url=sources[0].url, stitle=sources[0].title,
			author2=sources[1].author, source2=sources[1].source, url2=sources[1].url, stitle2=sources[1].title)
		elif len(sources) == 1:
			form = EditReadingForm(self.request.POST, title = title, description = description, slug = url, tags = tag_string, text = text,
			author=sources[0].author, source=sources[0].source, url=sources[0].url, stitle=sources[0].title)
		self.response['title'] = 'Edit this reading'
		self.response['form'] = form
		self.response['content_id'] = readingall.Content.id
		return self.response
		
	def edit_flashcard(self):
		flashcardid = self.request.matchdict['flashcard_id']
		flashcard = DBSession.query(EnglishLemma).filter(EnglishLemma.id==flashcardid).first()
		form = LemmaForm(self.request.POST, obj=flashcard)
		self.response['form'] = form
		self.response['title'] = 'Edit this flashcard'
		if self.request.method == 'POST' and form.validate():
			form.update()
			return HTTPFound(location = self.request.route_url('my_content'))
		return self.response



class LinkViews(ContentView):
	
	def __init__(self, request):
		self.response = {}
		self.request = request
		self.response = self.user_info(self.userid)
		headers = ''
		if self.userid: 
			headers = remember(self.request, self.userid)
		self.response['headers'] = headers
		
	
	@cache_region('twentymins', 'search')
	def search(self, (search_criteria, userid)):
		baselinklist = DBSession.query(Content).filter(Content.released <= datetime.date.today())
		content_type = search_criteria['content_type']
		if content_type != 'all':
			baselinklist = baselinklist.filter(Content.type == content_type) 
		limit = search_criteria['results_limit']
		date_difference = search_criteria['upload_date']
		upload_date = date.fromordinal(date.today().toordinal()-int(date_difference)).isoformat()
		baselinklist = baselinklist.filter(Content.released >= upload_date)
		if search_criteria['completed'] == 'true':
			baselinklist = baselinklist.filter(~Content.finished_by.any(AuthID.id==userid))
		if search_criteria['tag']:
			tag = DBSession.query(Tag).filter(Tag.name==search_criteria['tag']).first()
			baselinklist = baselinklist.filter(Content.tags.contains(tag))
		if search_criteria['order_by'] == 'created':
			baselinklist = baselinklist.order_by(Content.released.desc())
		elif search_criteria['order_by'] == 'easy':
			baselinklist = baselinklist.join(DifficultyVote).order_by(func.avg(DifficultyVote.score).asc())
		elif search_criteria['order_by'] == 'hard':
			baselinklist = baselinklist.join(DifficultyVote).order_by(func.avg(DifficultyVote.score).desc())
		elif search_criteria['order_by'] == 'quality':
			baselinklist = baselinklist.join(QualityVote).order_by(func.avg(QualityVote.score).desc())
		elif search_criteria['order_by'] == 'views':
			baselinklist = baselinklist.order_by(Content.views.desc())
		elif search_criteria['order_by'] == 'flashcards':
			baselinklist = baselinklist.join(EnglishLemma).group_by(EnglishLemma.contents_id).order_by(func.count(EnglishLemma.id).desc())
		linklist = baselinklist.limit(limit)
		contents = []
		for link in linklist:
			if userid != 0:
				content_dict = self.content_stats((link.id, userid))
			else:content_dict = self.content_stats((link.id, 0))
			contents.append(content_dict)
		return contents
		
		
	## Views
	def view_classroom(self):
		##Search criteria
		search_criteria = {}
		limit = 15
		search_criteria['content_type'] = 'all'
		search_criteria['results_limit'] = '7'
		search_criteria['upload_date'] = "100000"
		search_criteria['completed'] = 'false'
		search_criteria['order_by'] = 'created'
		search_criteria['tag'] = ''
		## View
		if self.userid:
			linklist = self.search((search_criteria,self.userid))
		else: linklist = self.search((search_criteria, 0))
		contents = []
		for indx, link in enumerate(linklist):
			if indx == 0:
				content = DBSession.query(Content).filter(Content.id == link['cid']).first()
				content.views += 1
				self.response['debut_content'] = link
				if link['type'] == 'lesson':
					self.response['debut_content']['video'] = DBSession.query(Lesson).filter(Lesson.content_id==link['cid']).first().video
				elif link['type'] == 'reading':
					reading = DBSession.query(Reading).filter(Reading.content_id==link['cid']).first()
					self.response['debut_content']['text'] = reading.text
					sources = []
					for source in reading.sources:
						sources.append({'author': source.author, 'url' : source.url, 'title' : source.title, 'source' :source.source, 'date' : source.date})
					self.response['debut_content']['sources'] = sources
			else:
				contents.append(link)
		self.response['links'] = contents
		self.response['scoreboard'] = self.scoreboard(1)
		return self.response
	
	def search_view(self):
		content_type = self.request.matchdict['content_type']
		##Search criteria
		search_criteria = {}
		limit = 15
		search_criteria['content_type'] = content_type
		search_criteria['results_limit'] = '15'
		search_criteria['upload_date'] = "100000"
		search_criteria['completed'] = 'false'
		search_criteria['tag'] = ''
		search_criteria['order_by'] = 'created'
		#searches
		self.response['search_criteria'] = search_criteria
		if self.request.params.has_key('content_type'):
			search_criteria['content_type'] = self.request.params['content_type']
		if self.request.params.has_key('results_limit'): 
			search_criteria['results_limit'] = self.request.params['results_limit']
		if self.request.params.has_key('upload_date'): 
			date_difference = self.request.params['upload_date']
			search_criteria['upload_date'] = self.request.params['upload_date']
		if self.request.params.has_key('completed'):
			search_criteria['completed'] = self.request.params['completed']
		if self.request.params.has_key('order_by'):
			search_criteria['order_by'] = self.request.params['order_by']
		if self.userid:
			self.response['links'] = self.search((search_criteria,self.userid))
		else: self.response['links'] = self.search((search_criteria, 0))
		return self.response
	
	def view_tag(self):
		tag = self.request.matchdict['tag_name']
		##Search criteria
		search_criteria = {}
		limit = 15
		search_criteria['content_type'] = 'all'
		search_criteria['results_limit'] = '15'
		search_criteria['upload_date'] = "100000"
		search_criteria['completed'] = 'false'
		search_criteria['tag'] = tag
		search_criteria['order_by'] = 'created'
		#searches
		self.response['search_criteria'] = search_criteria
		if self.request.params.has_key('content_type'):
			search_criteria['content_type'] = self.request.params['content_type']
		if self.request.params.has_key('results_limit'): 
			search_criteria['results_limit'] = self.request.params['results_limit']
		if self.request.params.has_key('upload_date'): 
			date_difference = self.request.params['upload_date']
			search_criteria['upload_date'] = self.request.params['upload_date']
		if self.request.params.has_key('completed'):
			search_criteria['completed'] = self.request.params['completed']
		if self.request.params.has_key('order_by'):
			search_criteria['order_by'] = self.request.params['order_by']
		if self.userid:
			self.response['links'] = self.search((search_criteria,self.userid))
		else: self.response['links'] = self.search((search_criteria, 0))
		return self.response


class LessonViews(ContentView):
	
	def __init__(self, request):
		self.request = request
		super(LessonViews, self).__init__(self.request)
		
		
	@cache_region('hour', 'lesson_content')
	def lesson_content(self, cid):
		content = DBSession.query(Lesson,Content,Quiz).filter(Content.id == cid, Quiz.id==Content.quiz_id, Lesson.content_id ==Content.id).first()
		quiz = content.Quiz
		return {'video': content.Lesson.video, 'quiz' : quiz.json_id()}
	
	def view_lesson(self):
		if self.userid:
			title = 'Add a comment or question!'
			form = CommentQuestionForm(self.request.POST)
		else:
			form = ''
			title = ''
		self.response['form'] = form
		self.response['form_title'] = title
		self.response['content'].update(self.lesson_content(self.cid))
		return self.response

class ReadingViews(ContentView):
	
	def __init__(self, request):
		self.request = request
		super(ReadingViews, self).__init__(self.request)
		if self.userid:
			title = 'Add a comment or question!'
			form = CommentQuestionForm(request.POST)
		else:
			form = ''
			title = ''
		self.response['form'] = form
		self.response['form_title'] = title

	
	@cache_region('hour', 'reading_content')
	def reading_content(self, cid):
		content = DBSession.query(Reading,Content,Quiz).filter(Content.id == cid, Quiz.id==Reading.quiz_id, Reading.content_id ==Content.id).first()
		sources = []
		for source in content.Reading.sources:
			sources.append({'author': source.author, 'url' : source.url, 'title' : source.title, 'source' :source.source, 'date' : source.date})
		return {'text': content.Reading.text, 'quiz' :content.Quiz.name, 'sources' : sources}
	
	
	def view_reading(self):
		self.response['content'].update(self.reading_content(self.cid))
		return self.response



		
def includeme(config):
	
	config.add_route('home', '')
	config.add_view(LinkViews, attr='view_classroom', route_name= 'home', renderer='index.mako', permission=NO_PERMISSION_REQUIRED)
	
	
	config.add_route('lesson_index', '/lesson/:cid/:curl')
	config.add_view(LessonViews, attr='view_lesson', route_name='lesson_index', renderer='lesson_index.mako', permission=NO_PERMISSION_REQUIRED)

	config.add_route('reading_index', '/reading/:cid/:curl')
	config.add_view(ReadingViews, attr='view_reading', route_name='reading_index', renderer='reading_index.mako', permission=NO_PERMISSION_REQUIRED)
	
	
	#Search
	config.add_route('search', 'search/:content_type')
	config.add_view(LinkViews, attr='search_view', route_name= 'search', renderer='search_content.mako', permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('tag_index', '/tags/:tag_name')
	config.add_view(LinkViews, attr='view_tag', route_name= 'tag_index', renderer='search_content.mako', permission=NO_PERMISSION_REQUIRED)
	
	
	#Add
	config.add_route('add_lesson', '/add_lesson') 
	config.add_view(ManageContentViews, attr='add_lesson', route_name='add_lesson', renderer='add_content.mako', permission=u'add')
	
	config.add_route('add_reading', '/add_reading') 
	config.add_view(ManageContentViews, attr='add_reading', route_name='add_reading', renderer='add_content.mako', permission=u'add')
	
	config.add_route('add_content', '/add_content/:content_type') 
	config.add_view(ManageContentViews, attr='add_content', route_name='add_content', renderer='add_content.mako', permission=u'add')
	
	config.add_route('add_quiz', '/add_quiz/:quiz_id') 
	config.add_view(ManageContentViews, attr='add_quiz', route_name='add_quiz', renderer='add_quiz.mako', permission=u'add')
	
	
	#Edit
	config.add_route('my_content', '/my_content') 
	config.add_view(ManageContentViews, attr='my_content', route_name='my_content', renderer='my_content.mako', permission=u'add')
	
	config.add_route('edit_lesson', '/edit_lesson/:lesson_id') 
	config.add_view(ManageContentViews, attr='edit_lesson', route_name='edit_lesson', renderer='edit_content.mako', permission=u'add')
	
	config.add_route('edit_reading', '/edit_reading/:reading_id') 
	config.add_view(ManageContentViews, attr='edit_reading', route_name='edit_reading', renderer='edit_content.mako', permission=u'add')
	
	config.add_route('edit_content', '/edit_content/:content_id') 
	config.add_view(ManageContentViews, attr='edit_content', route_name='edit_content', renderer='edit_content.mako', permission=u'add')
	
	config.add_route('edit_flashcard', '/edit_flashcard/:flashcard_id') 
	config.add_view(ManageContentViews, attr='edit_flashcard', route_name='edit_flashcard', renderer='file_form.mako', permission=u'add')
	
	config.add_route('edit_quiz', '/edit_quiz/:quiz_id') 
	config.add_view(ManageContentViews, attr='edit_quiz', route_name='edit_quiz', renderer='form.mako', permission=u'add')


