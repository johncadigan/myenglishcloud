# -*- coding: utf-8 -*-


from wtforms import *
from wtforms.fields import FormField
import os
import errno
from pyramid.security import authenticated_userid
from pyramid.threadlocal import get_current_registry
from pyramid.threadlocal import get_current_request
from pyramid.i18n import get_localizer

from re import *
from random import shuffle
from uuid import uuid4
from models import *
from datetime import date
from cache_functions import *
from slugify import slugify

from wtforms_alchemy import ModelForm, ModelFormField, model_form_factory,  InputRequired, Optional, ModelFieldList, DataRequired
##### Helper Functs
PICTURE_DIRECTORY = '/home/user/nenv/English/english/static/uploads/pictures/'
PICTURE_SIZES = [(256, 256), (128, 128), (64,64)]
PICTURE_SUBDIRECTORIES = ["original"] + ["{0}x{1}".format(x[0], x[1]) for x in PICTURE_SIZES]
PICTURE_DIRECTORIES = [os.path.join(PICTURE_DIRECTORY, s) for s in PICTURE_SUBDIRECTORIES]

def make_sure_path_exists(path):
	try:
		os.makedirs(path)
	except OSError as exception:
		if exception.errno != errno.EEXIST:
			raise
			
#for x in PICTURE_DIRECTORIES: make_sure_path_exists(x)

def add_image(picture, image):
	if picture.name == None: picture.name = str(uuid.uuid4())
	input_file = image.file
	pic = Image.open(input_file)
	for i, size in enumerate([pic.size]+PICTURE_SIZES):
		pic.thumbnail(size, Image.ANTIALIAS)
		file_path = os.path.join(PICTURE_DIRECTORIES[i], '{0}.jpeg'.format(picture.name))
		pic.save(file_path, 'jpeg')






##### Forms
class Translator(object):
    def __init__(self, localizer):
        self.t = localizer
    def gettext(self, string):
        return self.t.translate(string)
    def ngettext(self, single, plural, string):
        return self.t.pluralize(single, plural, string)

class ExtendedForm(Form):
	""" Base Model used to wrap WTForms for local use
	Global Validator, Renderer Function, determines whether
	it needs to be multipart based on file field present in form.
	
	http://groups.google.com/group/wtforms/msg/d6e5aca36a69ff5d
	"""
	
	def __init__(self, formdata=None, obj=None, prefix='', **kwargs):
		self.request = kwargs.pop('request', get_current_request())
		super(Form, self).__init__(self._unbound_fields, prefix=prefix)
	
		self.is_multipart = False
	
		for name, field in self._fields.iteritems():
			if field.type == 'FileField':
				self.is_multipart = True
	
			setattr(self, name, field)
	
		self.process(formdata, obj, **kwargs)
	
	def hidden_fields(self):
		""" Returns all the hidden fields.
		"""
		return [self._fields[name] for name, field in self._unbound_fields
			if self._fields.has_key(name) and self._fields[name].type == 'HiddenField']
	
	def visible_fields(self):
		""" Returns all the visible fields.
		"""
		return [self._fields[name] for name, field in self._unbound_fields
			if self._fields.has_key(name) and not self._fields[name].type == 'HiddenField']
	
	def _get_translations(self): 
		if self.request:
			localizer = get_localizer(self.request)
			return Translator(localizer)
	
	def clean(self): 
		"""Override me to validate a whole form.""" 
		pass
	
	def validate(self): 
		if not super(ExtendedForm, self).validate(): 
			return False 
		errors = self.clean() 
		if errors: 
			self._errors = {'whole_form': errors} 
			return False 
		return True
		
	def render(self, **kwargs):
		action = kwargs.pop('action', '')
		submit_text = kwargs.pop('submit_text', 'Submit')
		template = kwargs.pop('template', False)
	
		if not template:
			settings = self.request.registry.settings
	
			template = settings.get('apex.form_template', \
				'apex:templates/forms/tableform.mako')
	
		return render(template, {
			'form': self,
			'action': action,
			'submit_text': submit_text,
			'args': kwargs,
		}, request=self.request)

class StyledWidget(object): 
	""" Allows a user to pass style to specific form field
	
	http://groups.google.com/group/wtforms/msg/6c7dd4dc7fee872d
	"""
	def __init__(self, widget=None, **kwargs): 
		self.widget = widget
		self.kw = kwargs
	
	def __call__(self, field, **kwargs):
		if not self.widget:
			self.widget = field.__class__.widget
	
		return self.widget(field, **dict(self.kw, **kwargs)) 

class FileRequired(validators.Required): 
	""" 
	Required validator for file upload fields. 
	
	Bug mention for validating file field:
	http://groups.google.com/group/wtforms/msg/666254426eff1102
	""" 
	def __call__(self, form, field): 
		if not isinstance(field.data, cgi.FieldStorage): 
			if self.message is None: 
				self.message = field.gettext(u'This field is required.') 
			field.errors[:] = [] 
			raise validators.StopValidation(self.message)

#class ModelForm(ExtendedForm):
	#""" Simple form that adds a save method to forms for saving 
		#forms that use WTForms' model_form function.
	#"""
	#def save(self, session, model, commit=True):
		#record = model()
		#record = merge_session_with_post(record, self.data.items())
		#if commit:
			#session.add(record)
			#session.flush()
	
		#return record
        
class MultiCheckboxField(SelectMultipleField):
	"""
	A multiple-select, except displays a list of checkboxes.
	
	Iterating the field will produce subfields, allowing custom rendering of
	the enclosed checkbox fields.
	"""
	widget = widgets.ListWidget(prefix_label=False)
	option_widget = widgets.CheckboxInput()


