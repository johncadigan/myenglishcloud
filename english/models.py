# -*- coding: utf-8 -*-
import hashlib
import random
import string
import transaction
import json
import os
import datetime
import Image
import errno
from datetime import date
import re
from random import shuffle, randint
from cryptacular.bcrypt import BCRYPTPasswordManager

from slugify import slugify
import glob

from pyramid.threadlocal import get_current_request
from pyramid.util import DottedNameResolver
from pyramid.security import (Everyone,
							  Allow,
							  Deny
							  )

from sqlalchemy import (Column,
						ForeignKey,
						event,
						Index,
						Table,
						types,
						Unicode,
						select,
						func,
						case)
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import synonym
from sqlalchemy.sql.expression import func
from sqlalchemy_utils import URLType

#from velruse.store.sqlstore import SQLBase

from zope.sqlalchemy import ZopeTransactionExtension 

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()


##### Helper Functs

QUIZ_DIRECTORY = 'english/static/uploads/quizzes/'
PICTURE_DIRECTORY = 'english/static/uploads/pictures/'
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

"""USER MODELS"""
auth_group_table = Table('auth_auth_groups', Base.metadata,
	Column('auth_id', types.Integer(), \
		ForeignKey('auth_id.id', onupdate='CASCADE', ondelete='CASCADE')),
	Column('group_id', types.Integer(), \
		ForeignKey('auth_groups.id', onupdate='CASCADE', ondelete='CASCADE'))
)
# need to create Unique index on (auth_id,group_id)
Index('auth_group', auth_group_table.c.auth_id, auth_group_table.c.group_id)


class AuthGroup(Base):
	""" Table name: auth_groups
	
	::
	
	id = Column(types.Integer(), primary_key=True)
	name = Column(Unicode(80), unique=True, nullable=False)
	description = Column(Unicode(255), default=u'')
	"""
	__tablename__ = 'auth_groups'
	__table_args__ = {"sqlite_autoincrement": True}
	
	id = Column(types.Integer(), primary_key=True)
	name = Column(Unicode(80), unique=True, nullable=False)
	description = Column(Unicode(255), default=u'')
	
	users = relationship('AuthID', secondary=auth_group_table, \
					 backref='auth_groups')
	
	def __repr__(self):
		return u'%s' % self.name
	
	def __unicode__(self):
		return self.name
    

user_finished_content = Table('user_finished_content', Base.metadata,
	Column('user_id', types.Integer(), \
		ForeignKey('auth_id.id', onupdate='CASCADE', ondelete='CASCADE')),
	Column('content_id', types.Integer(), \
		ForeignKey('contents.id', onupdate='CASCADE', ondelete='CASCADE'))
)
# need to create Unique index on (authid_id,content_id)
Index('user_finished_content', user_finished_content.c.user_id, user_finished_content.c.content_id)

user_added_content_vocab = Table('user_added_content_vocab', Base.metadata,
	Column('user_id', types.Integer(), \
		ForeignKey('auth_id.id', onupdate='CASCADE', ondelete='CASCADE')),
	Column('content_id', types.Integer(), \
		ForeignKey('contents.id', onupdate='CASCADE', ondelete='CASCADE'))
)
# need to create Unique index on (authid_id,content_id)
Index('user_added_content_vocab', user_added_content_vocab.c.user_id, user_added_content_vocab.c.content_id)

user_voted_content_difficulty = Table('user_voted_content_difficulty', Base.metadata,
	Column('user_id', types.Integer(), \
		ForeignKey('auth_id.id', onupdate='CASCADE', ondelete='CASCADE')),
	Column('content_id', types.Integer(), \
		ForeignKey('contents.id', onupdate='CASCADE', ondelete='CASCADE'))
)
# need to create Unique index on (authid_id,content_id)
Index('user_voted_content_difficulty', user_voted_content_difficulty.c.user_id, user_voted_content_difficulty.c.content_id)

user_voted_content_quality = Table('user_voted_content_quality', Base.metadata,
	Column('user_id', types.Integer(), \
		ForeignKey('auth_id.id', onupdate='CASCADE', ondelete='CASCADE')),
	Column('content_id', types.Integer(), \
		ForeignKey('contents.id', onupdate='CASCADE', ondelete='CASCADE'))
)
# need to create Unique index on (authid_id,content_id)
Index('user_voted_content_quality', user_voted_content_quality.c.user_id, user_voted_content_quality.c.content_id)

class AuthID(Base):
	""" Table name: auth_id
	
	::
	
	id = Column(types.Integer(), primary_key=True)
	display_name = Column(Unicode(80), default=u'')
	active = Column(types.Enum(u'Y',u'N',u'D', name=u"active"), default=u'Y')
	created = Column(types.DateTime(), default=func.now())
	
	"""
	
	__tablename__ = 'auth_id'
	__table_args__ = {"sqlite_autoincrement": True}
	
	id = Column(types.Integer(), primary_key=True)
	display_name = Column(Unicode(80), default=u'')
	active = Column(types.Enum(u'Y',u'N',u'D', name=u"active"), default=u'Y')
	created = Column(types.DateTime(), default=func.now())
	groups = relationship('AuthGroup', secondary=auth_group_table, \
					  backref='auth_users')
	users = relationship('AuthUser')
	preferred_language = Column(types.Integer, ForeignKey('languages.id'))
	added_vocab =  relationship('Content', secondary=user_added_content_vocab, \
					 backref='vocab_adders')
	finished_content = relationship('Content', secondary=user_finished_content, \
					 backref='finishers')
	rated_content_difficulty = relationship('Content', secondary=user_voted_content_difficulty, \
					 backref='difficulty_raters')
	rated_content_quality = relationship('Content', secondary=user_voted_content_quality, \
					 backref='quality_raters')
	flashcards = relationship('Flashcard')
	
	"""
	Fix this to use association_proxy
	groups = association_proxy('auth_group_table', 'authgroup')
	"""
	
	last_login = relationship('AuthUserLog', \
						 order_by='AuthUserLog.id.desc()')
	login_log = relationship('AuthUserLog', \
						 order_by='AuthUserLog.id')
	
	def in_group(self, group):
		"""
		Returns True or False if the user is or isn't in the group.
		"""
		return group in [g.name for g in self.groups]
	
	def sorted_flashcards(self):
		flashcards = {'all' : len(self.flashcards)}
		i = 0
		flashcards.setdefault('toAdd', [])
		flashcards.setdefault('toPractice', [])
		flashcards.setdefault('overdue', [])
		flashcards.setdefault('today', [])
		flashcards.setdefault('due', [])
		flashcards.setdefault('tomorrow', [])
		flashcards.setdefault('next_week', [])
		flashcards.setdefault('this_week', [])
		for flashcard in self.flashcards:
			if flashcard.due.toordinal()-datetime.datetime.now().toordinal() < 0:
				flashcards['overdue'].append(flashcard)
				flashcards['due'].append(flashcard)
				if flashcard.level == 'Show':
					flashcards['toAdd'].append(flashcard)
				else:
					flashcards['toPractice'].append(flashcard)
			elif flashcard.due.toordinal()-datetime.datetime.now().toordinal() == 0:        
				flashcards['today'].append(flashcard)
				flashcards['due'].append(flashcard)
				if flashcard.level == 'Show':
					flashcards['toAdd'].append(flashcard)
				else:
					flashcards['toPractice'].append(flashcard)
			elif 0 < flashcard.due.toordinal()-datetime.datetime.now().toordinal() <= 1:
				flashcards['tomorrow'].append(flashcard)
			elif flashcard.due.toordinal()-datetime.datetime.now().toordinal() <= 6:
				flashcards['this_week'].append(flashcard)
			elif 6 < flashcard.due.toordinal()-datetime.datetime.now().toordinal() <= 13:
				flashcards['next_week'].append(flashcard)
		flashcards['due#'] = len(flashcards['due'])
		flashcards['toAdd#'] = len(flashcards['toAdd'])
		flashcards['toPractice#'] = len(flashcards['toPractice'])
		return flashcards
	
	
	@classmethod
	def get_by_id(cls, id):
		""" 
		Returns AuthID object or None by id
	
		.. code-block:: python
	
		   from apex.models import AuthID
	
		   user = AuthID.get_by_id(1)
		"""
		return DBSession.query(cls).filter(cls.id==id).first()    
	@classmethod
	def get_by_display_name(cls, display_name):
		""" 
		Returns AuthUser object or None by login
	
		.. code-block:: python
	
		   from apex.models import AuthUser
	
		   user = AuthUser.get_by_login('login')
		"""
		return DBSession.query(cls).filter(cls.display_name==display_name).first()
	def get_profile(self, request=None):
		"""
		Returns AuthUser.profile object, creates record if it doesn't exist.
	
		.. code-block:: python
	
		   from apex.models import AuthUser
	
		   user = AuthUser.get_by_id(1)
		   profile = user.get_profile(request)
	
		in **development.ini**
	
		.. code-block:: python
	
		   apex.auth_profile = 
		"""
		if not request:
			request = get_current_request()
	
		auth_profile = request.registry.settings.get('apex.auth_profile')
		if auth_profile:
			resolver = DottedNameResolver(auth_profile.split('.')[0])
			profile_cls = resolver.resolve(auth_profile)
			return get_or_create(DBSession, profile_cls, auth_id=self.id)
	
	@property
	def group_list(self):
		group_list = []
		if self.groups:
			for group in self.groups:
				group_list.append(group.name)
		return ','.join( map( str, group_list ) )

