# -*- coding: utf-8 -*-

## flashcard_views

import json
import os
import shutil
import glob
from pyramid.response import Response
from pyramid.request import Request
from pyramid.view import view_config
import uuid
import Image
from sqlalchemy.exc import DBAPIError
from sqlalchemy.orm import aliased
from sqlalchemy import exists
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
from user_views import BaseView

AUTO_PICTURE_DIR = '/home/user/venv/English/english/static/to_upload/images'


class FlashcardView(BaseView):
	
	def __init__(self,request):
		self.request = request
		super(FlashcardView, self).__init__(request)
		
		
	@cache_region('threehours', 'get_flashcard')
	def get_flashcard(self, (cardid, languageid)):
		translations = [translation.ForeignLemma.form for translation in DBSession.query(Translation,ForeignLemma).filter(Translation.card_id==cardid, ForeignLemma.id==Translation.foreign_lemma_id).order_by((Translation.count).desc()).limit(3)]
		fdistractors_query = DBSession.query(ForeignLemma).filter(ForeignLemma.language_id ==languageid)
		for translation in translations:
			fdistractors_query = fdistractors_query.filter(ForeignLemma.form != translation)
		foreigndistractors = [result.form for result in fdistractors_query.limit(7)]
		return  {'translations':translations, 'sourceDistractors' : foreigndistractors}
	
	
	@cache_region('threehours', 'get_card')
	def get_card(self, cardid):
		card = DBSession.query(Card,EnglishLemma,EnglishForm, Picture).filter(Card.id == cardid, Card.lemma_id==EnglishLemma.id,EnglishLemma.form_id==EnglishForm.id,EnglishLemma.picture_id==Picture.id).first()
		sentence = card.EnglishLemma.example_sentence
		pos = card.EnglishLemma.pos
		answer = card.EnglishForm.form
		picture = card.Picture.name
		edistractors_query = DBSession.query(EnglishForm).filter(EnglishForm.id !=card.EnglishForm.id)
		englishdistractors = [result.form for result in edistractors_query.limit(7)]
		return {'cardid': card.Card.id, 'sentence':sentence, 'pos' : pos, 'answer': answer, 'picturename' : picture, 'targetDistractors': englishdistractors}
	
	@cache_region('threehours', 'get_lemma')
	def get_lemma(self, lemmaid):
		lemma = DBSession.query(EnglishLemma,EnglishForm, Picture).filter(EnglishLemma.id == lemmaid,EnglishLemma.form_id==EnglishForm.id,EnglishLemma.picture_id==Picture.id).first()
		pos = lemma.EnglishLemma.pos
		answer = lemma.EnglishForm.form
		sentence = lemma.EnglishLemma.example_sentence.replace('____', answer)
		picture = lemma.Picture.name
		return {'sentence':sentence, 'pos' : pos, 'answer': answer, 'picturename' : picture}

	@cache_region('twentymins', 'search')
	def search(self, (search_criteria, preferred_language)):
		if preferred_language != 0:
			baselist = DBSession.query(EnglishLemma, Card, EnglishForm).filter(Card.lemma_id==EnglishLemma.id, EnglishLemma.form_id == EnglishForm.id, Card.language_id==preferred_language)
		else:
			baselist = DBSession.query(EnglishLemma, EnglishForm).filter(EnglishLemma.form_id == EnglishForm.id)
		 ###Search criteria
		lemma_type = search_criteria['lemma_type']
		letter = search_criteria['letter']
		limit = search_criteria['results_limit']
		###Selection
		if lemma_type != 'any':
			baselist = baselist.filter(EnglishLemma.pos == lemma_type)
		if letter != 'any':
			baselist = baselist.filter(EnglishForm.form.like('%{0}'.format(letter)))
		###Sorting
		if search_criteria['order_by'] == 'frequency':
			baselist = baselist.join(FormInfo, EnglishLemma.form_id==FormInfo.form_id).order_by(FormInfo.freq.desc())
		if search_criteria['order_by'] == 'popularity':
			baselist = baselist.outerjoin(Card, Card.lemma_id==EnglishLemma.id)
			baselist = baselist.outerjoin(Flashcard, Flashcard.card_id==Card.id).order_by(func.count(Flashcard.id))
		if search_criteria['order_by'] == 'recent':
			baselist = baselist.order_by(EnglishLemma.id.desc())
		###
		baselist = baselist.limit(limit)
		words_dict = []
		for lemma in baselist:
			if preferred_language != 0:
				word_dict = self.get_card(lemma.Card.id)
			else:
				word_dict = self.get_lemma(lemma.EnglishLemma.id)
			word_dict['len'] = 1
			words_dict.append(word_dict)
		return words_dict
		
	def process_drill_results(self, drill_results):
		session = DBSession()
		for flashcard_id in drill_results.keys():
			flashcard = session.query(Flashcard).filter_by(id=flashcard_id).first()
			flashcard.level = drill_results[flashcard_id]['ending_level']
			flashcard.correct += drill_results[flashcard_id]['correct']
			flashcard.incorrect += drill_results[flashcard_id]['incorrect']
			if drill_results[flashcard_id]['ending_level'].find('Flashcard') == 0:
				if drill_results[flashcard_id]['correct'] > drill_results[flashcard_id]['incorrect'] and flashcard.ease < 3500:
					flashcard.ease += flashcard.correct/(flashcard.incorrect+flashcard.correct)*100
				elif drill_results[flashcard_id]['correct'] < drill_results[flashcard_id]['incorrect'] and flashcard.ease > 1500:
					flashcard.ease -= flashcard.incorrect/(flashcard.incorrect+flashcard.correct)*100
				flashcard.interval= int(flashcard.interval*flashcard.ease/1000.0)
				flashcard.due = datetime.date.fromordinal(datetime.date.today().toordinal()+int(flashcard.interval/10))
		beaker.cache.region_invalidate(BaseView.user_info, None, 'user_info', flashcard.id)
		session.flush()
	
	def moveUP(self, s):
		if s == 'Show':
			return '4Source'
		elif s.find('Flashcard') ==0:
			if (int(s[-1])+1) <= 8:
				s = s.replace(s[-1], str(int(s[-1])+1))
			return s
		elif s.find('4') != -1:
			return s.replace('4', '8')
		elif s.find('8Source') == 0:
			return '4Target'
		elif s.find('8Target') == 0:
			return 'Flashcard1'
	
	def create_form(self, v):
		form = self.request.params['form{0}'.format(v)]
		english_form = DBSession.query(EnglishForm).filter(EnglishForm.form == form).first()
		
		if english_form == None:
			english_form = EnglishForm(form =form)
			DBSession.add(english_form)
			DBSession.flush()
		example_sentence = re.sub(form, '____', self.request.params['example_sentence{0}'.format(v)])
		pos = self.request.params['pos{0}'.format(v)]
		if self.request.params['picloc{0}'.format(v)] != 'other':
			picture = os.path.join(AUTO_PICTURE_DIR, '{0}.jpg'.format(self.request.params['picloc{0}'.format(v)]))
		else:
			if 'picture{0}'.format(v) in self.request.params:
				picture = self.request.params['picture{0}'.format(v)]
		pic_id = add_image(self.request, picture, self.userid, situation='flashcard')
		english_lemma = EnglishLemma(owner=self.userid, form_id = english_form.id, example_sentence=example_sentence, pos=pos, picture_id=pic_id)
		DBSession.add(english_lemma)
		DBSession.flush() 
		langs = DBSession.query(Language).all()
		for lang in langs:
			card = Card(lemma_id = english_lemma.id, language_id = lang.id)
			DBSession.add(card)
		DBSession.flush()
	
	## Views
	
	def add_forms(self):
		withoutlemma = DBSession.query(EnglishForm).filter(~exists().where(EnglishLemma.form_id==EnglishForm.id)).all()
		self.response['forms'] = [x.form for x in withoutlemma]
		return self.response
		
	def add_form(self):
		wordform = str(self.request.matchdict['word_form'])
		info = DBSession.query(EnglishForm, FormInfo).filter(EnglishForm.id == FormInfo.form_id, EnglishForm.form == wordform).first()
		self.response['pictures'] = ['{0}1'.format(wordform),'{0}2'.format(wordform), '{0}3'.format(wordform),'{0}4'.format(wordform)]
		self.response['wordform'] = wordform
		self.response.update({'freq' : info.FormInfo.freq, 'senses' : info.FormInfo.definitions})
		if self.request.method == 'POST':
			vocab_length = int(self.request.params['vocab_items'])
			self.create_form(v='')
			for v in xrange(1, vocab_length):
				self.create_form(str(v))
			return HTTPFound(location = self.request.route_url('add_forms'))
		return self.response
		
	
	def flashcard_tree(self):
		parentname = str(self.request.matchdict['parent_name'])
		parentid = int(self.request.matchdict['pid'])
		parent = DBSession.query(EnglishLemmaCategory).filter(EnglishLemmaCategory.id==parentid).first()
		children = DBSession.query(EnglishLemmaCategory).filter(EnglishLemmaCategory.left > parent.left, EnglishLemmaCategory.right < parent.right, EnglishLemmaCategory.level == parent.level + 1).all()
		self.response['parent'] = {}
		self.response['parent']['title'] = parent.name
		self.response['parent']['children'] = []
		for child in children:
			self.response['parent']['children'].append(child.name)
		return self.response

	def abc_flashcards(self):
		return self.response

	def add_flashcards(self):
		pass
	
	
	def search_flashcards(self):
		search_criteria = {}
		### Default settings
		limit = 30
		search_criteria['lemma_type'] = 'all'
		search_criteria['letter'] = 'any'
		search_criteria['order_by'] = 'frequency'
		search_criteria['limit'] = limit
		###Change settings if they exist
		if self.request.params.has_key('letter'):
			search_criteria['letter'] = self.request.params['letter']
		if self.request.params.has_key('lemma_type'):
			search_criteria['lemma_type'] = self.request.params['lemma_type']
		if self.request.params.has_key('results_limit'):
			search_criteria['results_limit'] = self.request.params['results_limit']
		if self.request.params.has_key('order_by'):
			search_criteria['order_by'] = self.request.params['order_by']
		search_criteria['results_limit'] = limit
		preferred_language = 0
		if self.userid:
			preferred_language = DBSession.query(AuthID).filter(AuthID.id == self.userid).first().preferred_language
		self.response['words'] = self.search((search_criteria, preferred_language))
		self.response['search_criteria'] = search_criteria
		return self.response

	def my_flashcards(self):
		user = DBSession.query(AuthID).filter(AuthID.id==self.userid).first()
		flashcards = user.sorted_flashcards()
		self.response['flashcards_overdue'] = len(flashcards['overdue'])
		self.response['flashcards_today'] = len(flashcards['today'])
		self.response['flashcards_tomorrow'] = len(flashcards['tomorrow'])
		self.response['flashcards_this_week'] = len(flashcards['this_week'])
		self.response['flashcards_next_week'] = len(flashcards['next_week'])
		self.response['total_flashcards'] = len(user.flashcards)
		return self.response

	def practice_flashcards(self):
		flashcards = DBSession.query(Flashcard,Card).filter(Flashcard.owner==self.userid, Flashcard.level != 'Show', Card.id ==Flashcard.card_id).filter(Flashcard.due <= datetime.date.today()).order_by((Flashcard.due).desc()).limit(30)
		flashcard_deck = []
		drill_results = {}
		position = 1
		self.response['drill'] = uuid.uuid4().node
		for flashcard in flashcards:
			card = self.get_card(flashcard.Card.id)
			card.update({'level': flashcard.Flashcard.level, 'points': 40, 'cid' : flashcard.Flashcard.id, 'position' : position})
			card['picture'] = self.request.static_url('english:/static/uploads/pictures/{0}.jpeg'.format(card['picturename']))
			flashcard_data = self.get_flashcard((flashcard.Card.id, flashcard.Card.language_id))
			card.update(flashcard_data)
			flashcard_deck.append(card)
			position +=1
		self.response['flashcard_json'] = json.dumps(flashcard_deck)
		return self.response

	def introduce_flashcards(self):
		flashcards = DBSession.query(Flashcard,Card).filter(Flashcard.owner==self.userid, Flashcard.level != 'Show', Card.id ==Flashcard.card_id).filter(Flashcard.due <= datetime.date.today()).order_by((Flashcard.due).desc()).limit(30)
		flashcard_deck = []
		drill_results = {}
		position = 1
		self.response['drill'] = uuid.uuid4().node
		for flashcard in flashcards:
			card = self.get_card(flashcard.Card.id)
			card.update({'level': flashcard.Flashcard.level, 'points': 40, 'cid' : flashcard.Flashcard.id, 'position' : position})
			card['picture'] = self.request.static_url('english:/static/uploads/pictures/{0}.jpeg'.format(card['picturename']))
			flashcard_data = self.get_flashcard((flashcard.Card.id, flashcard.Card.language_id))
			card.update(flashcard_data)
			flashcard_deck.append(card)
			position +=1
		self.response['flashcard_json'] = json.dumps(flashcard_deck)
		return self.response

	def report_drill_results(self):
		drill_results = {}
		if 'activity_type' in self.request.params:
			points_scored = 0
			if self.request.params['current_card'] != '0':
				for indx in xrange(0, int(self.request.params['current_card'])+1):
					points_scored += int(self.request.params['score'+str(indx)])
					card = int(self.request.params['card'+str(indx)])
					lvl = self.request.params['level'+str(indx)]
					time = int(float(self.request.params['time'+str(indx)])*100)
					resp = self.request.params['response'+str(indx)]
					corr = self.request.params['correct'+str(indx)]
					drill_results.setdefault(card, {'correct' : 0, 'incorrect' : 0, 'ending_level' : lvl})
					if corr == 'True' and lvl != 'Show':
						fhistory = FlashcardHistory(flashcard_id=card, response_time = time, response = resp, correct=True, level = lvl)
						drill_results[card]['correct'] += 1
						drill_results[card]['ending_level'] = moveUP(lvl)
					elif corr == 'False' and lvl != 'Show':
						fhistory = FlashcardHistory(flashcard_id=card, response_time = time, response = resp, correct=False, level=lvl)
						drill_results[card]['incorrect'] += 1
					if lvl != 'Show': DBSession.add(fhistory)
				self.process_drill_results(drill_results)
			return HTTPFound(location = self.request.route_url('my_flashcards'))
		return 'messed up'



	def flashcards_demo(self):
		self.response['flashcard_json'] = ''
		self.response['language'] = ''
		self.response['vocabulary'] = ''
		self.response['vb_error'] = ''
		self.response['drill'] = 1
		self.response['language_options'] =  [{'id': language.id, 'e_name': language.english_name, 'n_name' : language.native_name} for language in DBSession.query(Language).all()]
		if 'configure' in self.request.params:
			languageid = self.request.params["preferred_language"]
			language = DBSession.query(Language).filter_by(id=languageid).first()
			language_name = language.english_name
			vocabulary = []
			for indx in range(1,6):
				english_lemma = DBSession.query(EnglishLemma).filter_by(id=indx).first()
				form = DBSession.query(EnglishForm).filter(EnglishForm.id==english_lemma.form_id).first().form
				example_sentence = re.sub('____', form, english_lemma.example_sentence)
				all_translation = DBSession.query(Card,Translation,ForeignLemma).filter(Card.language_id==languageid, Card.lemma_id==english_lemma.id, Card.id==Translation.card_id, Translation.foreign_lemma_id==ForeignLemma.id).order_by(func.count(Translation.count).desc()).first()
				cid = DBSession.query(Card).filter(Card.lemma_id==english_lemma.id,Card.language_id==languageid).first()
				if cid == None:
					card = Card(lemma_id=english_lemma.id,language_id=languageid)
					DBSession.add(card)
					DBSession.flush()
					cid = card.id
				else: cid = cid.id
				vocab_item = {'form' : form, 'translation': u"{0}".format(all_translation.ForeignLemma.form), 'cid' : cid , 'fid' : all_translation.ForeignLemma.language_id, 'id': english_lemma.id, 'example_sentence': example_sentence, 'pos' :english_lemma.pos }
				vocabulary.append(vocab_item)
			self.response['vocabulary'] = vocabulary
			self.response['language'] = language_name
			if self.request.method=='POST' and self.request.POST.keys().count('add') > 0:
				results = []
				error = None
				for item in vocabulary:
					card = DBSession.query(Card).filter(Card.id==item['cid']).first()
					foreign_form = unicode(self.request.params[str(item['id'])]).strip()
					results.append(foreign_form)
					existing_f_lemma = DBSession.query(ForeignLemma).filter(ForeignLemma.form==foreign_form, ForeignLemma.language_id==int(languageid)).first() 
					if existing_f_lemma == None:
						existing_f_lemma = ForeignLemma(form=foreign_form, language_id=int(languageid))
						DBSession.add(existing_f_lemma)
					existing_translation = DBSession.query(Translation).filter(Translation.card_id ==card.id, Translation.foreign_lemma_id==existing_f_lemma.id).first()
					if existing_translation == None:
						existing_translation = Translation(card_id=card.id, foreign_lemma_id=existing_f_lemma.id, count = 0)
						DBSession.add(existing_translation)
					existing_translation.count += 1
					card.translations.append(existing_translation)
				if results.count('') == 0:
					position = 1
					flashcard_deck = []
					for vocab_item in vocabulary:
						pos = vocab_item['pos']
						form = vocab_item['form']
						englishform = DBSession.query(EnglishForm).filter(EnglishForm.form==form).first()
						flashcard = DBSession.query(Card,Picture).filter(Card.id==vocab_item['cid'],Card.lemma_id == EnglishLemma.id, Picture.id==EnglishLemma.picture_id).first()
						sentence = re.sub(form, '____', vocab_item['example_sentence'])
						level = 'Show'
						points = 40
						picture = self.request.static_url('english:/static/uploads/pictures/{0}.jpeg'.format(flashcard.Picture.name))
						id = flashcard.Card.id
						translations = [translation.ForeignLemma.form for translation in DBSession.query(Translation,ForeignLemma).filter(Translation.card_id==flashcard.Card.id, ForeignLemma.id==Translation.foreign_lemma_id).order_by((Translation.count).desc()).limit(3)]
						fdistractors_query = DBSession.query(ForeignLemma).filter(ForeignLemma.language_id ==flashcard.Card.language_id)
						edistractors_query = DBSession.query(EnglishForm).filter(EnglishForm.id !=englishform.id)
						for translation in translations:
							fdistractors_query = fdistractors_query.filter(ForeignLemma.form != translation)
						foreigndistractors = [result.form for result in fdistractors_query.limit(7)]
						englishdistractors = [result.form for result in edistractors_query.limit(7)]
						while len(foreigndistractors) < 7:
							foreigndistractors.append('Distractor')
						fc =  {'position' : position, 'points' : points, 'level' : level,  'cid': id, 'answer':form, 'picture': picture, 'sentence': sentence, 'pos':pos, 'translations':translations, 'targetDistractors': englishdistractors, 'sourceDistractors' : foreigndistractors}
						flashcard_deck.append(fc)
						position +=1
					self.response['flashcard_json'] = json.dumps(flashcard_deck)
					
					return self.response
				else:
					error = 'Missing translation(s)'
					self.response['language'] = language_name
					self.response['vocabulary'] = vocabulary
					self.response['vb_error'] = error
				return self.response
			return self.response
		return self.response