class Date(Form):
	today = datetime.date.today()
	year_choices = []
	for x in range(0, 80):
		year_choice = today.year - x
		year_choices.append((year_choice, year_choice))
	
	day = SelectField('', choices =[(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9), (10, 10), (11, 11), (12, 12), (13, 13), (14, 14), (15, 15), (16, 16), (17, 17), (18, 18), (19, 19), (20, 20), (21, 21), (22, 22), (23, 23), (24, 24), (25, 25), (26, 26), (27, 27), (28, 28), (29, 29), (30, 30), (31, 31)], coerce=int, default=today.day)
	month    = SelectField('', choices =[(1, 'January'), (2, 'February'), (3, 'March'), (4, 'April'), (5, 'May'), (6, 'June'), (7, 'July'), (8, 'August'), (9, 'September'), (10, 'October'), (11, 'November'), (12, 'December')], coerce=int, default = today.month)
	year       = SelectField('', choices = year_choices, coerce=int, default=today.year)

class SlugField(TextField):
	
	
	def process_formdata(self, valuelist):
		super(SlugField, self).process_formdata(valuelist)
		new_valuelist = []
		new_valuelist = u"".join([unicode(slugify(value)) for value in valuelist])
		self.data = new_valuelist

##SECURITY PROBLEM: NO VALIDATION OF PICTURE FIELD
def add_frquestion(number, prompt = None):
	if prompt == None:
		prompt = ''
	setattr(TestForm, 'frp'+str(number), TextField(label='Free Respone Prompt', id='frp'+str(number), default = prompt))
	setattr(TestForm, 'frpic'+str(number), FileField(u'Picture hint'))


class UploadPicture(Form):

    image = FileField(u'Image File', [validators.regexp(r'^[^/\\]\.jpg$')])
	
    def validate_image(form, field):
        if field.data:
            field.data = re.sub(r'[^a-z0-9_.-]', '_', field.data)



#Forms to add content
class NewPictureForm(ModelForm):
	errors = {}
	
	#[validators.regexp(r'/([^/]+\.(?:jpg|gif|png|jpeg))')]
	image = FileField(u'Image File')
	name = SlugField(u"Name")
	class Meta:
		model = Picture
	
	def get_session(self):
		return DBSession()
	
	def create(self,userid):
		session = self.get_session()
		pic = Picture.from_file(**self.data)
		pic.owner=userid
		session.add(pic)
		session.flush()
		return pic.id



class NewContentForm(ModelForm):
	
	errors = {}
	
	class Meta:
		model = Content
		exclude=['type', 'views']
		
	url = TextField(validators=[DataRequired()])
	picture = ModelFormField(NewPictureForm)
	tags = TextField(validators=[DataRequired()])

	def validate_url(form, field):
		if Content.get_by_url(field.data) is not None:
			raise validators.ValidationError('Sorry that URL already exists.')
	
	def get_session(self):
		return DBSession()
	
	#def populate_obj(self, obj):
		#session = self.get_session()
		#self.url.data = obj.url
	
	@classmethod
	def alt_cons(cls):
		return NewContentForm()
		
		
	
	def create(self,userid, qid, ctype):
		session = self.get_session()
		pid = self.picture.create(userid)
		c = Content(**{ k : v for (k, v) in self.data.iteritems() if k !='picture' and k != 'tags'})
		c.picture_id = pid
		c.type = ctype
		c.owner = userid
		c.quiz_id = qid
		tags = self.tags.data.replace(';',',')
		tags = [tag.lower().strip() for tag in tags.split(',')]
		tags = set(tags)        # no duplicates!
		for tag in tags:
			tagobj = session.query(Tag).filter_by(name=tag).first()
			if tagobj is None:
				tagobj = Tag(name=tag)
				session.add(tagobj)
				session.flush()
			c.tags.append(tagobj)
		session.add(c)
		session.flush()
		return c.id



class NewLessonForm(ModelForm):
	errors = {}
	class Meta:
		model=Lesson
	content = ModelFormField(NewContentForm)
	
	
	#def populate_obj(self, obj):
		#session = self.get_session()
		#self.video.data = "hello"
		#ncf = NewContentForm.alt_cons()
		#ncf.populate_obj(session.query(Content).filter(Content.id==obj.content_id).first())
		#self.content = ModelFormField(ncf)
	
	def get_session(self):
		return DBSession()
	
	def create(self, userid, qid):
		session = self.get_session()
		cid = self.content.create(userid, qid, 'lesson')
		dl = { k : v for (k, v) in self.data.iteritems() if k !='content'}
		l = Lesson(**dl)
		l.content_id = cid
		session.add(l)

class AnswerForm(ModelForm):
	
	errors = {}
	class Meta:
		model=Answer
	validators = [validators.Optional()]
	@classmethod
	def get_session(self):
		return DBSession()


class QuestionForm(ModelForm):
	errors = {}
	class Meta:
		model=Question
	answers = ModelFieldList(FormField(AnswerForm), validators = [validators.Optional()])
	
	@classmethod
	def get_session(self):
		return DBSession()
	


class EditQuizForm(ModelForm):
	errors = {}
	class Meta:
		model=Quiz
	questions = ModelFieldList(FormField(QuestionForm), validators = [validators.Optional()])
	
	@classmethod
	def get_session(self):
		return DBSession()
	
	def update(self):
		session = self.get_session()
		
		session.query(Quiz).filter(Quiz.id==self._obj.id).update(values={k: v for (k,v) in self.data.iteritems() if k!="questions" and k!="answers"})
		for i, q in enumerate(self._obj.questions):
			session.query(Question).filter(Question.id==q.id).update(values= {k: v for (k,v) in self.questions.entries[i].data.iteritems() if k!="answers"})
			for j, a in enumerate(q.answers):
				if len(self.questions.entries[i].data['answers']) < i+1:
					session.query(Question).filter(Question.id==q.id).delete()
				else:
					session.query(Answer).filter(Answer.id==a.id).update(values=self.questions.entries[i].data['answers'][j])
		session.flush()
		quiz = session.query(Quiz).filter(Quiz.id==self._obj.id).first()
		quiz.to_json()
		

