# -*- coding: utf-8 -*-


from models import (AuthID,
					AuthUser,
					AuthGroup,
					DBSession
					)
from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message
from pyramid.security import (Everyone,
                              Allow,
                              Deny,
                              Everyone,
                              Authenticated
                              )

class EmailMessageText(object):
    """ Default email message text class
    """

    def forgot(self):
        """
In the message body, %_url_% is replaced with:

::

    route_url('apex_reset', request, user_id=user_id, hmac=hmac))
        """
        return {
                'subject': 'Password reset request received',
                'body': """
A request to reset your password has been received. Please go to
the following URL to change your password:

%_url_%

If you did not make this request, you can safely ignore it.
""",
        }

    def activate(self):
        """
In the message body, %_url_% is replaced with:

::

    route_url('apex_activate', request, user_id=user_id, hmac=hmac))
        """
        return {
                'subject': 'Account activation. Please activate your account.',
                'body': """
This site requires account validation. Please follow the link below to
activate your account:

%_url_%

If you did not make this request, you can safely ignore it.
""",
        }

def my_email(request, recipients, subject, body, sender=None):
    """ Sends email message
    """
    mailer = get_mailer(request)
    if not sender:
        #sender = apex_settings('sender_email')
        if not sender:
            sender = 'nobody@example.com'
    message = Message(subject=subject,
                  sender=sender,
                  recipients=[recipients],
                  body=body)
    mailer.send(message)

def email_forgot(request, user_id, email, hmac):
    message_class_name = EmailMessageText
    message_class = message_class_name()
    message_text = getattr(message_class, 'forgot')()

    message_body = message_text['body'].replace('%_url_%', 'wooot')
        #route_url('apex_reset', request, user_id=user_id, hmac=hmac))

    my_email(request, email, message_text['subject'], message_body)

def email_activate(request, user_id, email, hmac):
    message_class_name = EmailMessageText
    message_class = message_class_name()
    message_text = getattr(message_class, 'activate')()

    message_body = message_text['body'].replace('%_url_%', \
        route_url('apex_activate', request, user_id=user_id, hmac=hmac))

    my_email(request, email, message_text['subject'], message_body)


def groupfinder(userid, request):
	""" Returns ACL formatted list of groups for the userid in the
	current request"""
	auth = AuthID.get_by_id(userid)
	if auth:
		return [('group:%s' % group.name) for group in auth.groups]

class RootFactory(object):
	""" Defines the default ACLs, groups populated from SQLAlchemy.
	"""
	@property
	def __acl__(self):
		dbsession = DBSession()
		groups = dbsession.query(AuthGroup.name).all()
		defaultlist = [ (Deny, Everyone, u'view'),
				(Allow, Authenticated, 'authenticated'),
				(Allow, Everyone, u'view'),
				(Allow, 'group:teachers', 'add'),
				(Allow, 'group:admin', 'add'), 
				]
		for g in groups:
			defaultlist.append( (Allow, 'group:%s' % g, g[0]) )
		return defaultlist
			
	
	def __init__(self, request):
		if request.matchdict:
			self.__dict__.update(request.matchdict)

#class GenericFallback(object):
    #def check(self, DBSession, request, user, password):
        #salted_passwd = user.password
        #prefix_salt = apex_settings('fallback_prefix_salt', None)
        #if prefix_salt:
            #salted_passwd = '%s%s' % (prefix_salt, salted_passwd)
        #salt_field = apex_settings('fallback_salt_field', None)
        #if salt_field:
            #prefix_salt = getattr(user, salt_field)
            #salted_passwd = '%s%s' % (prefix_salt, salted_passwd)

        #if salted_passwd is not None:
            #if len(salted_passwd) == 32:
                ## md5
                #m = hashlib.md5()
                ## password='Â·Â·Â·Â·Â breaks when type=unicode
                #m.update(password)
                #if m.hexdigest() == salted_passwd:
                    #user.password = password
                    #DBSession.merge(user)
                    #DBSession.flush()
                    #return True

            #if len(salted_passwd) == 40:
                ## sha1
                #m = hashlib.sha1()
                #m.update(password)
                #if m.hexdigest() == salted_passwd:
                    #user.password = password
                    #DBSession.merge(user)
                    #DBSession.flush()
                    #return True

            #if salted_passwd == password:
                ## plaintext
                #user.password = password
                #DBSession.merge(user)
                #DBSession.flush()
                #return True

        #return False