class AuthUser(Base):
	""" Table name: auth_users
	
	::
	
	id = Column(types.Integer(), primary_key=True)
	login = Column(Unicode(80), default=u'', index=True)
	_password = Column('password', Unicode(80), default=u'')
	email = Column(Unicode(80), default=u'', index=True)
	active = Column(types.Enum(u'Y',u'N',u'D'), default=u'Y')
	"""
	__tablename__ = 'auth_users'
	__table_args__ = {"sqlite_autoincrement": True}
	
	id = Column(types.Integer(), primary_key=True)
	auth_id = Column(types.Integer, ForeignKey(AuthID.id), index=True)
	provider = Column(Unicode(80), default=u'local', index=True)
	login = Column(Unicode(80), default=u'', index=True)
	salt = Column(Unicode(24))
	_password = Column('password', Unicode(80), default=u'')
	email = Column(Unicode(80), default=u'', index=True)
	created = Column(types.DateTime(), default=func.now())
	active = Column(types.Enum(u'Y',u'N',u'D', name=u"active"), default=u'Y')
	
	def _set_password(self, password):
		self.salt = self.get_salt(24)
		password = password + self.salt
		self._password = BCRYPTPasswordManager().encode(password, rounds=12)
	
	def _get_password(self):
		return self._password
	
	password = synonym('_password', descriptor=property(_get_password, \
					   _set_password))
	
	def get_salt(self, length):
		m = hashlib.sha256()
		word = ''
	
		for i in xrange(length):
			word += random.choice(string.ascii_letters)
	
		m.update(word)
	
		return unicode(m.hexdigest()[:length])
	
	@classmethod
	def get_by_id(cls, id):
		""" 
		Returns AuthUser object or None by id
	
		.. code-block:: python
	
		   from apex.models import AuthID
	
		   user = AuthID.get_by_id(1)
		"""
		return DBSession.query(cls).filter(cls.id==id).first()    
	
	@classmethod
	def get_by_login(cls, login):
		""" 
		Returns AuthUser object or None by login
	
		.. code-block:: python
	
		   from apex.models import AuthUser
	
		   user = AuthUser.get_by_login('login')
		"""
		return DBSession.query(cls).filter(cls.login==login).first()
	
	@classmethod
	def get_by_email(cls, email):
		""" 
		Returns AuthUser object or None by email
	
		.. code-block:: python
	
		   from apex.models import AuthUser
	
		   user = AuthUser.get_by_email('email@address.com')
		"""
		return DBSession.query(cls).filter(cls.email==email).first()
	
	@classmethod
	def check_password(cls, **kwargs):
		if kwargs.has_key('id'):
			user = cls.get_by_id(kwargs['id'])
		if kwargs.has_key('login'):
			user = cls.get_by_login(kwargs['login'])
		
		if not user:
			return False
		try:
			if BCRYPTPasswordManager().check(user.password,
				'%s%s' % (kwargs['password'], user.salt)):
				return True
		except TypeError:
			pass
	
		request = get_current_request()
	#        fallback_auth = request.registry.settings.get('apex.fallback_auth')
	#        if fallback_auth:
	#            resolver = DottedNameResolver(fallback_auth.split('.', 1)[0])
			#fallback = resolver.resolve(fallback_auth)
			#return fallback().check(DBSession, request, user, \
					   #kwargs['password'])
	
		return False

class AuthUserLog(Base):
	"""
	event: 
	  L - Login
	  R - Register
	  P - Password
	  F - Forgot
	"""
	__tablename__ = 'auth_user_log'
	__table_args__ = {"sqlite_autoincrement": True}
	
	id = Column(types.Integer, primary_key=True)
	auth_id = Column(types.Integer, ForeignKey(AuthID.id), index=True)
	user_id = Column(types.Integer, ForeignKey(AuthUser.id), index=True)
	time = Column(types.DateTime(), default=func.now())
	ip_addr = Column(Unicode(39), nullable=False)
	event = Column(types.Enum(u'L',u'R',u'P',u'F', name=u"event"), default=u'L')


class Country(Base):
	__tablename__= 'countries'
	__table_args__ = {"sqlite_autoincrement": True}
	
	id = Column(types.Integer, primary_key=True)	
	name = Column(Unicode(50), nullable=False)
	image = Column(Unicode(50), nullable=False)

language_profile_pairs = Table('language_profile_pairs', Base.metadata,
	Column('language_id', types.Integer(), \
		ForeignKey('languages.id', onupdate='CASCADE', ondelete='CASCADE')),
	Column('profile_id', types.Integer(), \
		ForeignKey('profiles.id', onupdate='CASCADE', ondelete='CASCADE'))
)

Index('language_profile', language_profile_pairs.c.language_id, language_profile_pairs.c.profile_id)


class Profile(Base):
	__tablename__= 'profiles'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	owner = Column(types.Integer, ForeignKey(AuthID.id), index=True)
	picture_id = Column(types.Integer, ForeignKey('pictures.id'))
	name = Column(Unicode(50))
	date_of_birth = Column(types.Date())
	country_id = Column(types.Integer, ForeignKey('countries.id'))
	city = Column(Unicode(50))
	about_me = Column(Unicode(1000))
	languages = relationship('Language', secondary=language_profile_pairs, \
					 backref='languages')