class ContentForm(Form):
	type =  HiddenField('', default='lesson')
	title = TextField('Title', [validators.Required(), validators.Length(min=7, max=50)])
	description = TextAreaField('Description')
	slug = TextField('Content URL', [validators.Required(), validators.Length(min=7, max=60)])
	tags = TextField('Add tags separated by commas')
	words = TextField('Add vocab items separated by commas')
	picture_id = FileField(u'Picture; for videos, it can be found with: http://img.youtube.com/vi/URL-GOES-HERE/0.jpg')
	release = FormField(Date)
	
	def validate_url(form, field):
		if Content.get_by_url(field.data) is not None:
			raise validators.ValidationError('Sorry that URL already exists.')
	
	
	
	def create_content(self, ctype):
		sanitizedurl = self.data['slug'].lower()
		sanitizedurl = sanitizedurl.replace(' ', '-')
		release_date = self.data['release']
		release = date(release_date['year'], release_date['month'], release_date['day'])
		content = Content(description = self.data['description'], title = self.data['title'], url = sanitizedurl, released=release, type = ctype)
		# Putting tags in order	
		tags = self.data['tags']
		tags = tags.replace(';',',')
		tags = [tag.lower().strip() for tag in tags.split(',')]
		tags = set(tags)        # no duplicates!
		for tag in tags:
			tagobj = DBSession.query(Tag).filter_by(name=tag).first()
			if tagobj is None:
				tagobj = Tag(name=tag)
				DBSession.add(tagobj)
				DBSession.flush()		
			content.tags.append(tagobj)
		words = self.data['words']
		words = words.replace(';',',')
		words = [word.lower().strip() for words in words.split(',')]
		words = set(words)        # no duplicates!
		for word in words:
			wordobj = DBSession.query(EnglishForm).filter_by(form=word).first()
			if wordobj is None:
				wordobj = EnglishForm(form=word)
				DBSession.add(wordobj)
				DBSession.flush()
		DBSession.add(content)
		DBSession.flush()
		return content
		
	def edit_content(self, content):
		sanitizedurl = self.data['slug'].lower()
		sanitizedurl = sanitizedurl.replace(' ', '-')
		release_date = self.data['release']
		release = date(release_date['year'], release_date['month'], release_date['day'])
		content.description = self.data['description']
		content.title  = self.data['title']
		content.url = sanitizedurl
		content.released = release
		# Putting tags in order	
		tags = self.data['tags']
		tags = tags.replace(';',',')
		tags = [tag.lower().strip() for tag in tags.split(',')]
		tags = set(tags)        # no duplicates!
		content.tags = []
		for tag in tags:
			tagobj = DBSession.query(Tag).filter_by(name=tag).first()
			if tagobj is None:
				tagobj = Tag(name=tag)
				DBSession.add(tagobj)
				DBSession.flush()		
			content.tags.append(tagobj)
		DBSession.flush()
		return content

class AddVocabForm():
	
	def create_vocab_item(self, v):
		v = str(v)
		form = self.request.params['form'+v]
		english_form = DBSession.query(EnglishForm).filter(EnglishForm.form == form).first()
		if english_form == None:
			english_form = EnglishForm(form =form)
			DBSession.add(english_form)
			DBSession.flush()
		example_sentence = re.sub(form, '____', self.request.params['example_sentence'+v])
		pos = self.request.params['pos'+v]
		picture = self.request.params['picture'+v]
		pic_id = add_image(self.request, picture, self.userid, situation='lesson')
		english_lemma = EnglishLemma(form_id = english_form.id, example_sentence=example_sentence, pos=pos, picture_id=pic_id)
		DBSession.add(english_lemma)
		DBSession.flush() 
		return english_lemma
	
	def create_vocab_list(self, content, vocab_length):
		content.vocabulary.append(self.create_vocab_item(''))
		DBSession.flush()
		for v in xrange(1, vocab_length-1):
			content.vocabulary.append(self.create_vocab_item(v))
			DBSession.flush()

class FormForm(ModelForm):
	errors = {}
	
	class Meta:
		model = EnglishForm
	
	@classmethod
	def get_session(self):
		return DBSession()

class LemmaForm(ModelForm):
	errors = {}
	
	class Meta:
		model = EnglishLemma
		
	picture = ModelFormField(NewPictureForm)
	form = ModelFormField(FormForm)
	
	@classmethod
	def get_session(self):
		return DBSession()
	
	
	def update(self):
		session = self.get_session()
		session.query(EnglishLemma).filter(EnglishLemma.id==self._obj.id).update(values={k: v for (k,v) in self.data.iteritems() if k!="form" and k!="picture"})
		session.query(EnglishForm).filter(EnglishForm.id==self._obj.form_id).update(values=self.data['form'])
		
		Picture.update_with_file(self._obj.picture_id, self.data['picture']['name'],self.data['picture']['image'])
		session.flush()

class AddLessonForm(ContentForm):
	""" Add a lesson
	"""	
	video = TextField("Video's Embedded URL", [validators.Required()])
	
	def create(self):
		content = self.create_content('lesson')
		quiz_name = str(uuid.uuid4())
		quiz = Quiz(name=quiz_name)
		DBSession.add(quiz)
		DBSession.flush()
		lesson = Lesson(video = self.data['video'], content_id=content.id, quiz_id = quiz.id)
		DBSession.add(lesson)
		DBSession.flush()	
		return quiz.id, content


