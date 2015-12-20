## teacher_views.py
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
from beaker.cache import cache_region

@cache_region('twentymins', 'userinfo')
def userinfo(userid):
	if userid:
		auth_id = DBSession.query(AuthID).filter_by(id=userid).first()
		username = auth_id.display_name
		user_group = str(DBSession.query(AuthID).filter_by(id=userid).first().groups[0])
		flashcards = len(auth_id.flashcards)
	else:
		username = ''
		user_group = ''
		flashcards = ''
	user_info = {'username':username, 'group':user_group,'flashcards':flashcards}
	return user_info



"""Useful functions"""
def get_came_from(request):
    return request.GET.get('came_from', request) 

	
def add_image(request, image, userid, situation):
	picture = Picture( name=str(uuid.uuid4())+'_'+str(userid), owner = userid)
	DBSession.add(picture)
	input_file = image.file
	picture_directory = '/home/user/env/English/english/static/uploads/pictures/'
	DBSession.flush()
	if situation == 'lesson':
		pic = Image.open(input_file)
		pic.thumbnail((150,150), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.thumbnail'.format(picture.name))
		pic.save(file_path, 'png')
	if situation == 'test' or situation =='vocab':
		pic = Image.open(input_file)
		pic.thumbnail((150,150), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.thumbnail'.format(picture.name))
		pic.save(file_path, 'png')
	if situation =='profile':
		pic = Image.open(input_file)
		pic.thumbnail((128,128), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.thumbnail'.format(picture.name))
		pic.save(file_path, 'png')
		pic.thumbnail((50,50), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.thumb'.format(picture.name))
		pic.save(file_path, 'png')
	return picture
    
def replace_image(request, image, imageid, situation):
	picture = DBSession.query(Picture).filter_by(id=imageid).first()
	input_file = image.file
	picture_directory = '/home/user/env/English/english/static/uploads/pictures/'
	DBSession.flush()
	if situation == 'lesson':
		pic = Image.open(input_file)
		pic.thumbnail((150,150), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.jpeg'.format(picture.name))
		pic.save(file_path, 'png')
	if situation == 'test' or situation =='vocab':
		pic = Image.open(input_file)
		pic.thumbnail((200,200), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.jpeg'.format(picture.name))
		filename = '{0}.jpg'.format(picture.name)
		pic.save(file_path, 'png')
	if situation =='profile':
		pic = Image.open(input_file)
		pic.thumbnail((128,128), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.thumbnail'.format(picture.name))
		pic.save(file_path, 'png')
		pic.thumbnail((50,50), Image.ANTIALIAS)
		file_path = os.path.join(picture_directory, '{0}.thumb'.format(picture.name))
		pic.save(file_path, 'png')
	return picture
	
"""TEACHER VIEWS"""



##SECURITY PROBLEM: NO VALIDATION OF PICTURE FIELD
def add_test(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	response['title'] = 'Configure test!'
	response['configure'] = True
	from forms import TestForm
	if 'config' in request.params:
		tfn = int(request.params['tfn'])
		mcn = int(request.params['mcn'])
		msn = int(request.params['msn'])
		frn = int(request.params['frn'])
		if tfn > 0: 
			for x in xrange(0, tfn):
				add_tfquestion(x)
		if mcn > 0: 
			for x in xrange(0, mcn):
				add_mcquestion(x)
		if msn > 0: 
			for x in xrange(0, msn):
				add_msquestion(x)
		if frn > 0: 
			for x in xrange(0, frn):
				add_frquestion(x)
		form = TestForm(request.POST)
		response['form'] = form
		response['title'] = 'Add a test!'
		if request.method == 'POST' and form.validate():
			test = form.save(tfn, mcn, msn)
			test.owner = userid
			if frn > 0:
				for a in range(0, frn):
					frp = form.data['frp'+str(a)]
					picture = form.data['frpic'+str(a)]
					pic = add_image(request, picture, userid, situation='test')
					DBSession.add(FreePrompt(prompt = frp, test_id = test.id, picture_id = int(pic.id)))
			DBSession.flush()
			return HTTPFound(location = request.route_url('home'), headers=headers)
		return response
	return response

def edit_test(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	response['title'] = 'Edit test'
	from forms import TestForm
	testid = request.matchdict['test_id']
	test = DBSession.query(Test).filter_by(id = testid).first()
	questions = test.questions
	freeprompts = test.freeprompts
	tjson = json.loads(test.tjson)
	tfn = []
	mcn = []
	msn = []
	frn = []
	for question in questions:
		qjson = json.loads(question.question_json)
		if qjson['type'] == 'tf':
			number=question.id
			add_tfquestion(number, json=qjson, tjson=tjson)
			tfn.append(number)
		if qjson['type'] == 'mc':
			number=question.id
			add_mcquestion(number, json=qjson, tjson=tjson)
			mcn.append(number)
		if qjson['type'] == 'ms':
			number=question.id
			add_msquestion(number, json=qjson, tjson=tjson)
			msn.append(number)
	for freeprompt in freeprompts:
		number=freeprompt.id
		add_frquestion(number, prompt = freeprompt.prompt)
		frn.append(number)
	form = TestForm(request.POST, title = tjson['title'])
	response['form'] = form
	if request.method == 'POST' and form.validate():
			titled = form.data['title']
			test = form.edit(tfn, mcn, msn, test, titled)
			test.owner = userid
			if len(frn) > 0:
				for a in frn:
					freeprompt = DBSession.query(FreePrompt).filter_by(id=a).first()
					frp = form.data['frp'+str(a)]
					picture = form.data['frpic'+str(a)]
					freeprompt.prompt = frp
					freeprompt.test_id = test.id
					imageid = freeprompt.picture_id
					pic_id = replace_image(request, picture, imageid, situation='test')
					freeprompt.picture_id = pic_id.id
			DBSession.flush()
			return HTTPFound(location = request.route_url('home'), headers=headers)
	return response


def review_my_tests(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	response['title'] = 'Review my tests'
	usertests = DBSession.query(Test).filter_by(owner=userid).all()
	tests_to_review = []
	for test in usertests:
		tjson = json.loads(test.tjson)
		tests_to_review.append({'id': test.id, 'title': tjson['title'], 'count': len(DBSession.query(TestLog).filter_by(test_id=test.id).filter_by(status='I').all()) })
	response['tests'] = tests_to_review
	return response

def review_test(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	tnumber = request.matchdict['test_id']
	testlogs = DBSession.query(TestLog).filter_by(test_id=tnumber).filter_by(status = 'I').all()
	test = DBSession.query(Test).filter_by(id=tnumber).first()
	responses_to_review = {}
	prompts_to_review = {}
	for prompt in test.freeprompts:
		picture_name = DBSession.query(Picture).filter_by(id=prompt.picture_id).first().name
		prompts_to_review[prompt.id] = {'prompt' : prompt.prompt, 'picture' : picture_name}
		responses_to_review[prompt.id] = []
	response_names = []
	for test in testlogs:
		responses = test.responses
		for response in responses:
			response_names.append(response.id)
			responses_to_review[response.prompt_id].append({'id': response.id, 'answer' : response.answer})
	evaluations = [evaluation.evaluation for evaluation in DBSession.query(SentenceEvaluation).all()]
	if 'submit' in request.params:
		for response_name in response_names:
			sentence_evaluation = request.params[str(response_name)]
			relevant_section = request.params['section'+str(response_name)]
			freeresponse = DBSession.query(FreeResponse).filter_by(id = response_name).first()
			test_log_id = freeresponse.test_log
			test_log = DBSession.query(TestLog).filter_by(id = test_log_id).first()
			tjson = json.loads(test_log.tlogjson)
			if sentence_evaluation == 'Correct':
				sentence_log = SentenceEvaluationLog(response=response_name, sentence_section = relevant_section, evaluation_id = 1)
				DBSession.add(sentence_log)
				score_add = 1.0
				freeresponse.correct = True
				freeresponse.evaluation = 1
			else:
				eval_id = DBSession.query(SentenceEvaluation).filter_by(evaluation=sentence_evaluation).first().id
				sentence_log = SentenceEvaluationLog(response=response_name, sentence_section = relevant_section, evaluation_id = eval_id)
				DBSession.add(sentence_log)
				score_add = 0.0
				freeresponse.correct = False
				freeresponse.evaluation = eval_id
			answers = tjson['answers']
			denom = tjson['denominator']
			num = tjson['numerator']
			if tjson['q'] == 1:
				score = str(int(100*(num+score_add)/(denom + 1.0)))+'%'
				test_log.tlogjson = json.dumps({'score': score, 'answers': answers})
				test_log.status = u'C'
			else:
				test_log.tlogjson = json.dumps({'q': tjson['q']-1, 'denominator': denom+1.0, 'numerator': num+score_add, 'answers': answers})	
			DBSession.flush()
		return HTTPFound(location = request.route_url('home'), headers=headers)
	response['prompts'] = prompts_to_review
	response['responses'] = responses_to_review
	response['evaluations'] = evaluations
	return response
			
	
def add_unit(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	teaching_resources = []
	lessons = []
	tests = []
	for lesson in DBSession.query(Lesson).filter_by(owner=userid).filter_by(unit_id=None).all():
		ljson = json.loads(lesson.ljson)		
		lessons.append(['lesson', lesson.lurl, ljson['title']]) 
	if len(lessons) >=1: teaching_resources += lessons
	for test in DBSession.query(Test).filter_by(owner=userid).filter_by(unit_id=None).all():
		tjson = json.loads(test.tjson)
		tests.append(['test', test.id, tjson['title']])
	if len(tests) >=1: teaching_resources += tests	
	form = UnitForm(request.POST)
	if request.method == 'POST' and form.validate():
		unit = form.save()
		picture = form.data['picture_id']
		pic_id = add_image(request, picture, userid, situation='lesson')
		unit.picture_id = int(pic_id.id)
		unit.owner = userid
		return HTTPFound(location = request.route_url('home'), headers=headers)
	response['form'] = form
	response['title'] = 'Add a unit'
	response['teaching_resources'] = teaching_resources
	return response

def edit_unit(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	unitid = request.matchdict['unit_id']
	teaching_resources = []
	lessons = []
	tests = []
	for lesson in DBSession.query(Lesson).filter_by(owner=userid).filter_by(unit_id=None).all():
		ljson = json.loads(lesson.ljson)		
		lessons.append(['lesson', lesson.lurl, ljson['title']]) 
	if len(lessons) >=1: teaching_resources += lessons
	for test in DBSession.query(Test).filter_by(owner=userid).filter_by(unit_id=None).all():
		tjson = json.loads(test.tjson)
		tests.append(['test', test.id, tjson['title']])
	if len(tests) >=1: teaching_resources += tests
	unit = DBSession.query(Unit).filter_by(id=unitid).first()
	lessons = unit.lessons
	test = unit.test[0]
	lesson1 = request.application_url+'/lesson/{0}'.format(unit.lessons[0].lurl)
	lesson2 = request.application_url+'/lesson/{0}'.format(unit.lessons[1].lurl)
	test = request.application_url+'/test/{0}'.format(unit.test[0].id)
	lesson3 = lesson4 = lesson5 = ''
	if len(lessons) == 3: lesson3 = request.application_url+'/lesson/{0}'.format(unit.lessons[2].lurl)
	if len(lessons) == 4: lesson4 = request.application_url+'/lesson/{0}'.format(unit.lessons[3].lurl)
	if len(lessons) == 5: lesson5 = request.application_url+'/lesson/{0}'.format(unit.lessons[4].lurl)
	ujson = json.loads(unit.ujson)
	form = UnitForm(request.POST, uurl = unit.uurl, title = ujson['title'], description = ujson['description'], lesson1 = lesson1, lesson2 = lesson2, lesson3 = lesson3, lesson4 = lesson4, lesson5 = lesson5, test = test)
	if request.method == 'POST' and form.validate():
		unit = form.edit(unit)
		picture = form.data['picture_id']
		imageid = unit.picture_id
		pic_id = replace_image(request, picture, imageid, situation='lesson')
		unit.owner = userid
		DBSession.flush()
		return HTTPFound(location = request.route_url('home'), headers=headers)
	response['form'] = form
	response['title'] = 'Edit this unit'
	response['teaching_resources'] = teaching_resources
	return response
	


def add_lesson(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	response['title'] = 'Add a lesson'
	form = False
	configure = True
	if 'config' in request.params:
		v_input = request.params['vocab']
		lemmas = v_input.split(',')
		for lemma in lemmas:
			add_vocab_item(lemma)
		form = AddLessonForm(request.POST)
		configure = False
		if request.method == 'POST' and form.validate():
			lesson = form.save()
			lesson.owner = userid
			picture = form.data['picture_id']
			pic_id = add_image(request, picture, userid, situation='lesson')
			lesson.picture_id = int(pic_id.id)
			for lemma in lemmas:
				lemma_info = form.data[lemma]
				example_sentence = re.sub(lemma, '____', lemma_info['example_sentence'])
				pos = lemma_info['pos']
				pic_id = add_image(request, lemma_info['picture'], userid, situation='vocab')
				new_vocab = EnglishLemma(form = lemma,owner = userid, example_sentence=example_sentence, picture_id=int(pic_id.id), pos=pos, lesson_id=lesson.id)
				DBSession.add(new_vocab)
			return HTTPFound(location = request.route_url('add_quiz', lesson = lesson.id, length = form.data.get('questions')), headers=headers)
	response['form'] = form
	response['configure'] = configure
	return response

def edit_lesson(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	lessonid = request.matchdict['lesson_id']
	lesson = DBSession.query(Lesson).filter_by(id=lessonid).first()
	ljson = json.loads(lesson.ljson)
	title = ljson['title']
	description = ljson['description']
	lurl = lesson.lurl
	tags = lesson.tags
	tag_string = ''
	for indx in xrange(0, len(tags) -1):
		tag_string += tags[indx].name +' , '
	tag_string += tags[-1].name	
	video = ljson['video']
	setattr(AddLessonForm, 'keepquiz', RadioField(label=u'Keep the quiz the same?', choices=[('yes', 'Yes'), ('no', 'No')], id='keepquiz'))
	form = AddLessonForm(request.POST, title = title, description = description, lurl = lurl, tags = tag_string, video = video)
	if request.method == 'POST' and form.validate():
		lesson = form.edit(lesson)
		lesson.owner = userid
		picture = form.data['picture_id']
		imageid = lesson.picture_id
		pic_id = replace_image(request, picture, imageid, situation='lesson')
		DBSession.flush()
		if form.data['keepquiz'] == 'no': return HTTPFound(location = request.route_url('add_quiz', lesson = lesson.id, length = form.data.get('questions')), headers=headers)
		else: return HTTPFound(location = request.route_url('home'), headers=headers)
	response['title'] = 'Edit this lesson'
	response['form'] = form
	return response

def add_quiz(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	length = int(request.matchdict['length'])
	lesson = int(request.matchdict['lesson'])
	for x in range(0, length):
		add_quiz_question(x)
	form = AddQuizForm(request.POST)
	if request.method == 'POST' and form.validate():
		quiz = form.save(length)
		save_quiz(quiz, lesson)
		if quiz:
			return HTTPFound(location = request.route_url('home'), headers=headers)
	response['title'] = 'Add a quiz!'
	response['form'] = form
	return response

def edit_flashcard(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	fcardid = request.matchdict['flashcard_id']
	fcard = DBSession.query(EnglishLemma).filter(EnglishLemma.id==fcardid).first()
	form = VocabItem(request.POST, pos=fcard.pos, example_sentence = fcard.example_sentence)

	response['title'] = 'Edit this flashcard'
	response['form'] = form
	
	return response


def my_content(request):
	userid = authenticated_userid(request)
	user = ''
	headers=''
	response = userinfo(userid)
	if userid: 
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		headers = remember(request, userid)
	response['headers'] = headers
	userlessons = DBSession.query(Lesson).filter_by(owner=userid).all()
	usertests = DBSession.query(Test).filter_by(owner=userid).all()
	userunits = DBSession.query(Unit).filter_by(owner=userid).all()
	userflashcards = DBSession.query(EnglishLemma).filter_by(owner=userid).all()
	tests = []
	lessons = []
	units = []
	flashcards = []
	for lesson in userlessons:
		ljson = json.loads(lesson.ljson)
		lessons.append({'title': ljson['title'], 'description': ljson['description'], 'id': lesson.id})
	for test in usertests:
		tjson = json.loads(test.tjson)
		tests.append({'id': test.id, 'title': tjson['title']})
	for unit in userunits:
		ujson = json.loads(unit.ujson)
		units.append({'id': unit.id, 'title': ujson['title'], 'description': ujson['description']})
	for flashcard in userflashcards:
		flashcards.append({'id' : flashcard.id, 'form' :flashcard.form})
	response['lessons'] = lessons
	response['units'] = units
	response['tests'] = tests
	response['myflashcards'] = flashcards
	return response


def includeme(config):
	#config.add_route('my_content', '/my_content') 
	#config.add_view(my_content, route_name='my_content', renderer='my_content.mako', permission=u'add')
	

	#config.add_route('edit_lesson', '/edit_lesson/:lesson_id') 
	#config.add_view(edit_lesson, route_name='edit_lesson', renderer='picture_form.mako', permission=u'add')
	
	config.add_route('edit_flashcard', '/edit_flashcard/:flashcard_id') 
	config.add_view(edit_flashcard, route_name='edit_flashcard', renderer='picture_form.mako', permission=u'add')
	
	config.add_route('add_unit', '/add_unit') 
	config.add_view(add_unit, route_name='add_unit', renderer='add_resource_form.mako', permission=u'add')

	config.add_route('edit_unit', '/edit_unit/:unit_id') 
	config.add_view(edit_unit, route_name='edit_unit', renderer='add_resource_form.mako', permission=u'add')
	
	config.add_route('add_test', '/add_test') 
	config.add_view(add_test, route_name='add_test', renderer='configure_test.mako', permission=u'add')

	config.add_route('edit_test', '/edit_test/:test_id') 
	config.add_view(edit_test, route_name='edit_test', renderer='edit_test.mako', permission=u'add')

	#config.add_route('add_quiz', ':lesson/add_quiz/:length') 
	#config.add_view(add_quiz, route_name='add_quiz', renderer='form.mako', permission=u'add')
                        
	config.add_route('review_my_tests', '/review_tests') 
	config.add_view(review_my_tests, route_name='review_my_tests', renderer='review_my_tests.mako', permission=u'add')
	
	config.add_route('review_test', '/review_test/:test_id') 
	config.add_view(review_test, route_name='review_test', renderer='review_test.mako', permission=u'add')