class Language(Base):
	__tablename__= 'languages'
	__table_args__ = {"sqlite_autoincrement": True}
	
	id = Column(types.Integer, primary_key=True)
	english_name = Column(Unicode(50), nullable=False)
	native_name = Column(Unicode(50), nullable=False)
	iso_lang = Column(Unicode(10))
	goog_translate = Column(Unicode(10))
	profiles = relationship('Profile', secondary=language_profile_pairs, \
					 backref='profiles')

class Card(Base):
	__tablename__='cards'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	lemma_id = Column(ForeignKey('english_lemmas.id', onupdate='CASCADE', ondelete='CASCADE'))
	language_id = Column(ForeignKey('languages.id', onupdate='CASCADE', ondelete='CASCADE'))
	translations = relationship('Translation')    

class Translation(Base):
	__tablename__='translations' 
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	card_id = Column(ForeignKey('cards.id', onupdate='CASCADE', ondelete='CASCADE'))
	foreign_lemma_id = Column(ForeignKey('foreign_lemmas.id', onupdate='CASCADE', ondelete='CASCADE'))
	count = Column(types.Integer, default=1, index=True)


lemma_content_pairs = Table('lemma_content_pairs', Base.metadata,
	Column('english_lemma_id', types.Integer(), \
		ForeignKey('english_lemmas.id', onupdate='CASCADE', ondelete='CASCADE')),
	Column('content_id', types.Integer(), \
		ForeignKey('contents.id', onupdate='CASCADE', ondelete='CASCADE'))
)
# need to create Unique index on (auth_id,group_id)
Index('english_lemma_content', lemma_content_pairs.c.english_lemma_id, lemma_content_pairs.c.content_id)

    
class EnglishLemma(Base):
	""" N=Noun, PR=Pronoun, ADJ=Adjective, ADV=Adverb, VB=Verb, PVB=Phrasal Verb, PP=Preposition, CNJ=Conjunction, 
	"""
	__tablename__= 'english_lemmas'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	owner = Column(ForeignKey('auth_id.id'))
	form_id = Column(ForeignKey('english_forms.id'))
	form = relationship('EnglishForm')
	example_sentence = Column(Unicode(100), nullable=False)
	pos = Column(types.Enum(u'Noun',u'Pronoun',u'Adjective', u'Adverb', u'Verb', u'Phrasal Verb', u'Preposition', u'Conjunction', u'Collocation', u'Slang'), nullable=False)
	picture_id = Column(types.Integer, ForeignKey('pictures.id'))
	picture = relationship("Picture")
	content_ids = relationship('Content', secondary=lemma_content_pairs, \
                                         backref='content_ids')

class EnglishLemmaCategory(Base):
	__tablename__= 'english_lemma_categories'
	__mapper_args__ = {'batch': False  # allows extension to fire for each
					# instance before going to the next.
					}
	parent = None
	id = Column(types.Integer(), primary_key=True)
	name = Column(types.Unicode(100))
	lemma_id = Column(ForeignKey('english_lemmas.id'))
	level = Column("lvl", types.Integer, nullable=False)
	left = Column("lft", types.Integer, nullable=False)
	right = Column("rgt", types.Integer, nullable=False) 

@event.listens_for(EnglishLemmaCategory, "before_insert")
def before_insert(mapper, connection, instance):
	
	print 'making adjustments before insertion'
	#If the new term has no parent, connect to root
	if instance.parent == None:
		category = mapper.mapped_table
		values = connection.execute(select([category]).where(category.c.name == 'ALL')).first().values()
		parent = EnglishLemmaCategory()
		parent.name = values[0]
		parent.level = values[2]
		parent.left = values[3]
		parent.right = values[4]
		instance.parent = parent
	category = mapper.mapped_table
	
	#Find right most sibling's right value
	right_most_sibling = connection.scalar(
		select([category.c.rgt]).
			where(category.c.name == instance.parent.name)
	)
	
	#Update all values greater than rightmost sibiling
	connection.execute(
		category.update(
			category.c.rgt >= right_most_sibling).values(
				
				#Update if left bound in greater than rightmost sibling
				lft=case(
					[(category.c.lft > right_most_sibling,
						category.c.lft + 2)],
					else_=category.c.lft
				),
				#Update if right bound is greater than right most sibling
				rgt=case(
					[(category.c.rgt >= right_most_sibling,
							category.c.rgt + 2)],
						else_=category.c.rgt
				  )
		)
	)
	instance.left = right_most_sibling
	instance.right = right_most_sibling + 1
	instance.level  = instance.parent.level + 1



@event.listens_for(EnglishLemmaCategory, "after_delete")
def after_delete(mapper, connection, target):
	
	
	category = mapper.mapped_table
	#Delete leaf
	if target.right-target.left == 1:
		print 'updating after deletion of leaf'
		#Update all values greater than right side
		connection.execute(
			category.update(
				category.c.rgt > target.left).values(
					
					#Update if left bound in greater than right side
					lft=case(
						[(category.c.lft > target.left,
							category.c.lft - 2)],
						else_=category.c.lft
					),
					#Update if right bound is greater than right
					rgt=case(
						[(category.c.rgt >= target.left,
								category.c.rgt - 2)],
							else_=category.c.rgt
					  )
			)
		)
	#Delete parent
	else:
		print 'updating after deletion of parent'
		category = mapper.mapped_table
		
		#Promote all children
		connection.execute(
			category.update(
				category.c.lft.between(target.left, target.right)).values(
					
					#Update if left bound in greater than right side
					lft=case(
						[(category.c.lft > target.left,
							category.c.lft - 1)],
						else_=category.c.lft
					),
					#Update if right bound is greater than right
					rgt=case(
						[(category.c.rgt > target.left,
								category.c.rgt - 1)],
							else_=category.c.rgt
					 ),
					lvl=case([(category.c.lvl > target.level,
								category.c.lvl - 1)],
							else_=category.c.lvl
					)
			)
		)
		
		#Update all values greater than right side
		connection.execute(
			category.update(
				category.c.rgt > target.right).values(
					
					#Update if left bound in greater than right side
					lft=case(
						[(category.c.lft > target.left,
							category.c.lft - 2)],
						else_=category.c.lft
					),
					#Update if right bound is greater than right
					rgt=case(
						[(category.c.rgt >= target.left,
								category.c.rgt - 2)],
							else_=category.c.rgt
					  )
			)
		)

class EnglishForm(Base):
	""" 
	"""
	__tablename__= 'english_forms'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	form = Column(Unicode(50), nullable=False)

class FormInfo(Base):
	"""
	"""
	__tablename__= 'form_infos'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	form_id = Column(types.Integer, ForeignKey('english_forms.id'))
	definitions = Column(Unicode(1000))
	freq = Column(types.Integer)

class ForeignLemma(Base):
	""" N=Noun, PR=Pronoun, ADJ=Adjective, ADV=Adverb, VB=Verb, PVB=Phrasal Verb, PP=Preposition, CNJ=Conjunction, 
	"""
	__tablename__= 'foreign_lemmas'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	language_id = Column(types.Integer, ForeignKey('languages.id'))
	form = Column(Unicode(50), nullable=False)