class EditLessonForm(AddLessonForm):
	
	keepquiz = RadioField(label=u'Keep the quiz the same?', choices=[('yes', 'Yes'), ('no', 'No')], id='keepquiz')


	def edit(self, content):
		content = self.edit_content(content)
		lesson = DBSession.query(Lesson).filter(Content.id == Lesson.content_id).first()
		lesson.video = self.data['video']
		DBSession.flush()
		return content.quiz_id, content
	

class AddReadingForm(ContentForm):
	""" Add a lesson
	"""	
	text = TextAreaField("Reading's text", [validators.Required()])
	author = TextField("Source author")
	source = TextField("Source", [validators.Required()])
	stitle = TextField("Article Title", [validators.Required()])
	url = TextField("URL", [validators.Required()])
	accessed = FormField(Date)
	author2 = TextField("Source author")
	source2 = TextField("Source ")
	stitle2 = TextField("Article Title")
	url2 = TextField("URL")
	accessed2 = FormField(Date)
	author3 = TextField("Source author")
	source3 = TextField("Source")
	stitle3 = TextField("Article Title")
	url3 = TextField("URL")
	accessed3 = FormField(Date)
	
	
	def create(self):
		content = self.create_content('reading')
		text = self.data['text']
		text = text.split('.')
		teaser = ''
		for sentence in text[0:2]:
			teaser += sentence + '.'
		content.description = teaser
		quiz_name = str(uuid.uuid4())
		quiz = Quiz(name=quiz_name)
		DBSession.add(quiz)
		DBSession.flush()
		reading = Reading(text = self.data['text'], content_id=content.id, quiz_id = quiz.id)
		DBSession.add(reading)
		accessed = self.data['accessed']
		accessed_date = date(accessed['year'], accessed['month'], accessed['day'])
		DBSession.flush()
		source = Source(reading_id=reading.id, author=self.data['author'], title = self.data['stitle'], url = self.data['url'], source=self.data['source'], date = accessed_date)
		DBSession.add(source)
		if self.data['source2']:
			accessed = self.data['accessed2']
			accessed_date = date(accessed['year'], accessed['month'], accessed['day'])
			source = Source(reading_id=reading.id, author=self.data['author2'], source=self.data['source2'], title = self.data['stitle2'], url = self.data['url2'], date = accessed_date)
			DBSession.add(source)
		if self.data['source3']:
			accessed = self.data['accessed3']
			accessed_date = date(accessed['year'], accessed['month'], accessed['day'])
			source = Source(reading_id=reading.id, author=self.data['author3'], source=self.data['source3'], title = self.data['stitle3'], url = self.data['url3'], date = accessed_date)
			DBSession.add(source)
		DBSession.flush()	
		return quiz.id, content
		
class EditReadingForm(AddReadingForm):
	
	keepquiz = RadioField(label=u'Keep the quiz the same?', choices=[('yes', 'Yes'), ('no', 'No')], id='keepquiz')


	def edit(self, content):
		content = self.edit_content(content)
		reading = DBSession.query(Reading).filter(content.id == Reading.content_id).first()
		reading.text = self.data['text']
		text = self.data['text']
		text = text.split('.')
		teaser = ''
		for sentence in text[0:2]:
			teaser += sentence + '.'
		content.description = teaser
		reading.text = self.data['text']
		DBSession.query(Source).filter(Source.reading_id==reading.id).delete()
		source = Source(reading_id=reading.id, author=self.data['author'], source=self.data['source'], url = self.data['url'], title = self.data['stitle'])
		DBSession.add(source)
		if self.data['source2']:
			source = Source(reading_id=reading.id, author=self.data['author2'], source=self.data['source2'], url = self.data['url2'], title = self.data['stitle2'])
			DBSession.add(source)
		if self.data['source3']:
			source = Source(reading_id=reading.id, author=self.data['author3'], source=self.data['source3'], url = self.data['url3'], title = self.data['stitle3'])
			DBSession.add(source)
		DBSession.add(reading)
		DBSession.flush()	
		return reading.quiz_id, content
		


class AddQuizForm(Form):
	title = TextField('Quiz Title', [validators.Required(), validators.Length(min=7, max=40)])
	tagline = TextField('Tagline', [validators.Required()])
	questions = HiddenField('', default=1)
	
		

	def create(self, request_params):
		quiz_length = int(self.data['questions'])
		questions = self.add_question('', request_params)
		for q in xrange(1, quiz_length):
			question = self.add_question(q, request_params)
			questions += question
		title = self.data['title']
		tagline = self.data['tagline']
		quiz = Quiz(title=title, tagline=tagline)
		if type(questions) == type([]): quiz.questions = questions
		else: quiz.questions = [questions]
		DBSession.add(quiz)
		DBSession.flush()
		
	
	def add_question(self, q, request_params):
		q = str(q)
		answers = []
		a1text = request_params['a1text'+q]
		a1value = request_params['a1value'+q]
		a2text = request_params['a2text'+q]
		a2value = request_params['a2value'+q]
		a3text = request_params['a3text'+q]
		a3value = request_params['a3value'+q]
		a4text = request_params['a4text'+q]
		a4value = request_params['a4value'+q]
		answer_literals = [(a1text,a1value), (a2text,a2value),(a3text,a3value),(a4text,a4value)]
		for t, v in answer_literals:
			if v == "false" and len(t) > 0:
				answers.append(Answer(response=t, correct=False))
			elif len(t) > 0:
				answers.append(Answer(response=t, correct=True))
		prompt = request_params['prompt'+q]
		cexplanation = request_params['cmessage'+q]
		icexplanation = request_params['icmessage'+q]
		q = Question(prompt = prompt, correct_message = cexplanation, incorrect_message = icexplanation)
		q.answers = answers
		DBSession.add(q)
		DBSession.flush
		return q
	
	def save_quiz_file(self, quiz, quiz_name):
		file_path = os.path.join(quiz_dir, '{0}.js'.format(quiz_name))
		temp_file_path = os.path.join('/tmp', '{0}.js'.format(quiz_name))
		output_file = open(temp_file_path, 'wb')
		output_file.write(quiz)
		output_file.close()
		os.rename(temp_file_path, file_path)