def includeme(config):


	#Use

	config.add_route('my_flashcards', 'my_flashcards') 
	config.add_view(FlashcardView, attr='my_flashcards', route_name='my_flashcards', renderer='my_flashcards.mako', permission=NO_PERMISSION_REQUIRED)

	config.add_route('practice_flashcards', 'practice_flashcards') 
	config.add_view(FlashcardView, attr='practice_flashcards', route_name='practice_flashcards', renderer='practice_flashcards.mako', permission=NO_PERMISSION_REQUIRED)

	config.add_route('introduce_flashcards', 'introduce_flashcards') 
	config.add_view(FlashcardView, attr='introduce_flashcards', route_name='introduce_flashcards', renderer='practice_flashcards.mako', permission=NO_PERMISSION_REQUIRED)

	config.add_route('report_drill_results', 'report_drill_results') 
	config.add_view(FlashcardView, attr='report_drill_results', route_name='report_drill_results', renderer='practice_flashcards.mako', permission=NO_PERMISSION_REQUIRED)
	
	config.add_route('flashcards_demo', 'flashcards_demo') 
	config.add_view(FlashcardView, attr='flashcards_demo', route_name='flashcards_demo', renderer='flashcards_demo.mako', permission=NO_PERMISSION_REQUIRED)

	#Search

	config.add_route('flashcard_tree', 'flashcard-tree/:pid/:parent_name') 
	config.add_view(FlashcardView, attr='flashcard_tree', route_name='flashcard_tree', renderer='flashcard_tree.mako', permission=NO_PERMISSION_REQUIRED)

	config.add_route('search_flashcards', 'search_flashcards') 
	config.add_view(FlashcardView, attr='search_flashcards', route_name='search_flashcards', renderer='search_flashcards.mako', permission=NO_PERMISSION_REQUIRED)

	#Add
	
	config.add_route('add_forms', 'add-forms') 
	config.add_view(FlashcardView, attr='add_forms', route_name='add_forms', renderer='add_forms.mako', permission='add')
	
	config.add_route('add_form', 'add-lemmas/:word_form') 
	config.add_view(FlashcardView, attr='add_form', route_name='add_form', renderer='add_form.mako', permission='add')
	
	



