# -*- coding: utf-8 -*-

## cache_functions

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


"""HELPER FUNCTIONS"""
picture_directory = '/home/user/venv/English/english/static/uploads/pictures/'
default_profile_picture = '1.thumb'

def add_image(request, image, userid, situation):
	picture = Picture(name=str(uuid.uuid4())+'_'+str(userid), owner = userid)
	DBSession.add(picture)
	if type(image) == type(u'') and situation == 'profile':
		default_image = os.path.join(picture_directory, default_profile_picture)
		pic = Image.open(default_image)
	elif type(image) == type('') and situation == 'flashcard':
		pic = Image.open(image)
	else:
		input_file = image.file
		pic = Image.open(input_file)
	if situation == 'lesson':
		pic.thumbnail((150,150), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.jpeg'.format(picture.name))
		pic.save(file_path, 'jpeg')
	if situation == 'flashcard':
		pic.thumbnail((300,300), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.jpeg'.format(picture.name))
		pic.save(file_path, 'jpeg')
	if situation =='profile':
		pic.thumbnail((128,128), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.thumb'.format(picture.name))
		pic.save(file_path, 'jpeg')
		pic.thumbnail((50,50), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.thumbnail'.format(picture.name))
		pic.save(file_path, 'jpeg')
	DBSession.flush()
	return picture.id
    
def replace_image(request, image, imageid, situation):
	picture = DBSession.query(Picture).filter_by(id=imageid).first()
	input_file = image.file
	DBSession.flush()
	if situation == 'lesson':
		pic = Image.open(input_file)
		pic.thumbnail((150,150), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.jpeg'.format(picture.name))
		pic.save(file_path, 'jpeg')
	if situation == 'test':
		pic = Image.open(input_file)
		pic.thumbnail((300,300), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.jpeg'.format(picture.name))
		pic.save(file_path, 'jpeg')
		filename = '{0}.jpg'.format(picture.name)
		file_path = os.path.join(picture_directory, filename)
		with open(file_path, 'wb') as output_file:
			shutil.copyfileobj(input_file, output_file)
	if situation =='profile':
		pic = Image.open(input_file)
		pic.thumbnail((128,128), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.thumb'.format(picture.name))
		pic.save(file_path, 'jpeg')
		pic.thumbnail((50,50), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.thumbnail'.format(picture.name))
		pic.save(file_path, 'jpeg')
	return picture.id


def point_table_check(this_week, this_month):
	DBSession.query(MonthlyUserPoint).filter((MonthlyUserPoint.month-this_month) < -2).delete()
	DBSession.query(MonthlyUserPoint).filter((MonthlyUserPoint.month-this_month) > 2).delete()
	DBSession.query(WeeklyUserPoint).filter((WeeklyUserPoint.week-this_week) < -2).delete()
	DBSession.flush()


def process_drill_results(drill_results):
	session = DBSession()
	for flashcard_id in drill_results.keys():
		flashcard = session.query(Flashcard).filter_by(id=flashcard_id).first()
		flashcard.level = drill_results[flashcard_id]['ending_level']
		flashcard.correct += drill_results[flashcard_id]['correct']
		flashcard.incorrect += drill_results[flashcard_id]['incorrect']
		if flashcard.level.find('Flashcard'):
			if drill_results[flashcard_id]['correct'] > drill_results[flashcard_id]['incorrect'] and flashcard.ease < 3500:
				flashcard.ease += flashcard.correct/(flashcard.incorrect+flashcard.correct)*100
			elif drill_results[flashcard_id]['correct'] < drill_results[flashcard_id]['incorrect'] and flashcard.ease > 1500:
				flashcard.ease -= flashcard.incorrect/(flashcard.incorrect+flashcard.correct)*100
			flashcard.interval= int(flashcard.interval*flashcard.ease/1000.0)
			flashcard.due = datetime.date.fromordinal(datetime.date.today().toordinal()+int(flashcard.interval/10))
		session.flush()

def moveUP(flashcard_level):
	if flashcard_level == 'Show':
		return '4Source'
	elif flashcard_level == '4Source':
		return '8Source'
	elif flashcard_level == '8Source':
		return '4Target'
	elif flashcard_level == '4Target':
		return '8Target'
	elif flashcard_level == '8Target':
		return 'Flashcard1'
	elif flashcard_level == 'Flashcard1':
		return 'Flashcard2'
	elif flashcard_level == 'Flashcard2':
		return 'Flashcard3'
	elif flashcard_level == 'Flashcard3':
		return 'Flashcard4'	
	elif flashcard_level == 'Flashcard4':
		return 'Flashcard5'
	elif flashcard_level == 'Flashcard5':
		return 'Flashcard6'
	elif flashcard_level == 'Flashcard6':
		return 'Flashcard7'
	elif flashcard_level == 'Flashcard7':
		return 'Flashcard8'
	elif flashcard_level == 'Flashcard8':
		return 'Flashcard8'


def add_points(userid, points, activity):
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
		totals = 'New totals:<br> Week: {0}Month: {1}	Alltime: {2}'.format(WUP.amount, MUP.amount, TUP.amount)
		if randint(1,10000) == 5000:
			point_table_check(this_week, this_month)
	return totals

def get_came_from(request):
    return request.GET.get('came_from', request) 

def add_vocab_list(request, vocabulary):
	userid = authenticated_userid(request)
	user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
	beaker.cache.region_invalidate(user_info, None, 'user_info', user.id)
	for vocab_item in vocabulary:
		card = DBSession.query(Card).filter(Card.lemma_id==int(vocab_item['id']), Card.language_id==user.preferred_language).first()
		english_lemma = DBSession.query(EnglishLemma).filter(EnglishLemma.id==int(vocab_item['id'])).first()
		if card == None:
			card = Card(lemma_id=int(vocab_item['id']), language_id=user.preferred_language)
			DBSession.add(card)
		existing_f_lemma = DBSession.query(ForeignLemma).filter(ForeignLemma.form==request.params[str(vocab_item['id']).strip()], ForeignLemma.language_id==user.preferred_language).first() 
		if existing_f_lemma == None:
			existing_f_lemma = ForeignLemma(form=request.params[str(vocab_item['id']).strip()], language_id=int(user.preferred_language))
			DBSession.add(existing_f_lemma)
		existing_translation = DBSession.query(Translation).filter(Translation.card_id ==card.id, Translation.foreign_lemma_id==existing_f_lemma.id).first()
		if existing_translation == None:
			existing_translation = Translation(card_id=card.id, foreign_lemma_id=existing_f_lemma.id, count = 0)
			DBSession.add(existing_translation)
		existing_translation.count += 1
		card.translations.append(existing_translation)
		flashcard = Flashcard(card_id=card.id, owner=user.id, due=datetime.datetime.today())
		user.flashcards.append(flashcard)
		DBSession.flush()



"""CACHE FUNCTIONS"""