class Flashcard(Base):
	__tablename__= 'flashcards'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	card_id = Column(ForeignKey('cards.id', onupdate='CASCADE', ondelete='CASCADE'))
	owner = Column(ForeignKey('auth_id.id'))
	level = Column(types.Enum('Show', '4Source','8Source', '4Target', '8Target', 'Flashcard1','Flashcard2','Flashcard3','Flashcard4','Flashcard5','Flashcard6','Flashcard7','Flashcard8'), default='Show')
	due  = Column(types.Date(), default=func.now())
	interval = Column(types.Integer(), default=10)
	ease = Column(types.Integer(), default=2500)
	correct = Column(types.Integer(), default=0)
	incorrect = Column(types.Integer(), default=0) 
    
class FlashcardHistory(Base):
	__tablename__= 'flashcardhistories'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	flashcard_id = Column(ForeignKey('flashcards.id'), index=True)
	time = Column(types.DateTime(), default=func.now())
	level = Column(types.Enum('Show', '4Source','8Source', '4Target', '8Target', 'Flashcard1','Flashcard2','Flashcard3','Flashcard4','Flashcard5','Flashcard6','Flashcard7','Flashcard8'))
	response_time= Column(types.Integer())
	response = Column(Unicode(50))
	correct = Column(types.Boolean())
    
"""CONTENT MODELS"""

tag_content_pairs = Table('tag_content_pairs', Base.metadata,
	Column('tag_id', types.Integer(), \
		ForeignKey('tags.id', onupdate='CASCADE', ondelete='CASCADE')),
	Column('content_id', types.Integer(), \
		ForeignKey('contents.id', onupdate='CASCADE', ondelete='CASCADE'))
)
# need to create Unique index on (auth_id,group_id)
Index('tag_content', tag_content_pairs.c.tag_id, tag_content_pairs.c.content_id)

    
class Tag(Base):
	__tablename__ = 'tags'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	name = Column(Unicode(100), unique=True, nullable=False)
	contents = relationship('Content', secondary=tag_content_pairs, \
					 backref='contents')

class Content(Base):
	__tablename__= 'contents'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	type = Column(types.Enum(u'lesson', u'reading'))
	released = Column(types.Date(), default=func.now())    
	title = Column(Unicode(80))
	description = Column(Unicode(350))
	picture_id = Column(types.Integer(), ForeignKey('pictures.id'))
	picture = relationship("Picture")
	url = Column(URLType)
	views = Column(types.Integer(), default=0)
	owner = Column(types.Integer, ForeignKey('auth_users.id'), index = True)
	quiz_id = Column(types.Integer, ForeignKey("quizzes.id"), index = True)
	quiz = relationship('Quiz', uselist=False)
	finished_by = relationship('AuthID', secondary=user_finished_content)
	
	difficulty_rated_by = relationship('AuthID', secondary=user_voted_content_difficulty)
	quality_rated_by = relationship('AuthID', secondary=user_voted_content_quality)
	vocab_added_by = relationship('AuthID', secondary=user_added_content_vocab)
	tags = relationship('Tag', secondary=tag_content_pairs, \
					 backref='tags')
	comments = relationship('Comment')
	difficulty_votes = relationship('DifficultyVote')
	quality_votes = relationship('QualityVote')
	vocabulary = relationship('EnglishLemma', secondary=lemma_content_pairs, \
                                         backref='vocabulary')
	
	
	@classmethod
	def get_by_title(cls, title):
		""" Returns Content object or None by title content = Content.get_by_title('title')"""
		return DBSession.query(cls).filter(cls.title==title).first()
	
	@classmethod
	def get_by_url(cls, url):
		""" Returns Content object or None by title content = Content.get_by_url('url')"""
		return DBSession.query(cls).filter(cls.url==url).first()


class DifficultyVote(Base):
	__tablename__ = 'difficulty_votes'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	score = Column(types.Integer())
	owner = Column(types.Integer, ForeignKey(AuthID.id), index = True)
	content_id = Column(types.Integer, ForeignKey('contents.id'), default = None)

class QualityVote(Base):
	__tablename__ = 'quality_votes'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	score = Column(types.Integer())
	owner = Column(types.Integer, ForeignKey(AuthID.id), index = True)
	content_id = Column(types.Integer, ForeignKey('contents.id'), default = None)

class Comment(Base):
	__tablename__ = 'comments'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	comment_type = Column(types.Enum(u'C',u'Q'), default=u'C')
	time = Column(types.DateTime(), default=func.now())
	owner = Column(types.Integer, ForeignKey(AuthID.id), index = True)
	content_id = Column(types.Integer, ForeignKey('contents.id'), default = None)
	text = Column(Unicode(1000), nullable = False)
	replies = relationship('CommentReply')

class CommentReply(Base):
	__tablename__ = 'comment_replies'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	time = Column(types.DateTime(), default=func.now())
	owner = Column(types.Integer, ForeignKey(AuthID.id), index = True)
	parent_id = Column(types.Integer, ForeignKey('comments.id'), default = None)
	text = Column(Unicode(1000), nullable = False)


class Lesson(Base):
	""" Table name: lessons
	video = Column(types.VARCHAR(200))
	quiz_id = Column(types.Integer, ForeignKey('quizzes.id'), nullable= False)
	"""
	__tablename__ = 'lessons'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	content_id = Column(types.Integer(), ForeignKey('contents.id'))
	content = relationship("Content")
	video = Column(types.VARCHAR(200))
	
	

class Reading(Base):
	""" Table name: readings
	text = Column(types.UnicodeText())
	quiz_id = Column(types.Integer, ForeignKey('quizzes.id'), nullable= False)
	"""
	__tablename__ = 'readings'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	content_id = Column(types.Integer(), ForeignKey('contents.id'))    
	text = Column(types.UnicodeText())
	sources = relationship('Source')

class Source(Base):
	__tablename__ = 'sources'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	reading_id = Column(types.Integer(), ForeignKey('readings.id'))
	author = Column(types.Unicode(60))
	title = Column(types.Unicode(100))
	url = Column(types.Unicode(200))
	source = Column(types.Unicode(60))
	date = Column(types.Date, default =func.now)

class Quiz(Base):
	__tablename__ = 'quizzes'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	title = Column(Unicode(100), nullable=False, default=u"This quiz is coming soon!")
	tagline = Column(Unicode(100), nullable=False, default=u'Test your Knowledge!')
	content = relationship('Content')
	questions = relationship('Question')
	
	def to_json(self):
		if len(self.questions) > 0:
			questions = self.questions[0].to_json()
			for question in self.questions[1:]:
				questions += "," + question.to_json
			quiz = """var quizJSON = {{"info": {{"name": "{title}","main": "<p>{tagline}</p>", "results": "<h5>Learn More!</h5><p>We have many more lessons for you.</p>", "level1": "You know this lesson very well!", "level2":  "You know this lesson well.", "level3":  "You might want to watch this lesson again.", "level4":  "You should watch this lesson again.","level5":"You should definitely watch this lesson again" }}, "questions": [{questions}]}};""".format(**{'title' : self.title, 'tagline' : self.tagline, 'questions' : questions})  
			file_path = os.path.join(QUIZ_DIRECTORY, '{0}.js'.format(self.id))
			temp_file_path = os.path.join('/tmp', '{0}.js'.format(self.id))
			output_file = open(temp_file_path, 'wb')
			output_file.write(quiz)
			output_file.close()
			os.rename(temp_file_path, file_path)
	
	def json_id(self):
		questions = DBSession.query(Question).filter(self.id==Question.quiz_id).all()
		if len(questions) > 0:
			return self.id
		else:
			return 0
		
		