# Forms to communicate

class CommentQuestionForm(Form):
	post_type = SelectField(u'Type:', [validators.Required()], choices = [('comment', 'Comment'),('question','Question')], default='comment')
	content = TextAreaField('Content:', [validators.Required()])
	parent_comment = HiddenField('', default='None')
	
	
	def create_post(self):
		if self.data['parent_comment'] == 'None':
			if self.data['post_type'] == 'comment': comment_type = u'C'
			else: comment_type=u'Q'
			comment = Comment(text = self.data['content'], comment_type = comment_type)
			DBSession.add(comment)
			DBSession.flush()
			return ('comment', comment)
		else:
			profile_comment_numbers = findall('([0-9]+)', self.data['parent_comment'])
			parent_number = profile_comment_numbers[1]
			reply = CommentReply(text = self.data['content'], parent_id= int(parent_number))
			DBSession.add(reply)
			return ('reply', reply)


	
	


#User forms

class RegisterForm(Form):
	""" Registration Form
	"""
	login = TextField('Username', [validators.Required(), validators.Length(min=4, max=25)])
	password = PasswordField('Password', [validators.Required(), validators.EqualTo('password2', message='Passwords must match')])
	password2 = PasswordField('Repeat Password', [validators.Required()])
	email = TextField('Email Address', [validators.Required(), validators.Email()])
	
	def validate_login(form, field):
		if AuthUser.get_by_login(field.data) is not None:
			raise validators.ValidationError('Sorry that username already exists.')

	def create_user(self, login):
		id = AuthID()
		DBSession.add(id)
		user = AuthUser(
			login=login,
			password=self.data['password'],
			email=self.data['email'],
		)
		id.users.append(user)
		DBSession.add(user)
		settings = get_current_registry().settings
		group = DBSession.query(AuthGroup).filter(AuthGroup.name=='users').one()
		id.groups.append(group)
		DBSession.flush()

		return user

	def save(self):
		new_user = self.create_user(self.data['login'])
		self.after_signup(new_user)
		return new_user
		
	def after_signup(self, user, **kwargs):
		""" Function to be overloaded and called after form submission
		to allow you the ability to save additional form data or perform
		extra actions after the form submission.
		"""
		pass