@event.listens_for(Quiz, "after_insert")
def after_insert(mapper, connection, target):
	target.to_json()

@event.listens_for(Quiz, "after_update")
def after_update(mapper, connection, target):
	print "\n\n\nUPDATING QUIZ\n\n\n", str(target)
	target.to_json()
	
class Question(Base):
	__tablename__ = 'questions'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	quiz_id = Column(types.Integer, ForeignKey('quizzes.id'))
	prompt = Column(Unicode(100), unique=True, nullable=False)
	answers = relationship('Answer')
	correct_message = Column(Unicode(100), nullable=False, default=u'That was correct!')
	incorrect_message = Column(Unicode(100), nullable=False, default=u'That was incorrect...')
	
	def to_json(self):
		correct = randint(0, 9)
		incorrect = randint(0, 3)
		icheadline = ['Incorrect!', 'Too bad..', 'You were wrong...', 'Sorry...'][incorrect]
		cheadline = ['Correct!', 'Good job!', 'Right on!', 'Way to go!', 'Keep it up!', 'Awesome!', 'Wonderful!', "You're right!", 'Yup', 'Good answer'][correct]
		dic = {"prompt" : self.prompt, 
				"cexplanation" : self.correct_message,
				"cheadline" : cheadline, 
				"icexplanation" : self.incorrect_message,
				"icheadline":icheadline,
				}
		for i, answer in enumerate(self.answers):
			dic["a{0}t".format(i+1)] = answer.response
			if answer.correct:
				dic["a{0}v".format(i+1)]='true'
			else:
				dic["a{0}v".format(i+1)]='false'
		if len(self.answers) == 4:
			question = """{{"q": "{prompt}", "a": [{{"option": "{a1t}", "correct": {a1v}}}, {{"option": "{a2t}", "correct": {a2v}}}, {{"option": "{a3t}", "correct": {a3v}}}, {{"option": "{a4t}", "correct": {a4v}}}], "correct": "<p><span>{cheadline}</span>{cexplanation}</p>", "incorrect": "<p><span>{icheadline}</span>{icexplanation}</p>"}}""".format(**dic)
		elif len(self.answers) == 2:
			question = """{{"q": "{prompt}", "a": [{{"option": "{a1t}", "correct": {a1v}}}, {{"option": "{a2t}", "correct": {a2v}}}], "correct": "<p><span>{cheadline}</span>{cexplanation}</p>", "incorrect": "<p><span>{icheadline}</span>{icexplanation}</p>"}}""".format(**dic)
		return question
	
@event.listens_for(Question, "after_update")
def after_update(mapper, connection, target):
	print "\n\n\nUPDATING QUIZ\n\n\n", str(target.quiz_id)
	quiz = connection.query(Quiz).filter(Quiz.id==target.quiz_id).first()
	quiz.to_json()
	
class Answer(Base):
	__tablename__ = 'answers'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer, primary_key=True)
	question_id = Column(types.Integer, ForeignKey('questions.id'), default = None)
	response = Column(Unicode(100), unique=True, nullable=False)
	correct = Column(types.Boolean)

class Picture(Base):
	"""Table which stores pictures"""
	__tablename__ = 'pictures'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	name = Column(URLType)
	owner = Column(types.Integer, ForeignKey(AuthID.id), index = True)
	
	@classmethod
	def add_file(cls, input_file, name):
		pic = Image.open(input_file)
		for i, size in enumerate([pic.size]+PICTURE_SIZES):
			pic.thumbnail(size, Image.ANTIALIAS)
			file_path = os.path.join(PICTURE_DIRECTORIES[i], '{0}.jpeg'.format(name))
			pic.save(file_path, 'jpeg')
	
	@classmethod
	def from_file(cls, name, image):
		if name == None: name = str(uuid.uuid4())
		same_name =len(glob.glob(os.path.join(PICTURE_DIRECTORIES[0], '{0}[0-9]*.jpeg'.format(name))))
		name+=str(same_name)
		input_file = image.file
		cls.add_file(input_file, name)
		return Picture(name=name)
	
	
	@classmethod
	def update_with_file(cls, pid, name, image):
		if name == None: name = str(uuid.uuid4())
		same_name =len(glob.glob(os.path.join(PICTURE_DIRECTORIES[0], '{0}[0-9]*.jpeg'.format(name))))
		name+=str(same_name)
		session = DBSession()
		session.query(cls).filter(cls.id==pid).update(values={'name' : name.strip()})
		input_file = image.file
		cls.add_file(input_file, name)
		session.flush()



class PotentialPicture(Base):
	"""Table which stores pictures"""
	__tablename__ = 'potential_pictures'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	name = Column(types.VARCHAR(75))
    
""" Usage Data"""

class UserPoint(Base):
	__tablename__ = 'user_points'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	source = Column(types.Unicode(255), default=u'')
	user_id = Column(types.Integer, ForeignKey(AuthID.id))    
	amount = Column(types.Integer(), default = 0)
	time = Column(types.DateTime(), default=func.now())

class TotalUserPoint(Base):
	__tablename__ = 'total_user_points'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	user_id = Column(types.Integer, ForeignKey(AuthID.id))    
	amount = Column(types.Integer(), default = 0)
    
class MonthlyUserPoint(Base):
	__tablename__ = 'monthly_user_points'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	user_id = Column(types.Integer, ForeignKey(AuthID.id))    
	amount = Column(types.Integer(), default = 0)    
	month = Column(types.Integer())
    
class WeeklyUserPoint(Base):
	__tablename__ = 'weekly_user_points'
	__table_args__ = {"sqlite_autoincrement": True}
	id = Column(types.Integer(), primary_key=True)
	user_id = Column(types.Integer, ForeignKey(AuthID.id))    
	amount = Column(types.Integer(), default = 0)
	week = Column(types.Integer())


def populate(settings):
	## Add logistical data
	session = DBSession()
	default_groups = [(u'users',u'User Group'), (u'teachers',u'Teacher Group'), (u'admin',u'Admin Group')]
	for name, description in default_groups:
		group = AuthGroup(name=name, description=description)
		session.add(group)
		session.flush()
	transaction.commit()
	session.close()
	
	session = DBSession()
	languages={'ab':{'name':"Abkhaz",'nativename':"аҧсуа"},'aa':{'name':"Afar",'nativename':"Afaraf"},'af':{'name':"Afrikaans",'nativename':"Afrikaans"},'ak':{'name':"Akan",'nativename':"Akan"},'sq':{'name':"Albanian",'nativename':"Shqip"},'am':{'name':"Amharic",'nativename':"አማርኛ"},'ar':{'name':"Arabic",'nativename':"العربية"},'an':{'name':"Aragonese",'nativename':"Aragonés"},'hy':{'name':"Armenian",'nativename':"Հայերեն"},'as':{'name':"Assamese",'nativename':"অসমীয়া"},'av':{'name':"Avaric",'nativename':"авар мацӀ, магӀарул мацӀ"},'ae':{'name':"Avestan",'nativename':"avesta"},'ay':{'name':"Aymara",'nativename':"aymar aru"},'az':{'name':"Azerbaijani",'nativename':"azərbaycan dili"},'bm':{'name':"Bambara",'nativename':"bamanankan"},'ba':{'name':"Bashkir",'nativename':"башҡорт теле"},'eu':{'name':"Basque",'nativename':"euskara, euskera"},'be':{'name':"Belarusian",'nativename':"Беларуская"},'bn':{'name':"Bengali",'nativename':"বাংলা"},'bh':{'name':"Bihari",'nativename':"भोजपुरी"},'bi':{'name':"Bislama",'nativename':"Bislama"},'bs':{'name':"Bosnian",'nativename':"bosanski jezik"},'br':{'name':"Breton",'nativename':"brezhoneg"},'bg':{'name':"Bulgarian",'nativename':"български език"},'my':{'name':"Burmese",'nativename':"ဗမာစာ"},'ca':{'name':"Catalan; Valencian",'nativename':"Català"},'ch':{'name':"Chamorro",'nativename':"Chamoru"},'ce':{'name':"Chechen",'nativename':"нохчийн мотт"},'ny':{'name':"Chichewa; Chewa; Nyanja",'nativename':"chiCheŵa, chinyanja"},'zh':{'name':"Chinese",'nativename':"中文 (Zhōngwén), 汉语, 漢語"},'cv':{'name':"Chuvash",'nativename':"чӑваш чӗлхи"},'kw':{'name':"Cornish",'nativename':"Kernewek"},'co':{'name':"Corsican",'nativename':"corsu, lingua corsa"},'cr':{'name':"Cree",'nativename':"ᓀᐦᐃᔭᐍᐏᐣ"},'hr':{'name':"Croatian",'nativename':"hrvatski"},'cs':{'name':"Czech",'nativename':"česky, čeština"},'da':{'name':"Danish",'nativename':"dansk"},'dv':{'name':"Divehi; Dhivehi; Maldivian;",'nativename':"ދިވެހި"},'nl':{'name':"Dutch",'nativename':"Nederlands, Vlaams"},'en':{'name':"English",'nativename':"English"},'eo':{'name':"Esperanto",'nativename':"Esperanto"},'et':{'name':"Estonian",'nativename':"eesti, eesti keel"},'ee':{'name':"Ewe",'nativename':"Eʋegbe"},'fo':{'name':"Faroese",'nativename':"føroyskt"},'fj':{'name':"Fijian",'nativename':"vosa Vakaviti"},'fi':{'name':"Finnish",'nativename':"suomi, suomen kieli"},'fr':{'name':"French",'nativename':"français, langue française"},'ff':{'name':"Fula; Fulah; Pulaar; Pular",'nativename':"Fulfulde, Pulaar, Pular"},'gl':{'name':"Galician",'nativename':"Galego"},'ka':{'name':"Georgian",'nativename':"ქართული"},'de':{'name':"German",'nativename':"Deutsch"},'el':{'name':"Greek, Modern",'nativename':"Ελληνικά"},'gn':{'name':"Guaraní",'nativename':"Avañeẽ"},'gu':{'name':"Gujarati",'nativename':"ગુજરાતી"},'ht':{'name':"Haitian; Haitian Creole",'nativename':"Kreyòl ayisyen"},'ha':{'name':"Hausa",'nativename':"Hausa, هَوُسَ"},'he':{'name':"Hebrew (modern)",'nativename':"עברית"},'hz':{'name':"Herero",'nativename':"Otjiherero"},'hi':{'name':"Hindi",'nativename':"हिन्दी, हिंदी"},'ho':{'name':"Hiri Motu",'nativename':"Hiri Motu"},'hu':{'name':"Hungarian",'nativename':"Magyar"},'ia':{'name':"Interlingua",'nativename':"Interlingua"},'id':{'name':"Indonesian",'nativename':"Bahasa Indonesia"},'ie':{'name':"Interlingue",'nativename':"Originally called Occidental; then Interlingue after WWII"},'ga':{'name':"Irish",'nativename':"Gaeilge"},'ig':{'name':"Igbo",'nativename':"Asụsụ Igbo"},'ik':{'name':"Inupiaq",'nativename':"Iñupiaq, Iñupiatun"},'io':{'name':"Ido",'nativename':"Ido"},'is':{'name':"Icelandic",'nativename':"Íslenska"},'it':{'name':"Italian",'nativename':"Italiano"},'iu':{'name':"Inuktitut",'nativename':"ᐃᓄᒃᑎᑐᑦ"},'ja':{'name':"Japanese",'nativename':"日本語 (にほんご／にっぽんご)"},'jv':{'name':"Javanese",'nativename':"basa Jawa"},'kl':{'name':"Kalaallisut, Greenlandic",'nativename':"kalaallisut, kalaallit oqaasii"},'kn':{'name':"Kannada",'nativename':"ಕನ್ನಡ"},'kr':{'name':"Kanuri",'nativename':"Kanuri"},'ks':{'name':"Kashmiri",'nativename':"कश्मीरी, كشميري‎"},'kk':{'name':"Kazakh",'nativename':"Қазақ тілі"},'km':{'name':"Khmer",'nativename':"ភាសាខ្មែរ"},'ki':{'name':"Kikuyu, Gikuyu",'nativename':"Gĩkũyũ"},'rw':{'name':"Kinyarwanda",'nativename':"Ikinyarwanda"},'ky':{'name':"Kirghiz, Kyrgyz",'nativename':"кыргыз тили"},'kv':{'name':"Komi",'nativename':"коми кыв"},'kg':{'name':"Kongo",'nativename':"KiKongo"},'ko':{'name':"Korean",'nativename':"한국어 (韓國語), 조선말 (朝鮮語)"},'ku':{'name':"Kurdish",'nativename':"Kurdî, كوردی‎"},'kj':{'name':"Kwanyama, Kuanyama",'nativename':"Kuanyama"},'la':{'name':"Latin",'nativename':"latine, lingua latina"},'lb':{'name':"Luxembourgish, Letzeburgesch",'nativename':"Lëtzebuergesch"},'lg':{'name':"Luganda",'nativename':"Luganda"},'li':{'name':"Limburgish, Limburgan, Limburger",'nativename':"Limburgs"},'ln':{'name':"Lingala",'nativename':"Lingála"},'lo':{'name':"Lao",'nativename':"ພາສາລາວ"},'lt':{'name':"Lithuanian",'nativename':"lietuvių kalba"},'lu':{'name':"Luba-Katanga",'nativename':""},'lv':{'name':"Latvian",'nativename':"latviešu valoda"},'gv':{'name':"Manx",'nativename':"Gaelg, Gailck"},'mk':{'name':"Macedonian",'nativename':"македонски јазик"},'mg':{'name':"Malagasy",'nativename':"Malagasy fiteny"},'ms':{'name':"Malay",'nativename':"bahasa Melayu, بهاس ملايو‎"},'ml':{'name':"Malayalam",'nativename':"മലയാളം"},'mt':{'name':"Maltese",'nativename':"Malti"},'mi':{'name':"Māori",'nativename':"te reo Māori"},'mr':{'name':"Marathi (Marāṭhī)",'nativename':"मराठी"},'mh':{'name':"Marshallese",'nativename':"Kajin M̧ajeļ"},'mn':{'name':"Mongolian",'nativename':"монгол"},'na':{'name':"Nauru",'nativename':"Ekakairũ Naoero"},'nv':{'name':"Navajo, Navaho",'nativename':"Diné bizaad, Dinékʼehǰí"},'nb':{'name':"Norwegian Bokmål",'nativename':"Norsk bokmål"},'nd':{'name':"North Ndebele",'nativename':"isiNdebele"},'ne':{'name':"Nepali",'nativename':"नेपाली"},'ng':{'name':"Ndonga",'nativename':"Owambo"},'nn':{'name':"Norwegian Nynorsk",'nativename':"Norsk nynorsk"},'no':{'name':"Norwegian",'nativename':"Norsk"},'ii':{'name':"Nuosu",'nativename':"ꆈꌠ꒿ Nuosuhxop"},'nr':{'name':"South Ndebele",'nativename':"isiNdebele"},'oc':{'name':"Occitan",'nativename':"Occitan"},'oj':{'name':"Ojibwe, Ojibwa",'nativename':"ᐊᓂᔑᓈᐯᒧᐎᓐ"},'cu':{'name':"Old Church Slavonic, Church Slavic, Church Slavonic, Old Bulgarian, Old Slavonic",'nativename':"ѩзыкъ словѣньскъ"},'om':{'name':"Oromo",'nativename':"Afaan Oromoo"},'or':{'name':"Oriya",'nativename':"ଓଡ଼ିଆ"},'os':{'name':"Ossetian, Ossetic",'nativename':"ирон æвзаг"},'pa':{'name':"Panjabi, Punjabi",'nativename':"ਪੰਜਾਬੀ, پنجابی‎"},'pi':{'name':"Pāli",'nativename':"पाऴि"},'fa':{'name':"Persian",'nativename':"فارسی"},'pl':{'name':"Polish",'nativename':"polski"},'ps':{'name':"Pashto, Pushto",'nativename':"پښتو"},'pt':{'name':"Portuguese",'nativename':"Português"},'qu':{'name':"Quechua",'nativename':"Runa Simi, Kichwa"},'rm':{'name':"Romansh",'nativename':"rumantsch grischun"},'rn':{'name':"Kirundi",'nativename':"kiRundi"},'ro':{'name':"Romanian, Moldavian, Moldovan",'nativename':"română"},'ru':{'name':"Russian",'nativename':"русский язык"},'sa':{'name':"Sanskrit (Saṁskṛta)",'nativename':"संस्कृतम्"},'sc':{'name':"Sardinian",'nativename':"sardu"},'sd':{'name':"Sindhi",'nativename':"सिन्धी, سنڌي، سندھی‎"},'se':{'name':"Northern Sami",'nativename':"Davvisámegiella"},'sm':{'name':"Samoan",'nativename':"gagana faa Samoa"},'sg':{'name':"Sango",'nativename':"yângâ tî sängö"},'sr':{'name':"Serbian",'nativename':"српски језик"},'gd':{'name':"Scottish Gaelic; Gaelic",'nativename':"Gàidhlig"},'sn':{'name':"Shona",'nativename':"chiShona"},'si':{'name':"Sinhala, Sinhalese",'nativename':"සිංහල"},'sk':{'name':"Slovak",'nativename':"slovenčina"},'sl':{'name':"Slovene",'nativename':"slovenščina"},'so':{'name':"Somali",'nativename':"Soomaaliga, af Soomaali"},'st':{'name':"Southern Sotho",'nativename':"Sesotho"},'es':{'name':"Spanish; Castilian",'nativename':"español, castellano"},'su':{'name':"Sundanese",'nativename':"Basa Sunda"},'sw':{'name':"Swahili",'nativename':"Kiswahili"},'ss':{'name':"Swati",'nativename':"SiSwati"},'sv':{'name':"Swedish",'nativename':"svenska"},'ta':{'name':"Tamil",'nativename':"தமிழ்"},'te':{'name':"Telugu",'nativename':"తెలుగు"},'tg':{'name':"Tajik",'nativename':"тоҷикӣ, toğikī, تاجیکی‎"},'th':{'name':"Thai",'nativename':"ไทย"},'ti':{'name':"Tigrinya",'nativename':"ትግርኛ"},'bo':{'name':"Tibetan Standard, Tibetan, Central",'nativename':"བོད་ཡིག"},'tk':{'name':"Turkmen",'nativename':"Türkmen, Түркмен"},'tl':{'name':"Tagalog",'nativename':"Wikang Tagalog, ᜏᜒᜃᜅ᜔ ᜆᜄᜎᜓᜄ᜔"},'tn':{'name':"Tswana",'nativename':"Setswana"},'to':{'name':"Tonga (Tonga Islands)",'nativename':"faka Tonga"},'tr':{'name':"Turkish",'nativename':"Türkçe"},'ts':{'name':"Tsonga",'nativename':"Xitsonga"},'tt':{'name':"Tatar",'nativename':"татарча, tatarça, تاتارچا‎"},'tw':{'name':"Twi",'nativename':"Twi"},'ty':{'name':"Tahitian",'nativename':"Reo Tahiti"},'ug':{'name':"Uighur, Uyghur",'nativename':"Uyƣurqə, ئۇيغۇرچە‎"},'uk':{'name':"Ukrainian",'nativename':"українська"},'ur':{'name':"Urdu",'nativename':"اردو"},'uz':{'name':"Uzbek",'nativename':"zbek, Ўзбек, أۇزبېك‎"},'ve':{'name':"Venda",'nativename':"Tshivenḓa"},'vi':{'name':"Vietnamese",'nativename':"Tiếng Việt"},'vo':{'name':"Volapük",'nativename':"Volapük"},'wa':{'name':"Walloon",'nativename':"Walon"},'cy':{'name':"Welsh",'nativename':"Cymraeg"},'wo':{'name':"Wolof",'nativename':"Wollof"},'fy':{'name':"Western Frisian",'nativename':"Frysk"},'xh':{'name':"Xhosa",'nativename':"isiXhosa"},'yi':{'name':"Yiddish",'nativename':"ייִדיש"},'yo':{'name':"Yoruba",'nativename':"Yorùbá"},'za':{'name':"Zhuang, Chuang",'nativename':"Saɯ cueŋƅ, Saw cuengh"}}
	#languages = [("Abkhaz","аҧсуа"),("Afar","Afaraf"),("Afrikaans","Afrikaans"),("Akan","Akan"),("Albanian","Shqip"),("Amharic","አማርኛ"),("Arabic","العربية"),("Aragonese","Aragonés"),("Armenian","Հայերեն"),("Assamese","অসমীয়া"),("Avaric","авар мацӀ"),("Avestan","avesta"),("Aymara","aymar aru"),("Azerbaijani","azərbaycan dili"),("Bambara","bamanankan"),("Bashkir","башҡорт теле"),("Basque","euskara"),("Belarusian","Беларуская"),("Bengali","বাংলা"),("Bihari","भोजपुरी"),("Bislama","Bislama"),("Bosnian","bosanski jezik"),("Breton","brezhoneg"),("Bulgarian","български език"),("Burmese","Burmese"),("Catalan","Català"),("Chamorro","Chamoru"),("Chechen","нохчийн мотт"),("Chichewa","chiCheŵa"),("Chinese","中文"),("Chuvash","чӑваш чӗлхи"),("Cornish","Kernewek"),("Corsican","corsu"),("Cree","ᓀᐦᐃᔭᐍᐏᐣ"),("Croatian","hrvatski"),("Czech","česky"),("Danish","dansk"),("Divehi","ދިވެހި"),("Dutch","Nederlands"),("Dzongkha","རྫོང་ཁ"),("English","English"),("Esperanto","Esperanto"),("Estonian","eesti"),("Ewe","Eʋegbe"),("Faroese","føroyskt"),("Fijian","vosa Vakaviti"),("Finnish","suomi"),("French","français"),("Fula","Fulfulde | Pulaar"),("Gaelic","Gàidhlig"),("Galician","Galego"),("Georgian","ქართული"),("German","Deutsch"),("Greek","Ελληνικά"),("Guaraní","Avañe'ẽ"),("Gujarati","ગુજરાતી"),("Haitian","Kreyòl ayisyen"),("Hausa","هَوُسَ"),("Hebrew","עברית"),("Herero","Otjiherero"),("Hindi","हिन्दी| हिंदी"),("Hiri Motu","Hiri Motu"),("Hungarian","Magyar"),("Icelandic","Íslenska"),("Ido","Ido"),("Igbo","Asụsụ Igbo"),("Indonesian","Bahasa Indonesia"),("Interlingua","Interlingua"),("Interlingue","Interlingue"),("Inuktitut","ᐃᓄᒃᑎᑐᑦ"),("Inupiaq","Iñupiaq"),("Irish","Gaeilge"),("Italian","Italiano"),("Japanese","日本語"),("Javanese","basa Jawa"),("Kalaallisut","kalaallisut"),("Kannada","ಕನ್ನಡ"),("Kanuri","Kanuri"),("Kashmiri","कश्मीरी"),("Kazakh","Қазақ тілі"),("Khmer","ភាសាខ្មែរ"),("Kikuyu","Gĩkũyũ"),("Kinyarwanda","Ikinyarwanda"),("Kirghiz","кыргыз тили"),("Kirundi","kiRundi"),("Komi","коми кыв"),("Kongo","KiKongo"),("Korean","한국어 (韓國語)"),("Kurdish","Kurdî"),("Kwanyama","Kuanyama"),("Lao","ພາສາລາວ"),("Latin","latine"),("Latvian","latviešu valoda"),("Lezgian","Лезги чlал"),("Limburgish","Limburgs"),("Lingala","Lingála"),("Lithuanian","lietuvių kalba"),("Luba-Katanga","Luba-Katanga"),("Luganda","Luganda"),("Luxembourgish","Lëtzebuergesch"),("Macedonian","македонски јазик"),("Malagasy","Malagasy fiteny"),("Malay","bahasa Melayu"),("Malayalam","മലയാളം"),("Maltese","Malti"),("Manx","Gaelg"),("Marathi","मराठी"),("Marshallese","Kajin M̧ajeļ"),("Mongolian","монгол"),("Māori","te reo Māori"),("Nauru","Ekakairũ Naoero"),("Navajo","Diné bizaad"),("Ndonga","Owambo"),("Nepali","नेपाली"),("North Ndebele","isiNdebele"),("Norwegian","Norsk"),("Nuosu","Nuosuhxop"),("Occitan","Occitan"),("Ojibwe","ᐊᓂᔑᓈᐯᒧᐎᓐ"),("Oriya","ଓଡ଼ିଆ"),("Oromo","Afaan Oromoo"),("Ossetian","ирон æвзаг"),("Panjabi","ਪੰਜਾਬੀ| پنجابی‎"),("Pashto","پښتو"),("Persian","فارسی"),("Polish","polski"),("Portuguese","Português"),("Pāli","पाऴि"),("Quechua","Kichwa"),("Romanian","română"),("Romansh","rumantsch grischun"),("Russian","русский язык"),("Sami (Northern)","Davvisámegiella"),("Samoan","gagana fa'a Samoa"),("Sango","yângâ tî sängö"),("Sanskrit","संस्कृतम्"),("Sardinian","sardu"),("Serbian","српски језик"),("Shona","chiShona"),("Sindhi","सिन्धी"),("Sinhala","සිංහල"),("Slavonic","ѩзыкъ словѣньскъ"),("Slovak","slovenčina"),("Slovene","slovenščina"),("Somali","Soomaaliga"),("South Ndebele","isiNdebele"),("Southern Sotho","Sesotho"),("Spanish","español | castellano"),("Sundanese","Basa Sunda"),("Swahili","Kiswahili"),("Swati","SiSwati"),("Swedish","svenska"),("Tagalog","Wikang Tagalog"),("Tahitian","Reo Tahiti"),("Tajik","тоҷикӣ"),("Tamil","தமிழ்"),("Tatar","татарча"),("Telugu","తెలుగు"),("Thai","ไทย"),("Tibetan","བོད་ཡིག"),("Tigrinya","ትግርኛ"),("Tonga","faka Tonga"),("Tsonga","Xitsonga"),("Tswana","Setswana"),("Turkish","Türkçe"),("Turkmen","Türkmen | Түркмен"),("Twi","Twi"),("Uighur","Uyƣurqə"),("Ukrainian","українська"),("Urdu","اردو"),("Uzbek","O'zbek"),("Venda","Tshivenḓa"),("Vietnamese","Tiếng Việt"),("Volapük","Volapük"),("Walloon","Walon"),("Welsh","Cymraeg"),("Western Frisian","Frysk"),("Wolof","Wollof"),("Xhosa","isiXhosa"),("Yiddish","ייִדיש"),("Yoruba","Yorùbá"),("Zhuang","Saɯ cueŋƅ"),("Zulu","isiZulu")]
	goog = ['Afrikaans', 'Albanian', 'Arabic', 'Armenian', 'Azerbaijani', 'Basque', 'Belarusian', 'Bengali', 'Bosnian', 'Bulgarian', 'Catalan', 'Cebuano', 'Chinese', 'Croatian', 'Czech', 'Danish', 'Dutch', 'English', 'Esperanto', 'Estonian', 'Filipino', 'Finnish', 'French', 'Galician', 'Georgian', 'German', 'Greek', 'Gujarati', 'Haitian Creole', 'Hausa', 'Hebrew', 'Hindi', 'Hmong', 'Hungarian', 'Icelandic', 'Igbo', 'Indonesian', 'Irish', 'Italian', 'Japanese', 'Javanese', 'Kannada', 'Khmer', 'Korean', 'Lao', 'Latin', 'Latvian', 'Lithuanian', 'Macedonian', 'Malay', 'Maltese', 'Maori', 'Marathi', 'Mongolian', 'Nepali', 'Norwegian', 'Persian', 'Polish', 'Portuguese', 'Punjabi', 'Romanian', 'Russian', 'Serbian', 'Slovak', 'Slovenian', 'Somali', 'Spanish', 'Swahili', 'Swedish', 'Tamil', 'Telugu', 'Thai', 'Turkish', 'Ukrainian', 'Urdu', 'Vietnamese', 'Welsh', 'Yiddish', 'Yoruba', 'Zulu']
	language_tuples = []
	for key in languages:
		language_tuples.append((languages[key]['name'], languages[key]['nativename'], key))
	language_tuples = sorted(language_tuples, key=lambda a: a[0])
	for l in language_tuples:
		goog_trans = None
		if goog.count(l[0]) > 0: goog_trans =l[2]
		language = Language(english_name=l[0], native_name=l[1], iso_lang=l[2], goog_translate=goog_trans)
		session.add(language)
	transaction.commit()
	session.close()

		
	
def initialize_sql(engine, settings):
	DBSession.configure(bind=engine)
	Base.metadata.bind = engine
	Base.metadata.create_all(engine)
	#    if settings.has_key('apex.velruse_providers'):
	#        pass
		#SQLBase.metadata.bind = engine
		#SQLBase.metadata.create_all(engine)
	try:
		populate(settings)
	except IntegrityError:
		transaction.abort()
	