class AddProfileForm(Form):
	
	language_choices = [(1, u"Abkhaz-аҧсуа"),(2, u"Afar-Afaraf"),(3, u"Afrikaans-Afrikaans"),(4, u"Akan-Akan"),(5, u"Albanian-Shqip"),(6, u"Amharic-አማርኛ"),(7, u"Arabic-العربية"),(8, u"Aragonese-Aragonés"),(9, u"Armenian-Հայերեն"),(10, u"Assamese-অসমীয়া"),(11, u"Avaric-авар мацӀ"),(12, u"Avestan-avesta"),(13, u"Aymara-aymar aru"),(14, u"Azerbaijani-azərbaycan dili"),(15, u"Bambara-bamanankan"),(16, u"Bashkir-башҡорт теле"),(17, u"Basque-euskara"),(18, u"Belarusian-Беларуская"),(19, u"Bengali-বাংলা"),(20, u"Bihari-भोजपुरी"),(21, u"Bislama-Bislama"),(22, u"Bosnian-bosanski jezik"),(23, u"Breton-brezhoneg"),(24, u"Bulgarian-български език"),(25, u"Burmese-Burmese"),(26, u"Catalan-Català"),(27, u"Chamorro-Chamoru"),(28, u"Chechen-нохчийн мотт"),(29, u"Chichewa-chiCheŵa"),(30, u"Chinese-中文"),(31, u"Chuvash-чӑваш чӗлхи"),(32, u"Cornish-Kernewek"),(33, u"Corsican-corsu"),(34, u"Cree-ᓀᐦᐃᔭᐍᐏᐣ"),(35, u"Croatian-hrvatski"),(36, u"Czech-česky"),(37, u"Danish-dansk"),(38, u"Divehi-ދިވެހި"),(39, u"Dutch-Nederlands"),(40, u"Dzongkha-རྫོང་ཁ"),(41, u"English-English"),(42, u"Esperanto-Esperanto"),(43, u"Estonian-eesti"),(44, u"Ewe-Eʋegbe"),(45, u"Faroese-føroyskt"),(46, u"Fijian-vosa Vakaviti"),(47, u"Finnish-suomi"),(48, u"French-français"),(49, u"Fula-Fulfulde | Pulaar"),(50, u"Gaelic-Gàidhlig"),(51, u"Galician-Galego"),(52, u"Georgian-ქართული"),(53, u"German-Deutsch"),(54, u"Greek-Ελληνικά"),(55, u"Guaraní-Avañe'ẽ"),(56, u"Gujarati-ગુજરાતી"),(57, u"Haitian-Kreyòl ayisyen"),(58, u"Hausa-هَوُسَ"),(59, u"Hebrew-עברית"),(60, u"Herero-Otjiherero"),(61, u"Hindi-हिन्दी| हिंदी"),(62, u"Hiri Motu-Hiri Motu"),(63, u"Hungarian-Magyar"),(64, u"Icelandic-Íslenska"),(65, u"Ido-Ido"),(66, u"Igbo-Asụsụ Igbo"),(67, u"Indonesian-Bahasa Indonesia"),(68, u"Interlingua-Interlingua"),(69, u"Interlingue-Interlingue"),(70, u"Inuktitut-ᐃᓄᒃᑎᑐᑦ"),(71, u"Inupiaq-Iñupiaq"),(72, u"Irish-Gaeilge"),(73, u"Italian-Italiano"),(74, u"Japanese-日本語"),(75, u"Javanese-basa Jawa"),(76, u"Kalaallisut-kalaallisut"),(77, u"Kannada-ಕನ್ನಡ"),(78, u"Kanuri-Kanuri"),(79, u"Kashmiri-कश्मीरी"),(80, u"Kazakh-Қазақ тілі"),(81, u"Khmer-ភាសាខ្មែរ"),(82, u"Kikuyu-Gĩkũyũ"),(83, u"Kinyarwanda-Ikinyarwanda"),(84, u"Kirghiz-кыргыз тили"),(85, u"Kirundi-kiRundi"),(86, u"Komi-коми кыв"),(87, u"Kongo-KiKongo"),(88, u"Korean-한국어 (韓國語)"),(89, u"Kurdish-Kurdî"),(90, u"Kwanyama-Kuanyama"),(91, u"Lao-ພາສາລາວ"),(92, u"Latin-latine"),(93, u"Latvian-latviešu valoda"),(94, u"Lezgian-Лезги чlал"),(95, u"Limburgish-Limburgs"),(96, u"Lingala-Lingála"),(97, u"Lithuanian-lietuvių kalba"),(98, u"Luba-Katanga-Luba-Katanga"),(99, u"Luganda-Luganda"),(100, u"Luxembourgish-Lëtzebuergesch"),(101, u"Macedonian-македонски јазик"),(102, u"Malagasy-Malagasy fiteny"),(103, u"Malay-bahasa Melayu"),(104, u"Malayalam-മലയാളം"),(105, u"Maltese-Malti"),(106, u"Manx-Gaelg"),(107, u"Marathi-मराठी"),(108, u"Marshallese-Kajin M̧ajeļ"),(109, u"Mongolian-монгол"),(110, u"Māori-te reo Māori"),(111, u"Nauru-Ekakairũ Naoero"),(112, u"Navajo-Diné bizaad"),(113, u"Ndonga-Owambo"),(114, u"Nepali-नेपाली"),(115, u"North Ndebele-isiNdebele"),(116, u"Norwegian-Norsk"),(117, u"Nuosu-Nuosuhxop"),(118, u"Occitan-Occitan"),(119, u"Ojibwe-ᐊᓂᔑᓈᐯᒧᐎᓐ"),(120, u"Oriya-ଓଡ଼ିଆ"),(121, u"Oromo-Afaan Oromoo"),(122, u"Ossetian-ирон æвзаг"),(123, u"Panjabi-ਪੰਜਾਬੀ| پنجابی‎"),(124, u"Pashto-پښتو"),(125, u"Persian-فارسی"),(126, u"Polish-polski"),(127, u"Portuguese-Português"),(128, u"Pāli-पाऴि"),(129, u"Quechua-Kichwa"),(130, u"Romanian-română"),(131, u"Romansh-rumantsch grischun"),(132, u"Russian-русский язык"),(133, u"Sami (Northern)-Davvisámegiella"),(134, u"Samoan-gagana fa'a Samoa"),(135, u"Sango-yângâ tî sängö"),(136, u"Sanskrit-संस्कृतम्"),(137, u"Sardinian-sardu"),(138, u"Serbian-српски језик"),(139, u"Shona-chiShona"),(140, u"Sindhi-सिन्धी"),(141, u"Sinhala-සිංහල"),(142, u"Slavonic-ѩзыкъ словѣньскъ"),(143, u"Slovak-slovenčina"),(144, u"Slovene-slovenščina"),(145, u"Somali-Soomaaliga"),(146, u"South Ndebele-isiNdebele"),(147, u"Southern Sotho-Sesotho"),(148, u"Spanish-español | castellano"),(149, u"Sundanese-Basa Sunda"),(150, u"Swahili-Kiswahili"),(151, u"Swati-SiSwati"),(152, u"Swedish-svenska"),(153, u"Tagalog-Wikang Tagalog"),(154, u"Tahitian-Reo Tahiti"),(155, u"Tajik-тоҷикӣ"),(156, u"Tamil-தமிழ்"),(157, u"Tatar-татарча"),(158, u"Telugu-తెలుగు"),(159, u"Thai-ไทย"),(160, u"Tibetan-བོད་ཡིག"),(161, u"Tigrinya-ትግርኛ"),(162, u"Tonga-faka Tonga"),(163, u"Tsonga-Xitsonga"),(164, u"Tswana-Setswana"),(165, u"Turkish-Türkçe"),(166, u"Turkmen-Türkmen | Түркмен"),(167, u"Twi-Twi"),(168, u"Uighur-Uyƣurqə"),(169, u"Ukrainian-українська"),(170, u"Urdu-اردو"),(171, u"Uzbek-O'zbek"),(172, u"Venda-Tshivenḓa"),(173, u"Vietnamese-Tiếng Việt"),(174, u"Volapük-Volapük"),(175, u"Walloon-Walon"),(176, u"Welsh-Cymraeg"),(177, u"Western Frisian-Frysk"),(178, u"Wolof-Wollof"),(179, u"Xhosa-isiXhosa"),(180, u"Yiddish-ייִדיש"),(181, u"Yoruba-Yorùbá"),(182, u"Zhuang-Saɯ cueŋƅ"),(183, u"Zulu-isiZulu")]	
	name = TextField('Full name')
	display_name = TextField('Display name', [validators.Required(), validators.Length(min=4, max=25)])
	birthday = FormField(Date)
	country = SelectField(u'Country', choices = [(1L, u'Afghanistan'), (2L, u'Albania'), (3L, u'Algeria'), (4L, u'American Samoa'), (5L, u'Andorra'), (6L, u'Angola'), (7L, u'Anguilla'), (8L, u'Antarctica'), (9L, u'Antigua And Barbuda'), (10L, u'Argentina'), (11L, u'Armenia'), (12L, u'Aruba'), (13L, u'Australia'), (14L, u'Austria'), (15L, u'Azerbaijan'), (16L, u'Bahamas'), (17L, u'Bahrain'), (18L, u'Bangladesh'), (19L, u'Barbados'), (20L, u'Belarus'), (21L, u'Belgium'), (22L, u'Belize'), (23L, u'Benin'), (24L, u'Bermuda'), (25L, u'Bhutan'), (26L, u'Bolivia'), (27L, u'Bosnia And Herzegowina'), (28L, u'Botswana'), (29L, u'Bouvet Island'), (30L, u'Brazil'), (31L, u'Brunei Darussalam'), (32L, u'Bulgaria'), (33L, u'Burkina Faso'), (34L, u'Burundi'), (35L, u'Cambodia'), (36L, u'Cameroon'), (37L, u'Canada'), (38L, u'Cape Verde'), (39L, u'Cayman Islands'), (40L, u'Central African Rep'), (41L, u'Chad'), (42L, u'Chile'), (43L, u'China'), (44L, u'Christmas Island'), (45L, u'Cocos Islands'), (46L, u'Colombia'), (47L, u'Comoros'), (48L, u'Congo'), (49L, u'Cook Islands'), (50L, u'Costa Rica'), (51L, u'Cote D`ivoire'), (52L, u'Croatia'), (53L, u'Cuba'), (54L, u'Cyprus'), (55L, u'Czech Republic'), (56L, u'Denmark'), (57L, u'Djibouti'), (58L, u'Dominica'), (59L, u'Dominican Republic'), (60L, u'East Timor'), (61L, u'Ecuador'), (62L, u'Egypt'), (63L, u'El Salvador'), (64L, u'Equatorial Guinea'), (65L, u'Eritrea'), (66L, u'Estonia'), (67L, u'Ethiopia'), (68L, u'Falkland Islands (Malvinas)'), (69L, u'Faroe Islands'), (70L, u'Fiji'), (71L, u'Finland'), (72L, u'France'), (73L, u'French Guiana'), (74L, u'French Polynesia'), (75L, u'French S. Territories'), (76L, u'Gabon'), (77L, u'Gambia'), (78L, u'Georgia'), (79L, u'Germany'), (80L, u'Ghana'), (81L, u'Gibraltar'), (82L, u'Greece'), (83L, u'Greenland'), (84L, u'Grenada'), (85L, u'Guadeloupe'), (86L, u'Guam'), (87L, u'Guatemala'), (88L, u'Guinea'), (89L, u'Guinea-bissau'), (90L, u'Guyana'), (91L, u'Haiti'), (92L, u'Honduras'), (93L, u'Hong Kong'), (94L, u'Hungary'), (95L, u'Iceland'), (96L, u'India'), (97L, u'Indonesia'), (98L, u'Iran'), (99L, u'Iraq'), (100L, u'Ireland'), (101L, u'Israel'), (102L, u'Italy'), (103L, u'Jamaica'), (104L, u'Japan'), (105L, u'Jordan'), (106L, u'Kazakhstan'), (107L, u'Kenya'), (108L, u'Kiribati'), (109L, u'Korea (North)'), (110L, u'Korea (South)'), (111L, u'Kuwait'), (112L, u'Kyrgyzstan'), (113L, u'Laos'), (114L, u'Latvia'), (115L, u'Lebanon'), (116L, u'Lesotho'), (117L, u'Liberia'), (118L, u'Libya'), (119L, u'Liechtenstein'), (120L, u'Lithuania'), (121L, u'Luxembourg'), (122L, u'Macau'), (123L, u'Macedonia'), (124L, u'Madagascar'), (125L, u'Malawi'), (126L, u'Malaysia'), (127L, u'Maldives'), (128L, u'Mali'), (129L, u'Malta'), (130L, u'Marshall Islands'), (131L, u'Martinique'), (132L, u'Mauritania'), (133L, u'Mauritius'), (134L, u'Mayotte'), (135L, u'Mexico'), (136L, u'Micronesia'), (137L, u'Moldova'), (138L, u'Monaco'), (139L, u'Mongolia'), (140L, u'Montserrat'), (141L, u'Morocco'), (142L, u'Mozambique'), (143L, u'Myanmar'), (144L, u'Namibia'), (145L, u'Nauru'), (146L, u'Nepal'), (147L, u'Netherlands'), (148L, u'Netherlands Antilles'), (149L, u'New Caledonia'), (150L, u'New Zealand'), (151L, u'Nicaragua'), (152L, u'Niger'), (153L, u'Nigeria'), (154L, u'Niue'), (155L, u'Norfolk Island'), (156L, u'Northern Mariana Islands'), (157L, u'Norway'), (158L, u'Oman'), (159L, u'Pakistan'), (160L, u'Palau'), (161L, u'Panama'), (162L, u'Papua New Guinea'), (163L, u'Paraguay'), (164L, u'Peru'), (165L, u'Philippines'), (166L, u'Pitcairn'), (167L, u'Poland'), (168L, u'Portugal'), (169L, u'Puerto Rico'), (170L, u'Qatar'), (171L, u'Reunion'), (172L, u'Romania'), (173L, u'Russian Federation'), (174L, u'Rwanda'), (175L, u'Saint Kitts And Nevis'), (176L, u'Saint Lucia'), (177L, u'Samoa'), (178L, u'San Marino'), (179L, u'Sao Tome'), (180L, u'Saudi Arabia'), (181L, u'Senegal'), (182L, u'Seychelles'), (183L, u'Sierra Leone'), (184L, u'Singapore'), (185L, u'Slovakia'), (186L, u'Slovenia'), (187L, u'Solomon Islands'), (188L, u'Somalia'), (189L, u'South Africa'), (190L, u'Spain'), (191L, u'Sri Lanka'), (192L, u'St Vincent/Grenadines'), (193L, u'St. Helena'), (194L, u'St.Pierre'), (195L, u'Sudan'), (196L, u'Suriname'), (197L, u'Swaziland'), (198L, u'Sweden'), (199L, u'Switzerland'), (200L, u'Syrian Arab Republic'), (201L, u'Taiwan'), (202L, u'Tajikistan'), (203L, u'Tanzania'), (204L, u'Thailand'), (205L, u'Togo'), (206L, u'Tokelau'), (207L, u'Tonga'), (208L, u'Trinidad And Tobago'), (209L, u'Tunisia'), (210L, u'Turkey'), (211L, u'Turkmenistan'), (212L, u'Tuvalu'), (213L, u'Uganda'), (214L, u'Ukraine'), (215L, u'United Arab Emirates'), (216L, u'United Kingdom'), (217L, u'United States'), (218L, u'Uruguay'), (219L, u'Uzbekistan'), (220L, u'Vanuatu'), (221L, u'Vatican City State'), (222L, u'Venezuela'), (223L, u'Viet Nam'), (224L, u'Virgin Islands (British)'), (225L, u'Virgin Islands (U.S.)'), (226L, u'Western Sahara'), (227L, u'Yemen'), (228L, u'Yugoslavia'), (229L, u'Zaire'), (230L, u'Zambia'), (231L, u'Zimbabwe')], coerce=int)
	city = TextField('City')
	preferred_language = SelectField('My first language', [validators.Required()], choices=language_choices, coerce =int)
	languages = MultiCheckboxField('I speak', widget=StyledWidget(class_="list-inline", size=10), choices=language_choices, coerce =int)
	picture_id = FileField(u'Profile Picture')
	about_me = TextAreaField('About me')
	
	def validate_display_name(form, field):
		if AuthID.get_by_display_name(field.data) is not None:
			raise validators.ValidationError('Sorry that username already exists.')

	
	def create_profile(self, userid):
		user = DBSession.query(AuthID).filter(AuthID.id==userid).first()
		user.display_name = self.data['display_name']
		user.preferred_language = self.data['preferred_language']
		profile = Profile()
		profile.name = self.data['name']
		bday = self.data['birthday']
		profile.country_id = self.data['country']
		profile.city = self.data['city']
		profile.about_me = self.data['about_me']
		languages = []
		for language in self.data['languages']:
			languages.append(DBSession.query(Language).filter_by(id=language).first())
		profile.languages = languages
		profile.date_of_birth = date(bday['year'], bday['month'], bday['day'])
		profile.owner = userid
		DBSession.add(profile)
		DBSession.flush()
		return profile


class EditProfileForm(AddProfileForm):
	
	display_name = ''
	
	def edit_profile(self, profile):
		user = DBSession.query(AuthID).filter(AuthID.id==profile.owner).first()
		profile.name = self.data['name']
		bday = self.data['birthday']
		profile.country_id = self.data['country']
		profile.city = self.data['city']
		languages = []
		user.preferred_language = self.data['preferred_language']
		for language in self.data['languages']:
			languages.append(DBSession.query(Language).filter_by(id=language).first())
		profile.languages = languages
		profile.date_of_birth = date(bday['year'], bday['month'], bday['day'])
		return profile
	
	def validate_display_name(form, field):
		if AuthID.get_by_display_name(field.data) is not None:
			raise validators.ValidationError('Sorry that username already exists.')
	
class ChangePasswordForm(ExtendedForm):
	""" Change Password Form
	"""
	user_id = HiddenField('')
	old_password = PasswordField('Old Password', [validators.Required()])
	password = PasswordField('New Password', [validators.Required(),validators.EqualTo('password2', message='Passwords must match')])
	password2 = PasswordField('Repeat New Password', [validators.Required()])
	
	def validate_old_password(form, field):
		request = get_current_request()
		if not AuthUser.check_password(id=authenticated_userid(request),password=field.data):
			raise validators.ValidationError('Your old password doesn\'t match')

class ForgotForm(ExtendedForm):
	login = TextField('Username', [validators.Optional()])
	label = HiddenField(label='Or')
	email = TextField('Email Address', [validators.Optional(), \
										   validators.Email()])
	label = HiddenField(label='')
	label = HiddenField(label='If your username and email weren\'t found, ' \
							  'you may have logged in with a login ' \
							  'provider and didn\'t set your email ' \
							  'address.')
	
	""" I realize the potential issue here, someone could continuously
		hit the page to find valid username/email combinations and leak
		information, however, that is an enhancement that will be added
		at a later point.
	"""
	def validate_login(form, field):
		if AuthUser.get_by_login(field.data) is None:
			raise validators.ValidationError('Sorry that username doesn\'t exist.')
	
	def validate_email(form, field):
		if AuthUser.get_by_email(field.data) is None:
			raise validators.ValidationError('Sorry that email doesn\'t exist.')
	
	def clean(self):
		errors = []
		if not self.data.get('login') and not self.data.get('email'):
			errors.append('You need to specify either a Username or ' \
							'Email address')
		return errors

class LoginForm(Form):
	login = TextField('Username', validators=[validators.Required()])
	password = PasswordField('Password', validators=[validators.Required()])

	def clean(self):
		errors = []
		if not AuthUser.check_password(login=self.data.get('login'), password=self.data.get('password')):
			errors.append('Login Error -- please try again')
		return errors
