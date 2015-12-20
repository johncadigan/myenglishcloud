-- MySQL dump 10.13  Distrib 5.5.37, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: englishc
-- ------------------------------------------------------
-- Server version	5.5.37-0ubuntu0.12.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `answers`
--

DROP TABLE IF EXISTS `answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL,
  `response` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `correct` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `response` (`response`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `answers_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `answers`
--

LOCK TABLES `answers` WRITE;
/*!40000 ALTER TABLE `answers` DISABLE KEYS */;
/*!40000 ALTER TABLE `answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_auth_groups`
--

DROP TABLE IF EXISTS `auth_auth_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_auth_groups` (
  `auth_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  KEY `group_id` (`group_id`),
  KEY `auth_group` (`auth_id`,`group_id`),
  CONSTRAINT `auth_auth_groups_ibfk_1` FOREIGN KEY (`auth_id`) REFERENCES `auth_id` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `auth_auth_groups_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `auth_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_auth_groups`
--

LOCK TABLES `auth_auth_groups` WRITE;
/*!40000 ALTER TABLE `auth_auth_groups` DISABLE KEYS */;
INSERT INTO `auth_auth_groups` VALUES (1,2),(2,1),(3,1),(4,1),(5,1),(6,1),(7,1),(8,1),(9,1),(10,1),(11,3);
/*!40000 ALTER TABLE `auth_auth_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_groups`
--

DROP TABLE IF EXISTS `auth_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_groups`
--

LOCK TABLES `auth_groups` WRITE;
/*!40000 ALTER TABLE `auth_groups` DISABLE KEYS */;
INSERT INTO `auth_groups` VALUES (1,'users','User Group'),(2,'teachers','Teacher Group'),(3,'admin','Admin Group');
/*!40000 ALTER TABLE `auth_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_id`
--

DROP TABLE IF EXISTS `auth_id`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_id` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `display_name` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `active` enum('Y','N','D') COLLATE utf8_unicode_ci DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `preferred_language` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `preferred_language` (`preferred_language`),
  CONSTRAINT `auth_id_ibfk_1` FOREIGN KEY (`preferred_language`) REFERENCES `languages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_id`
--

LOCK TABLES `auth_id` WRITE;
/*!40000 ALTER TABLE `auth_id` DISABLE KEYS */;
INSERT INTO `auth_id` VALUES (1,'Chris','Y','2014-08-17 18:14:15',133),(2,'Deborah','Y','2014-08-17 18:14:19',133),(3,'Gabe','Y','2014-08-17 18:14:19',148),(4,'Carl','Y','2014-08-17 18:14:19',148),(5,'Adrian','Y','2014-08-17 18:14:19',53),(6,'Grace','Y','2014-08-17 18:14:19',88),(7,'Jane','Y','2014-08-17 18:14:19',74),(8,'Doo','Y','2014-08-17 18:14:19',30),(9,'Bear','Y','2014-08-17 18:14:19',39),(10,'Flower','Y','2014-08-17 18:14:19',48),(11,'John','Y','2014-08-17 18:14:19',133);
/*!40000 ALTER TABLE `auth_id` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_log`
--

DROP TABLE IF EXISTS `auth_user_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_user_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `auth_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `ip_addr` varchar(39) COLLATE utf8_unicode_ci NOT NULL,
  `event` enum('L','R','P','F') COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_auth_user_log_auth_id` (`auth_id`),
  KEY `ix_auth_user_log_user_id` (`user_id`),
  CONSTRAINT `auth_user_log_ibfk_1` FOREIGN KEY (`auth_id`) REFERENCES `auth_id` (`id`),
  CONSTRAINT `auth_user_log_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_log`
--

LOCK TABLES `auth_user_log` WRITE;
/*!40000 ALTER TABLE `auth_user_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_users`
--

DROP TABLE IF EXISTS `auth_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `auth_id` int(11) DEFAULT NULL,
  `provider` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `login` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `salt` varchar(24) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `active` enum('Y','N','D') COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_auth_users_login` (`login`),
  KEY `ix_auth_users_email` (`email`),
  KEY `ix_auth_users_auth_id` (`auth_id`),
  KEY `ix_auth_users_provider` (`provider`),
  CONSTRAINT `auth_users_ibfk_1` FOREIGN KEY (`auth_id`) REFERENCES `auth_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_users`
--

LOCK TABLES `auth_users` WRITE;
/*!40000 ALTER TABLE `auth_users` DISABLE KEYS */;
INSERT INTO `auth_users` VALUES (1,1,'local','chris','ajsfjaslkdfjiweio','$2a$12$2.AHHHHHHHHHHKSJDF:KJSDFkjas;djfweoi','chris@blah.com','2014-08-17 18:14:15','Y'),(2,2,'local','Debbie','5befcc9ffae725505c5bf07a','$2a$12$tz7JkXo9jIxRg65NE5ZJM..OV2iOwUEmVnQ4WVS.v4lBhDq5zbMOO','debbie@blah.com','2014-08-17 18:14:19','Y'),(3,3,'local','Gabriel','b096d3a188f5993700b34cf5','$2a$12$B85twPe.IIbu4w1smRA7n.PRalWciUqF8scH/rDszz7aYaOfrLKO.','gabriel@blah.com','2014-08-17 18:14:19','Y'),(4,4,'local','Spain','7d57eaea34eb7874684d9295','$2a$12$6eql5L7OXOSSvixCzuD9Oul8QVDBTjirWyblmDBB.hRT2mKoj3u92','Madrid@blah.com','2014-08-17 18:14:19','Y'),(5,5,'local','Germany','06d5894f595a8a7f33fec4e7','$2a$12$gswH3ZTKpYgeSqTwtoLux.NSSklEMnubm516UzFzLcgXzg4MK3H46','Berlin@blah.com','2014-08-17 18:14:19','Y'),(6,6,'local','Korea','981f344d777ce164553fce58','$2a$12$GM09KnM.PzU8ygU6i3HK4ORhU9Nh/cQHG5s8yVD9dxpfI6zBUjKzK','Seoul@blah.com','2014-08-17 18:14:19','Y'),(7,7,'local','Japan','3984a66b1193c17996a6e97b','$2a$12$hS5hTwI1SlOKqqAb9rYsTOy0.603Bq85awe6Kqtxp2HN63aZjUc5a','Tokyo@blah.com','2014-08-17 18:14:19','Y'),(8,8,'local','China','fb479eb708dacfdd599529fb','$2a$12$uNyjSNrgf0w1HnF5iTtO0ORnlZfbCtd73EOV80pcsbAmZlqlK0DW6','Bejing@blah.com','2014-08-17 18:14:19','Y'),(9,9,'local','Netherlands','f4ece22a4f16c1e95f7e9d04','$2a$12$WeutNSWjy8AuAdn1RaiE7OYMsdGI.wxK8ezUkk9kk.L5GBgFaP.r.','Amsterdam@blah.com','2014-08-17 18:14:19','Y'),(10,10,'local','France','d16c9ebca1ce1cb941a2b901','$2a$12$zAeqwOOz1ku4DtA5sIdWnOCCyghnmjQsDlJbU7Vu1ctFhttP6D8MS','Paris@blah.com','2014-08-17 18:14:19','Y'),(11,11,'local','John','648177729ff8e1faae27b716','$2a$12$AhC.0DgbFXVVwdhxL0m59uc2lc8rx/Ppnb43rXIeaPXgUOWg7oPSu','john@blah.com','2014-08-17 18:14:19','Y');
/*!40000 ALTER TABLE `auth_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cards`
--

DROP TABLE IF EXISTS `cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lemma_id` int(11) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lemma_id` (`lemma_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `cards_ibfk_1` FOREIGN KEY (`lemma_id`) REFERENCES `english_lemmas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `cards_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=331 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cards`
--

LOCK TABLES `cards` WRITE;
/*!40000 ALTER TABLE `cards` DISABLE KEYS */;
INSERT INTO `cards` VALUES (1,1,3),(2,2,3),(3,3,3),(4,4,3),(5,5,3),(6,1,5),(7,2,5),(8,3,5),(9,4,5),(10,5,5),(11,1,7),(12,2,7),(13,3,7),(14,4,7),(15,5,7),(16,1,9),(17,2,9),(18,3,9),(19,4,9),(20,5,9),(21,1,14),(22,2,14),(23,3,14),(24,4,14),(25,5,14),(26,1,17),(27,2,17),(28,3,17),(29,4,17),(30,5,17),(31,1,18),(32,2,18),(33,3,18),(34,4,18),(35,5,18),(36,1,19),(37,2,19),(38,3,19),(39,4,19),(40,5,19),(41,1,22),(42,2,22),(43,3,22),(44,4,22),(45,5,22),(46,1,24),(47,2,24),(48,3,24),(49,4,24),(50,5,24),(51,1,30),(52,2,30),(53,3,30),(54,4,30),(55,5,30),(56,1,35),(57,2,35),(58,3,35),(59,4,35),(60,5,35),(61,1,36),(62,2,36),(63,3,36),(64,4,36),(65,5,36),(66,1,37),(67,2,37),(68,3,37),(69,4,37),(70,5,37),(71,1,39),(72,2,39),(73,3,39),(74,4,39),(75,5,39),(76,1,40),(77,2,40),(78,3,40),(79,4,40),(80,5,40),(81,1,41),(82,2,41),(83,3,41),(84,4,41),(85,5,41),(86,1,42),(87,2,42),(88,3,42),(89,4,42),(90,5,42),(91,1,46),(92,2,46),(93,3,46),(94,4,46),(95,5,46),(96,1,47),(97,2,47),(98,3,47),(99,4,47),(100,5,47),(101,1,49),(102,2,49),(103,3,49),(104,4,49),(105,5,49),(106,1,50),(107,2,50),(108,3,50),(109,4,50),(110,5,50),(111,1,51),(112,2,51),(113,3,51),(114,4,51),(115,5,51),(116,1,54),(117,2,54),(118,3,54),(119,4,54),(120,5,54),(121,1,56),(122,2,56),(123,3,56),(124,4,56),(125,5,56),(126,1,59),(127,2,59),(128,3,59),(129,4,59),(130,5,59),(131,1,61),(132,2,61),(133,3,61),(134,4,61),(135,5,61),(136,1,62),(137,2,62),(138,3,62),(139,4,62),(140,5,62),(141,1,64),(142,2,64),(143,3,64),(144,4,64),(145,5,64),(146,1,65),(147,2,65),(148,3,65),(149,4,65),(150,5,65),(151,1,70),(152,2,70),(153,3,70),(154,4,70),(155,5,70),(156,1,71),(157,2,71),(158,3,71),(159,4,71),(160,5,71),(161,1,72),(162,2,72),(163,3,72),(164,4,72),(165,5,72),(166,1,73),(167,2,73),(168,3,73),(169,4,73),(170,5,73),(171,1,75),(172,2,75),(173,3,75),(174,4,75),(175,5,75),(176,1,79),(177,2,79),(178,3,79),(179,4,79),(180,5,79),(181,1,86),(182,2,86),(183,3,86),(184,4,86),(185,5,86),(186,1,89),(187,2,89),(188,3,89),(189,4,89),(190,5,89),(191,1,90),(192,2,90),(193,3,90),(194,4,90),(195,5,90),(196,1,91),(197,2,91),(198,3,91),(199,4,91),(200,5,91),(201,1,94),(202,2,94),(203,3,94),(204,4,94),(205,5,94),(206,1,98),(207,2,98),(208,3,98),(209,4,98),(210,5,98),(211,1,100),(212,2,100),(213,3,100),(214,4,100),(215,5,100),(216,1,102),(217,2,102),(218,3,102),(219,4,102),(220,5,102),(221,1,106),(222,2,106),(223,3,106),(224,4,106),(225,5,106),(226,1,111),(227,2,111),(228,3,111),(229,4,111),(230,5,111),(231,1,114),(232,2,114),(233,3,114),(234,4,114),(235,5,114),(236,1,126),(237,2,126),(238,3,126),(239,4,126),(240,5,126),(241,1,127),(242,2,127),(243,3,127),(244,4,127),(245,5,127),(246,1,128),(247,2,128),(248,3,128),(249,4,128),(250,5,128),(251,1,133),(252,2,133),(253,3,133),(254,4,133),(255,5,133),(256,1,139),(257,2,139),(258,3,139),(259,4,139),(260,5,139),(261,1,143),(262,2,143),(263,3,143),(264,4,143),(265,5,143),(266,1,145),(267,2,145),(268,3,145),(269,4,145),(270,5,145),(271,1,150),(272,2,150),(273,3,150),(274,4,150),(275,5,150),(276,1,152),(277,2,152),(278,3,152),(279,4,152),(280,5,152),(281,1,156),(282,2,156),(283,3,156),(284,4,156),(285,5,156),(286,1,158),(287,2,158),(288,3,158),(289,4,158),(290,5,158),(291,1,159),(292,2,159),(293,3,159),(294,4,159),(295,5,159),(296,1,165),(297,2,165),(298,3,165),(299,4,165),(300,5,165),(301,1,169),(302,2,169),(303,3,169),(304,4,169),(305,5,169),(306,1,170),(307,2,170),(308,3,170),(309,4,170),(310,5,170),(311,1,173),(312,2,173),(313,3,173),(314,4,173),(315,5,173),(316,1,176),(317,2,176),(318,3,176),(319,4,176),(320,5,176),(321,1,180),(322,2,180),(323,3,180),(324,4,180),(325,5,180),(326,1,181),(327,2,181),(328,3,181),(329,4,181),(330,5,181);
/*!40000 ALTER TABLE `cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment_replies`
--

DROP TABLE IF EXISTS `comment_replies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment_replies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `text` varchar(1000) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`),
  KEY `ix_comment_replies_owner` (`owner`),
  CONSTRAINT `comment_replies_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `auth_id` (`id`),
  CONSTRAINT `comment_replies_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_replies`
--

LOCK TABLES `comment_replies` WRITE;
/*!40000 ALTER TABLE `comment_replies` DISABLE KEYS */;
/*!40000 ALTER TABLE `comment_replies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `comment_type` enum('C','Q') COLLATE utf8_unicode_ci DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `text` varchar(1000) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `content_id` (`content_id`),
  KEY `ix_comments_owner` (`owner`),
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `auth_id` (`id`),
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contents`
--

DROP TABLE IF EXISTS `contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('lesson','reading') COLLATE utf8_unicode_ci DEFAULT NULL,
  `released` date DEFAULT NULL,
  `title` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(350) COLLATE utf8_unicode_ci DEFAULT NULL,
  `picture_id` int(11) DEFAULT NULL,
  `url` text COLLATE utf8_unicode_ci,
  `views` int(11) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `quiz_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `picture_id` (`picture_id`),
  KEY `ix_contents_quiz_id` (`quiz_id`),
  KEY `ix_contents_owner` (`owner`),
  CONSTRAINT `contents_ibfk_1` FOREIGN KEY (`picture_id`) REFERENCES `pictures` (`id`),
  CONSTRAINT `contents_ibfk_2` FOREIGN KEY (`owner`) REFERENCES `auth_users` (`id`),
  CONSTRAINT `contents_ibfk_3` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contents`
--

LOCK TABLES `contents` WRITE;
/*!40000 ALTER TABLE `contents` DISABLE KEYS */;
INSERT INTO `contents` VALUES (1,'lesson','2013-10-29','English Pronunciation: F & V','This English lesson is about the pronunciation of F and V.',18,'english-pronunciation-f-v',0,11,1),(2,'lesson','2013-11-06','English Pronunciation: R & L','This free English lesson is about the pronunciation of \"R\" and \"L.\"',19,'english-pronunciation-r-l',0,11,2),(3,'lesson','2013-11-07','English Grammar: Articles (\"A\" & \"The\")','This is free English lesson is about articles (\"a\" & \"the\"). After this lesson, you will know when to use \"the\" and \"a.\"',20,'english-grammar-articles-a-the',0,11,3),(4,'lesson','2013-11-12','English Grammar: Simple Past & Past Continuous','This free English lesson is about the simple past and past continuous. After this lesson, you will know when to use them.',21,'english-grammar-simple-past-past-continuous',0,11,4),(5,'lesson','2013-10-16','English Pronunciation: K & G','This free English lesson covers the pronunciation of K & G',22,'english-pronunciation-k-g',0,11,5),(6,'lesson','2014-02-28','Present Perfect Continuous and Past Perfect Continuous','This English lesson is about the present perfect continuous and the past perfect continuous tenses.',23,'present-perfect-continuous-and-past-perfect-continuous',0,11,6),(7,'lesson','2013-11-07','English Grammar: How to say no (Negation)','This lesson is about negating sentences, making a sentence mean its opposite with the word \"not\" or \"never.\"',24,'english-grammar-how-to-say-no-negation',0,11,7),(8,'lesson','2013-10-16','English Pronunciation: T & D','This free English lesson covers the pronunciation of T and D.',25,'english-pronunciation-t-d',0,11,8),(9,'lesson','2013-11-13','English Grammar: Simple Past & Present Perfect','This free English lesson is about the simple past and present perfect.',26,'english-grammar-simple-past-present-perfect',0,11,9),(10,'lesson','2013-11-06','English Pronunciation: \"Ch\" & \"J\"','This free English lesson is about the pronunciation of \"ch\" and \"j.\"',27,'english-pronunciation-ch-j',0,11,10),(11,'lesson','2013-11-06','English Pronunciation: Sh & Zh','This free English lesson is about the pronunciation of \"sh\" as in ship and \"zh\" as in usual.',28,'english-pronunciation-sh-zh',0,11,11),(12,'lesson','2013-10-15','English Pronunciation: P & B','This free English lesson focuses on pronunciation of p and b.',29,'english-pronunciation-p-b',0,11,12),(13,'lesson','2013-10-22','English Pronunciation: S & Z','This English lesson is about the pronunciation of S and Z.',30,'english-pronunciation-s-z',0,11,13),(14,'lesson','2014-08-13','English Grammar: Will and be going to','This lesson is about will and be going to and how they are used to talk about the future.',31,'english-grammar-will-and-be-going-to',2,11,14),(15,'lesson','2013-10-10','Introduction to American Pronunciation','This free English lesson introduces American English pronunciation with the international phonetic alphabet.',32,'introduction-to-american-pronunciation',0,11,15),(16,'lesson','2013-11-05','English Pronunciation: Th','This lesson is about the two pronunciations of \"th.\"',33,'english-pronunciation-th',0,11,16),(17,'lesson','2013-11-24','English Grammar: Past Perfect','This free English lesson is on the past perfect. After this lesson, you will know when to use it.',34,'english-grammar-past-perfect',0,11,17),(18,'lesson','2014-01-28','Habits in the past with \"would\" and \"used to\"','This lesson shows how to talk about habits with would and used to',35,'habits-in-the-past-with-would-and-used-to',0,11,18);
/*!40000 ALTER TABLE `contents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `image` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=232 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `countries`
--

LOCK TABLES `countries` WRITE;
/*!40000 ALTER TABLE `countries` DISABLE KEYS */;
INSERT INTO `countries` VALUES (1,'Afghanistan','AF.png'),(2,'Albania','AL.png'),(3,'Algeria','DZ.png'),(4,'American Samoa','AS.png'),(5,'Andorra','AD.png'),(6,'Angola','AO.png'),(7,'Anguilla','AI.png'),(8,'Antarctica','AQ.png'),(9,'Antigua And Barbuda','AG.png'),(10,'Argentina','AR.png'),(11,'Armenia','AM.png'),(12,'Aruba','AW.png'),(13,'Australia','AU.png'),(14,'Austria','AT.png'),(15,'Azerbaijan','AZ.png'),(16,'Bahamas','BS.png'),(17,'Bahrain','BH.png'),(18,'Bangladesh','BD.png'),(19,'Barbados','BB.png'),(20,'Belarus','BY.png'),(21,'Belgium','BE.png'),(22,'Belize','BZ.png'),(23,'Benin','BJ.png'),(24,'Bermuda','BM.png'),(25,'Bhutan','BT.png'),(26,'Bolivia','BO.png'),(27,'Bosnia And Herzegowina','BA.png'),(28,'Botswana','BW.png'),(29,'Bouvet Island','_unknown.png'),(30,'Brazil','BR.png'),(31,'Brunei Darussalam','BN.png'),(32,'Bulgaria','BG.png'),(33,'Burkina Faso','BF.png'),(34,'Burundi','BI.png'),(35,'Cambodia','KH.png'),(36,'Cameroon','CM.png'),(37,'Canada','CA.png'),(38,'Cape Verde','CV.png'),(39,'Cayman Islands','KY.png'),(40,'Central African Rep','CF.png'),(41,'Chad','TD.png'),(42,'Chile','CL.png'),(43,'China','CN.png'),(44,'Christmas Island','CX.png'),(45,'Cocos Islands','CC.png'),(46,'Colombia','CO.png'),(47,'Comoros','KM.png'),(48,'Congo','CG.png'),(49,'Cook Islands','CK.png'),(50,'Costa Rica','CR.png'),(51,'Cote D`ivoire','CI.png'),(52,'Croatia','HR.png'),(53,'Cuba','CU.png'),(54,'Cyprus','CY.png'),(55,'Czech Republic','CZ.png'),(56,'Denmark','DK.png'),(57,'Djibouti','DJ.png'),(58,'Dominica','DM.png'),(59,'Dominican Republic','DO.png'),(60,'East Timor','_unknown.png'),(61,'Ecuador','EC.png'),(62,'Egypt','EG.png'),(63,'El Salvador','SV.png'),(64,'Equatorial Guinea','GQ.png'),(65,'Eritrea','ER.png'),(66,'Estonia','EE.png'),(67,'Ethiopia','ET.png'),(68,'Falkland Islands (Malvinas)','FK.png'),(69,'Faroe Islands','FO.png'),(70,'Fiji','FJ.png'),(71,'Finland','FI.png'),(72,'France','FR.png'),(73,'French Guiana','_unknown.png'),(74,'French Polynesia','PF.png'),(75,'French S. Territories','TF.png'),(76,'Gabon','GA.png'),(77,'Gambia','GM.png'),(78,'Georgia','GE.png'),(79,'Germany','DE.png'),(80,'Ghana','GH.png'),(81,'Gibraltar','GI.png'),(82,'Greece','GR.png'),(83,'Greenland','GL.png'),(84,'Grenada','GD.png'),(85,'Guadeloupe','_unknown.png'),(86,'Guam','GU.png'),(87,'Guatemala','GT.png'),(88,'Guinea','GN.png'),(89,'Guinea-bissau','GW.png'),(90,'Guyana','GY.png'),(91,'Haiti','HT.png'),(92,'Honduras','HN.png'),(93,'Hong Kong','HK.png'),(94,'Hungary','HU.png'),(95,'Iceland','IS.png'),(96,'India','IN.png'),(97,'Indonesia','ID.png'),(98,'Iran','IR.png'),(99,'Iraq','IQ.png'),(100,'Ireland','IE.png'),(101,'Israel','IL.png'),(102,'Italy','IT.png'),(103,'Jamaica','JM.png'),(104,'Japan','JP.png'),(105,'Jordan','JO.png'),(106,'Kazakhstan','KZ.png'),(107,'Kenya','KE.png'),(108,'Kiribati','KI.png'),(109,'Korea (North)','KP.png'),(110,'Korea (South)','KR.png'),(111,'Kuwait','KW.png'),(112,'Kyrgyzstan','KG.png'),(113,'Laos','LA.png'),(114,'Latvia','LV.png'),(115,'Lebanon','LB.png'),(116,'Lesotho','LS.png'),(117,'Liberia','LR.png'),(118,'Libya','LY.png'),(119,'Liechtenstein','LI.png'),(120,'Lithuania','LT.png'),(121,'Luxembourg','LU.png'),(122,'Macau','MO.png'),(123,'Macedonia','MK.png'),(124,'Madagascar','MG.png'),(125,'Malawi','MW.png'),(126,'Malaysia','MY.png'),(127,'Maldives','MV.png'),(128,'Mali','ML.png'),(129,'Malta','MT.png'),(130,'Marshall Islands','MH.png'),(131,'Martinique','MQ.png'),(132,'Mauritania','MR.png'),(133,'Mauritius','MU.png'),(134,'Mayotte','YT.png'),(135,'Mexico','MX.png'),(136,'Micronesia','FM.png'),(137,'Moldova','MD.png'),(138,'Monaco','MC.png'),(139,'Mongolia','MN.png'),(140,'Montserrat','MS.png'),(141,'Morocco','MA.png'),(142,'Mozambique','MZ.png'),(143,'Myanmar','MM.png'),(144,'Namibia','NA.png'),(145,'Nauru','NR.png'),(146,'Nepal','NP.png'),(147,'Netherlands','NL.png'),(148,'Netherlands Antilles','AN.png'),(149,'New Caledonia','NC.png'),(150,'New Zealand','NZ.png'),(151,'Nicaragua','NI.png'),(152,'Niger','NE.png'),(153,'Nigeria','NG.png'),(154,'Niue','NU.png'),(155,'Norfolk Island','NF.png'),(156,'Northern Mariana Islands','MP.png'),(157,'Norway','NO.png'),(158,'Oman','OM.png'),(159,'Pakistan','PK.png'),(160,'Palau','PW.png'),(161,'Panama','PA.png'),(162,'Papua New Guinea','PG.png'),(163,'Paraguay','PY.png'),(164,'Peru','PE.png'),(165,'Philippines','PH.png'),(166,'Pitcairn','PN.png'),(167,'Poland','PL.png'),(168,'Portugal','PT.png'),(169,'Puerto Rico','PR.png'),(170,'Qatar','QA.png'),(171,'Reunion','_unknown.png'),(172,'Romania','RO.png'),(173,'Russian Federation','RU.png'),(174,'Rwanda','RW.png'),(175,'Saint Kitts And Nevis','KN.png'),(176,'Saint Lucia','LC.png'),(177,'Samoa','WS.png'),(178,'San Marino','SM.png'),(179,'Sao Tome','ST.png'),(180,'Saudi Arabia','SA.png'),(181,'Senegal','SN.png'),(182,'Seychelles','SC.png'),(183,'Sierra Leone','SL.png'),(184,'Singapore','SG.png'),(185,'Slovakia','SK.png'),(186,'Slovenia','SI.png'),(187,'Solomon Islands','SB.png'),(188,'Somalia','SO.png'),(189,'South Africa','ZA.png'),(190,'Spain','ES.png'),(191,'Sri Lanka','LK.png'),(192,'St Vincent/Grenadines','VC.png'),(193,'St. Helena','SH.png'),(194,'St.Pierre','_unknown.png'),(195,'Sudan','SD.png'),(196,'Suriname','SR.png'),(197,'Swaziland','SZ.png'),(198,'Sweden','SE.png'),(199,'Switzerland','CH.png'),(200,'Syrian Arab Republic','SY.png'),(201,'Taiwan','TW.png'),(202,'Tajikistan','TJ.png'),(203,'Tanzania','TZ.png'),(204,'Thailand','TH.png'),(205,'Togo','TG.png'),(206,'Tokelau','TK.png'),(207,'Tonga','TO.png'),(208,'Trinidad And Tobago','TT.png'),(209,'Tunisia','TN.png'),(210,'Turkey','TR.png'),(211,'Turkmenistan','TM.png'),(212,'Tuvalu','TV.png'),(213,'Uganda','UG.png'),(214,'Ukraine','UA.png'),(215,'United Arab Emirates','AE.png'),(216,'United Kingdom','_unknown.png'),(217,'United States','US.png'),(218,'Uruguay','UY.png'),(219,'Uzbekistan','UZ.png'),(220,'Vanuatu','VU.png'),(221,'Vatican City State','VA.png'),(222,'Venezuela','VE.png'),(223,'Viet Nam','VN.png'),(224,'Virgin Islands (British)','VG.png'),(225,'Virgin Islands (U.S.)','VI.png'),(226,'Western Sahara','EH.png'),(227,'Yemen','YE.png'),(228,'Yugoslavia','_unknown.png'),(229,'Zaire','_unknown.png'),(230,'Zambia','ZM.png'),(231,'Zimbabwe','ZW.png');
/*!40000 ALTER TABLE `countries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `difficulty_votes`
--

DROP TABLE IF EXISTS `difficulty_votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `difficulty_votes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `score` int(11) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `content_id` (`content_id`),
  KEY `ix_difficulty_votes_owner` (`owner`),
  CONSTRAINT `difficulty_votes_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `auth_id` (`id`),
  CONSTRAINT `difficulty_votes_ibfk_2` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `difficulty_votes`
--

LOCK TABLES `difficulty_votes` WRITE;
/*!40000 ALTER TABLE `difficulty_votes` DISABLE KEYS */;
/*!40000 ALTER TABLE `difficulty_votes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `english_forms`
--

DROP TABLE IF EXISTS `english_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `english_forms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `english_forms`
--

LOCK TABLES `english_forms` WRITE;
/*!40000 ALTER TABLE `english_forms` DISABLE KEYS */;
INSERT INTO `english_forms` VALUES (1,'school'),(2,'in'),(3,'slowly'),(4,'go'),(5,'and');
/*!40000 ALTER TABLE `english_forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `english_lemma_categories`
--

DROP TABLE IF EXISTS `english_lemma_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `english_lemma_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lemma_id` int(11) DEFAULT NULL,
  `lvl` int(11) NOT NULL,
  `lft` int(11) NOT NULL,
  `rgt` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `lemma_id` (`lemma_id`),
  CONSTRAINT `english_lemma_categories_ibfk_1` FOREIGN KEY (`lemma_id`) REFERENCES `english_lemmas` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `english_lemma_categories`
--

LOCK TABLES `english_lemma_categories` WRITE;
/*!40000 ALTER TABLE `english_lemma_categories` DISABLE KEYS */;
INSERT INTO `english_lemma_categories` VALUES (1,'ALL',NULL,0,1,2);
/*!40000 ALTER TABLE `english_lemma_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `english_lemmas`
--

DROP TABLE IF EXISTS `english_lemmas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `english_lemmas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `example_sentence` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `pos` enum('Noun','Pronoun','Adjective','Adverb','Verb','Phrasal Verb','Preposition','Conjunction','Collocation','Slang') COLLATE utf8_unicode_ci NOT NULL,
  `picture_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner` (`owner`),
  KEY `form_id` (`form_id`),
  KEY `picture_id` (`picture_id`),
  CONSTRAINT `english_lemmas_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `auth_id` (`id`),
  CONSTRAINT `english_lemmas_ibfk_2` FOREIGN KEY (`form_id`) REFERENCES `english_forms` (`id`),
  CONSTRAINT `english_lemmas_ibfk_3` FOREIGN KEY (`picture_id`) REFERENCES `pictures` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `english_lemmas`
--

LOCK TABLES `english_lemmas` WRITE;
/*!40000 ALTER TABLE `english_lemmas` DISABLE KEYS */;
INSERT INTO `english_lemmas` VALUES (1,11,4,'I ____ to the bus stop every day','Verb',2),(2,11,1,'I learned a lot at ____','Noun',3),(3,11,2,'I am ____ my room','Preposition',4),(4,11,3,'It is good to eat ____','Adverb',5),(5,11,5,'I like salt ____ pepper','Conjunction',6);
/*!40000 ALTER TABLE `english_lemmas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flashcardhistories`
--

DROP TABLE IF EXISTS `flashcardhistories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flashcardhistories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `flashcard_id` int(11) DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `level` enum('Show','4Source','8Source','4Target','8Target','Flashcard1','Flashcard2','Flashcard3','Flashcard4','Flashcard5','Flashcard6','Flashcard7','Flashcard8') COLLATE utf8_unicode_ci DEFAULT NULL,
  `response_time` int(11) DEFAULT NULL,
  `response` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `correct` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_flashcardhistories_flashcard_id` (`flashcard_id`),
  CONSTRAINT `flashcardhistories_ibfk_1` FOREIGN KEY (`flashcard_id`) REFERENCES `flashcards` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flashcardhistories`
--

LOCK TABLES `flashcardhistories` WRITE;
/*!40000 ALTER TABLE `flashcardhistories` DISABLE KEYS */;
/*!40000 ALTER TABLE `flashcardhistories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flashcards`
--

DROP TABLE IF EXISTS `flashcards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flashcards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_id` int(11) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `level` enum('Show','4Source','8Source','4Target','8Target','Flashcard1','Flashcard2','Flashcard3','Flashcard4','Flashcard5','Flashcard6','Flashcard7','Flashcard8') COLLATE utf8_unicode_ci DEFAULT NULL,
  `due` date DEFAULT NULL,
  `interval` int(11) DEFAULT NULL,
  `ease` int(11) DEFAULT NULL,
  `correct` int(11) DEFAULT NULL,
  `incorrect` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `card_id` (`card_id`),
  KEY `owner` (`owner`),
  CONSTRAINT `flashcards_ibfk_1` FOREIGN KEY (`card_id`) REFERENCES `cards` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `flashcards_ibfk_2` FOREIGN KEY (`owner`) REFERENCES `auth_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flashcards`
--

LOCK TABLES `flashcards` WRITE;
/*!40000 ALTER TABLE `flashcards` DISABLE KEYS */;
/*!40000 ALTER TABLE `flashcards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `foreign_lemmas`
--

DROP TABLE IF EXISTS `foreign_lemmas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `foreign_lemmas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `language_id` int(11) DEFAULT NULL,
  `form` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `foreign_lemmas_ibfk_1` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=330 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `foreign_lemmas`
--

LOCK TABLES `foreign_lemmas` WRITE;
/*!40000 ALTER TABLE `foreign_lemmas` DISABLE KEYS */;
INSERT INTO `foreign_lemmas` VALUES (1,42,'minna'),(2,70,'dul'),(3,102,'go'),(4,79,'ចូលទៅ'),(5,176,'fynd'),(6,170,'جاؤ'),(7,127,'przejdź'),(8,89,'ໄປ'),(9,100,'pergi'),(10,51,'gehen'),(11,37,'gå'),(12,5,'shkoni'),(13,152,'gå'),(14,14,'getmək'),(15,159,'ไป'),(16,98,'одат'),(17,30,'去'),(18,169,'перейти'),(19,47,'aller'),(20,165,'gitmek'),(21,46,'Siirry'),(22,91,'go'),(23,143,'ísť'),(24,114,'gå'),(25,150,'kwenda'),(26,71,'andare'),(27,22,'idi'),(28,111,'जाने'),(29,139,'иди'),(30,181,'lọ'),(31,56,'tafi'),(32,94,'eiti'),(33,39,'gaan'),(34,40,'go'),(35,145,'tagaan'),(36,61,'megy'),(37,59,'जाओ'),(38,106,'явах'),(39,158,'వెళ్ళి'),(40,24,'отидете'),(41,126,'به'),(42,17,'joan'),(43,7,'ذهاب'),(44,41,'iri'),(45,90,'vade,'),(46,73,'pindhah'),(47,86,'이동'),(48,35,'go'),(49,180,'גיין'),(50,128,'ir'),(51,36,'jít'),(52,49,'ir'),(53,3,'gaan'),(54,19,'যান'),(55,133,'перейти'),(56,62,'fara'),(57,18,'перайсці'),(58,9,'գնալ'),(59,173,'đi'),(60,64,'aga'),(61,75,'ಹೋಗಿ'),(62,156,'செல்ல'),(63,54,'જાઓ'),(64,65,'pergi'),(65,72,'行く'),(66,50,'გადასვლა'),(67,42,'kool'),(68,176,'ysgol'),(69,79,'សាលារៀន'),(70,102,'iskola'),(71,159,'โรงเรียน'),(72,111,'स्कूल'),(73,152,'skola'),(74,47,'école'),(75,100,'sekolah'),(76,14,'məktəb'),(77,40,'school'),(78,150,'shule'),(79,91,'skola'),(80,139,'Сцхоол'),(81,70,'scoil'),(82,61,'iskola'),(83,170,'اسکول'),(84,17,'eskola'),(85,94,'mokykla'),(86,169,'школа'),(87,165,'okul'),(88,35,'škola'),(89,46,'koulu'),(90,5,'shkolla'),(91,89,'ໂຮງຮຽນ'),(92,37,'skole'),(93,59,'स्कूल'),(94,127,'szkoła'),(95,158,'పాఠశాల'),(96,39,'de school'),(97,98,'училиште'),(98,51,'Schule'),(99,71,'scuola'),(100,24,'училище'),(101,181,'ile-iwe'),(102,114,'skole'),(103,22,'škole'),(104,49,'escola'),(105,73,'sekolah'),(106,30,'学校'),(107,180,'שולע'),(108,64,'ụlọ akwụkwọ'),(109,143,'škola'),(110,36,'škola'),(111,18,'школа'),(112,128,'escola'),(113,56,'makaranta'),(114,3,'skool'),(115,50,'სკოლა'),(116,145,'dugsiga'),(117,106,'сургууль'),(118,173,'trường'),(119,133,'школа'),(120,7,'المدرسة'),(121,126,'مدرسه'),(122,65,'sekolah'),(123,156,'பள்ளி'),(124,62,'skóli'),(125,90,'scholae'),(126,41,'lernejo'),(127,86,'학교'),(128,19,'স্কুল'),(129,181,'ni'),(130,71,'in'),(131,3,'in'),(132,165,'içinde'),(133,102,'fil'),(134,24,'в'),(135,86,'에서'),(136,30,'在'),(137,94,'į'),(138,49,'en'),(139,70,'i'),(140,90,'in'),(141,42,'aastal'),(142,98,'во'),(143,36,'v'),(144,89,'ໃນ'),(145,158,'లో'),(146,7,'في'),(147,111,'मा'),(148,51,'in'),(149,46,'vuonna'),(150,41,'en'),(151,35,'u'),(152,145,'in'),(153,133,'в'),(154,106,'нь'),(155,17,'in'),(156,64,'na'),(157,152,'i'),(158,65,'di'),(159,170,'میں'),(160,127,'w'),(161,14,'da'),(162,180,'אין'),(163,59,'में'),(164,18,'ў'),(165,114,'i'),(166,126,'در'),(167,5,'në'),(168,62,'í'),(169,47,'dans'),(170,56,'a'),(171,40,'in'),(172,19,'মধ্যে'),(173,128,'em'),(174,176,'yn'),(175,159,'ใน'),(176,143,'v'),(177,50,'in'),(178,169,'в'),(179,79,'ក្នុង'),(180,37,'i'),(181,91,'in'),(182,61,'a'),(183,73,'ing'),(184,139,'у'),(185,173,'trong'),(186,100,'dalam'),(187,39,'in'),(188,22,'u'),(189,150,'katika'),(190,156,'உள்ள'),(191,54,'શાળા'),(192,72,'学校'),(193,75,'ಶಾಲೆಯ'),(194,9,'դպրոց'),(195,24,'бавно'),(196,102,'bil-mod'),(197,70,'mall'),(198,90,'sensim'),(199,46,'hitaasti'),(200,41,'malrapide'),(201,94,'lėtai'),(202,106,'удаан'),(203,98,'и'),(204,89,'ແລະ'),(205,47,'et'),(206,181,'ati ki o'),(207,40,'and'),(208,14,'və'),(209,100,'dan'),(210,59,'और'),(211,51,'und'),(212,180,'און'),(213,145,'iyo'),(214,17,'eta'),(215,65,'dan'),(216,22,'i'),(217,143,'a'),(218,139,'и'),(219,73,'lan'),(220,50,'და'),(221,56,'da kuma'),(222,35,'i'),(223,91,'un'),(224,114,'og'),(225,176,'a'),(226,111,'र'),(227,79,'និង'),(228,128,'e'),(229,75,'ನಿಧಾನವಾಗಿ'),(230,156,'மற்றும்'),(231,37,'og'),(232,150,'na'),(233,126,'و'),(234,61,'és'),(235,9,'կամաց - կամաց'),(236,39,'en'),(237,173,'và'),(238,54,'ધીમે ધીમે'),(239,72,'ゆっくり'),(240,75,'ಮತ್ತು'),(241,54,'અને'),(242,9,'եւ'),(243,72,'そして'),(244,37,'langsomt'),(245,94,'ir'),(246,114,'sakte'),(247,156,'மெதுவாக'),(248,143,'pomaly'),(249,145,'Si tartiib ah'),(250,50,'ნელა'),(251,98,'полека'),(252,90,'et'),(253,41,'kaj'),(254,54,'માં'),(255,61,'lassan'),(256,176,'araf'),(257,56,'sannu a hankali'),(258,72,'中に'),(259,91,'lēni'),(260,9,'- ին'),(261,22,'polako'),(262,40,'slowly'),(263,70,'agus'),(264,169,'повільно'),(265,65,'perlahan-lahan'),(266,73,'alon'),(267,35,'polako'),(268,102,'u'),(269,79,'យឺត'),(270,111,'बिस्तारै'),(271,100,'perlahan-lahan'),(272,14,'yavaş-yavaş'),(273,75,'ರಲ್ಲಿ'),(274,18,'павольна'),(275,159,'อย่างช้าๆ'),(276,126,'به آرامی'),(277,24,'и'),(278,17,'astiro'),(279,181,'laiyara'),(280,39,'langzaam'),(281,89,'ຊ້າ'),(282,180,'סלאָולי'),(283,59,'धीरे धीरे'),(284,46,'ja'),(285,47,'lentement'),(286,150,'polepole'),(287,128,'lentamente'),(288,152,'långsamt'),(289,19,'ধীরে ধীরে'),(290,51,'langsam'),(291,173,'chậm'),(292,64,'nwayọọ nwayọọ na-'),(293,127,'powoli'),(294,30,'慢慢'),(295,86,'천천히'),(296,139,'полако'),(297,42,'aeglaselt'),(298,71,'lentamente'),(299,133,'медленно'),(300,170,'آہستہ آہستہ'),(301,5,'ngadalë'),(302,7,'ببطء'),(303,165,'yavaş yavaş'),(304,3,'stadig'),(305,49,'lentamente'),(306,158,'నెమ్మదిగా'),(307,36,'pomalu'),(308,62,'hægt'),(309,169,'і'),(310,170,'اور'),(311,71,'e'),(312,7,'و'),(313,3,'en'),(314,42,'ja'),(315,159,'และ'),(316,18,'і'),(317,127,'i'),(318,106,'болон'),(319,19,'এবং'),(320,49,'e'),(321,152,'och'),(322,133,'и'),(323,62,'og'),(324,36,'a'),(325,86,'및'),(326,158,'మరియు'),(327,165,'ve'),(328,5,'dhe'),(329,30,'和');
/*!40000 ALTER TABLE `foreign_lemmas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_infos`
--

DROP TABLE IF EXISTS `form_infos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_infos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` int(11) DEFAULT NULL,
  `definitions` varchar(1000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `freq` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_id` (`form_id`),
  CONSTRAINT `form_infos_ibfk_1` FOREIGN KEY (`form_id`) REFERENCES `english_forms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_infos`
--

LOCK TABLES `form_infos` WRITE;
/*!40000 ALTER TABLE `form_infos` DISABLE KEYS */;
INSERT INTO `form_infos` VALUES (1,1,'[\'an educational institution\', \'a building where young people receive education\', \'the process of being formally educated at a school\', \'a body of creative artists or writers or thinkers linked by a similar style or by similar teachers\', \'the period of instruction in a school; the time period when school is in session\', \"an educational institution\'s faculty and students\", \'a large group of fish\', \'educate in or as if in a school\', \'teach or refine to be discriminative in taste or judgment\', \'swim in or form a large group of fish\']\n',152495),(2,2,'[\'a unit of length equal to one twelfth of a foot\', \'a rare soft silvery metallic element; occurs in small quantities in sphalerite\', \'a state in midwestern United States\', \'holding office\', \'directed or bound inward\', \'currently fashionable\', \'to or toward the inside of\']\n',7611793),(3,3,'[\"without speed (`slow\' is sometimes used informally for `slowly\')\", \'in music\']\n',23365),(4,4,'[\'a time for working (after which you will be relieved by someone else)\', \'street names for methylenedioxymethamphetamine\', \'a usually brief attempt\', \"a board game for two players who place counters on a grid; the object is to surround and so capture the opponent\'s counters\", \'change location; move, travel, or proceed, also metaphorically\', \'follow a procedure or take a course\', \'move away from a place into another direction\', \'enter or assume a certain state or condition\', \'be awarded; be allotted\', \'have a particular form\', \'stretch out over a distance, space, time, or scope; run or extend between two points or beyond a certain point\', \'follow a certain course\', \'be abolished or discarded\', \'be or continue to be in a certain condition\', \'make a certain noise or sound\', \'perform as expected when applied\', \'to be spent or finished\', \'progress by being changed\', \'continue to live through hardship or adversity\', \'pass, fare, or elapse; of a certain state of affairs or action\', \'pass fro',333351),(5,5,'[\'subsequently or soon afterward (often used as sentence connectors)\']\n',1050218);
/*!40000 ALTER TABLE `form_infos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language_profile_pairs`
--

DROP TABLE IF EXISTS `language_profile_pairs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_profile_pairs` (
  `language_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  KEY `profile_id` (`profile_id`),
  KEY `language_profile` (`language_id`,`profile_id`),
  CONSTRAINT `language_profile_pairs_ibfk_1` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `language_profile_pairs_ibfk_2` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language_profile_pairs`
--

LOCK TABLES `language_profile_pairs` WRITE;
/*!40000 ALTER TABLE `language_profile_pairs` DISABLE KEYS */;
INSERT INTO `language_profile_pairs` VALUES (41,1),(41,2),(41,3),(41,4),(41,5),(41,6),(41,7),(41,8),(41,9),(41,10);
/*!40000 ALTER TABLE `language_profile_pairs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `english_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `native_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `iso_lang` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `goog_translate` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=183 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
INSERT INTO `languages` VALUES (1,'Abkhaz','аҧсуа','ab',NULL),(2,'Afar','Afaraf','aa',NULL),(3,'Afrikaans','Afrikaans','af','af'),(4,'Akan','Akan','ak',NULL),(5,'Albanian','Shqip','sq','sq'),(6,'Amharic','አማርኛ','am',NULL),(7,'Arabic','العربية','ar','ar'),(8,'Aragonese','Aragonés','an',NULL),(9,'Armenian','Հայերեն','hy','hy'),(10,'Assamese','অসমীয়া','as',NULL),(11,'Avaric','авар мацӀ, магӀарул мацӀ','av',NULL),(12,'Avestan','avesta','ae',NULL),(13,'Aymara','aymar aru','ay',NULL),(14,'Azerbaijani','azərbaycan dili','az','az'),(15,'Bambara','bamanankan','bm',NULL),(16,'Bashkir','башҡорт теле','ba',NULL),(17,'Basque','euskara, euskera','eu','eu'),(18,'Belarusian','Беларуская','be','be'),(19,'Bengali','বাংলা','bn','bn'),(20,'Bihari','भोजपुरी','bh',NULL),(21,'Bislama','Bislama','bi',NULL),(22,'Bosnian','bosanski jezik','bs','bs'),(23,'Breton','brezhoneg','br',NULL),(24,'Bulgarian','български език','bg','bg'),(25,'Burmese','ဗမာစာ','my',NULL),(26,'Catalan; Valencian','Català','ca',NULL),(27,'Chamorro','Chamoru','ch',NULL),(28,'Chechen','нохчийн мотт','ce',NULL),(29,'Chichewa; Chewa; Nyanja','chiCheŵa, chinyanja','ny',NULL),(30,'Chinese','中文 (Zhōngwén), 汉语, 漢語','zh','zh'),(31,'Chuvash','чӑваш чӗлхи','cv',NULL),(32,'Cornish','Kernewek','kw',NULL),(33,'Corsican','corsu, lingua corsa','co',NULL),(34,'Cree','ᓀᐦᐃᔭᐍᐏᐣ','cr',NULL),(35,'Croatian','hrvatski','hr','hr'),(36,'Czech','česky, čeština','cs','cs'),(37,'Danish','dansk','da','da'),(38,'Divehi; Dhivehi; Maldivian;','ދިވެހި','dv',NULL),(39,'Dutch','Nederlands, Vlaams','nl','nl'),(40,'English','English','en','en'),(41,'Esperanto','Esperanto','eo','eo'),(42,'Estonian','eesti, eesti keel','et','et'),(43,'Ewe','Eʋegbe','ee',NULL),(44,'Faroese','føroyskt','fo',NULL),(45,'Fijian','vosa Vakaviti','fj',NULL),(46,'Finnish','suomi, suomen kieli','fi','fi'),(47,'French','français, langue française','fr','fr'),(48,'Fula; Fulah; Pulaar; Pular','Fulfulde, Pulaar, Pular','ff',NULL),(49,'Galician','Galego','gl','gl'),(50,'Georgian','ქართული','ka','ka'),(51,'German','Deutsch','de','de'),(52,'Greek, Modern','Ελληνικά','el',NULL),(53,'Guaraní','Avañeẽ','gn',NULL),(54,'Gujarati','ગુજરાતી','gu','gu'),(55,'Haitian; Haitian Creole','Kreyòl ayisyen','ht',NULL),(56,'Hausa','Hausa, هَوُسَ','ha','ha'),(57,'Hebrew (modern)','עברית','he',NULL),(58,'Herero','Otjiherero','hz',NULL),(59,'Hindi','हिन्दी, हिंदी','hi','hi'),(60,'Hiri Motu','Hiri Motu','ho',NULL),(61,'Hungarian','Magyar','hu','hu'),(62,'Icelandic','Íslenska','is','is'),(63,'Ido','Ido','io',NULL),(64,'Igbo','Asụsụ Igbo','ig','ig'),(65,'Indonesian','Bahasa Indonesia','id','id'),(66,'Interlingua','Interlingua','ia',NULL),(67,'Interlingue','Originally called Occidental; then Interlingue aft','ie',NULL),(68,'Inuktitut','ᐃᓄᒃᑎᑐᑦ','iu',NULL),(69,'Inupiaq','Iñupiaq, Iñupiatun','ik',NULL),(70,'Irish','Gaeilge','ga','ga'),(71,'Italian','Italiano','it','it'),(72,'Japanese','日本語 (にほんご／にっぽんご)','ja','ja'),(73,'Javanese','basa Jawa','jv','jv'),(74,'Kalaallisut, Greenlandic','kalaallisut, kalaallit oqaasii','kl',NULL),(75,'Kannada','ಕನ್ನಡ','kn','kn'),(76,'Kanuri','Kanuri','kr',NULL),(77,'Kashmiri','कश्मीरी, كشميري‎','ks',NULL),(78,'Kazakh','Қазақ тілі','kk',NULL),(79,'Khmer','ភាសាខ្មែរ','km','km'),(80,'Kikuyu, Gikuyu','Gĩkũyũ','ki',NULL),(81,'Kinyarwanda','Ikinyarwanda','rw',NULL),(82,'Kirghiz, Kyrgyz','кыргыз тили','ky',NULL),(83,'Kirundi','kiRundi','rn',NULL),(84,'Komi','коми кыв','kv',NULL),(85,'Kongo','KiKongo','kg',NULL),(86,'Korean','한국어 (韓國語), 조선말 (朝鮮語)','ko','ko'),(87,'Kurdish','Kurdî, كوردی‎','ku',NULL),(88,'Kwanyama, Kuanyama','Kuanyama','kj',NULL),(89,'Lao','ພາສາລາວ','lo','lo'),(90,'Latin','latine, lingua latina','la','la'),(91,'Latvian','latviešu valoda','lv','lv'),(92,'Limburgish, Limburgan, Limburger','Limburgs','li',NULL),(93,'Lingala','Lingála','ln',NULL),(94,'Lithuanian','lietuvių kalba','lt','lt'),(95,'Luba-Katanga','','lu',NULL),(96,'Luganda','Luganda','lg',NULL),(97,'Luxembourgish, Letzeburgesch','Lëtzebuergesch','lb',NULL),(98,'Macedonian','македонски јазик','mk','mk'),(99,'Malagasy','Malagasy fiteny','mg',NULL),(100,'Malay','bahasa Melayu, بهاس ملايو‎','ms','ms'),(101,'Malayalam','മലയാളം','ml',NULL),(102,'Maltese','Malti','mt','mt'),(103,'Manx','Gaelg, Gailck','gv',NULL),(104,'Marathi (Marāṭhī)','मराठी','mr',NULL),(105,'Marshallese','Kajin M̧ajeļ','mh',NULL),(106,'Mongolian','монгол','mn','mn'),(107,'Māori','te reo Māori','mi',NULL),(108,'Nauru','Ekakairũ Naoero','na',NULL),(109,'Navajo, Navaho','Diné bizaad, Dinékʼehǰí','nv',NULL),(110,'Ndonga','Owambo','ng',NULL),(111,'Nepali','नेपाली','ne','ne'),(112,'North Ndebele','isiNdebele','nd',NULL),(113,'Northern Sami','Davvisámegiella','se',NULL),(114,'Norwegian','Norsk','no','no'),(115,'Norwegian Bokmål','Norsk bokmål','nb',NULL),(116,'Norwegian Nynorsk','Norsk nynorsk','nn',NULL),(117,'Nuosu','ꆈꌠ꒿ Nuosuhxop','ii',NULL),(118,'Occitan','Occitan','oc',NULL),(119,'Ojibwe, Ojibwa','ᐊᓂᔑᓈᐯᒧᐎᓐ','oj',NULL),(120,'Old Church Slavonic, Church Slavic, Church Slavoni','ѩзыкъ словѣньскъ','cu',NULL),(121,'Oriya','ଓଡ଼ିଆ','or',NULL),(122,'Oromo','Afaan Oromoo','om',NULL),(123,'Ossetian, Ossetic','ирон æвзаг','os',NULL),(124,'Panjabi, Punjabi','ਪੰਜਾਬੀ, پنجابی‎','pa',NULL),(125,'Pashto, Pushto','پښتو','ps',NULL),(126,'Persian','فارسی','fa','fa'),(127,'Polish','polski','pl','pl'),(128,'Portuguese','Português','pt','pt'),(129,'Pāli','पाऴि','pi',NULL),(130,'Quechua','Runa Simi, Kichwa','qu',NULL),(131,'Romanian, Moldavian, Moldovan','română','ro',NULL),(132,'Romansh','rumantsch grischun','rm',NULL),(133,'Russian','русский язык','ru','ru'),(134,'Samoan','gagana faa Samoa','sm',NULL),(135,'Sango','yângâ tî sängö','sg',NULL),(136,'Sanskrit (Saṁskṛta)','संस्कृतम्','sa',NULL),(137,'Sardinian','sardu','sc',NULL),(138,'Scottish Gaelic; Gaelic','Gàidhlig','gd',NULL),(139,'Serbian','српски језик','sr','sr'),(140,'Shona','chiShona','sn',NULL),(141,'Sindhi','सिन्धी, سنڌي، سندھی‎','sd',NULL),(142,'Sinhala, Sinhalese','සිංහල','si',NULL),(143,'Slovak','slovenčina','sk','sk'),(144,'Slovene','slovenščina','sl',NULL),(145,'Somali','Soomaaliga, af Soomaali','so','so'),(146,'South Ndebele','isiNdebele','nr',NULL),(147,'Southern Sotho','Sesotho','st',NULL),(148,'Spanish; Castilian','español, castellano','es',NULL),(149,'Sundanese','Basa Sunda','su',NULL),(150,'Swahili','Kiswahili','sw','sw'),(151,'Swati','SiSwati','ss',NULL),(152,'Swedish','svenska','sv','sv'),(153,'Tagalog','Wikang Tagalog, ᜏᜒᜃᜅ᜔ ᜆᜄᜎᜓᜄ᜔','tl',NULL),(154,'Tahitian','Reo Tahiti','ty',NULL),(155,'Tajik','тоҷикӣ, toğikī, تاجیکی‎','tg',NULL),(156,'Tamil','தமிழ்','ta','ta'),(157,'Tatar','татарча, tatarça, تاتارچا‎','tt',NULL),(158,'Telugu','తెలుగు','te','te'),(159,'Thai','ไทย','th','th'),(160,'Tibetan Standard, Tibetan, Central','བོད་ཡིག','bo',NULL),(161,'Tigrinya','ትግርኛ','ti',NULL),(162,'Tonga (Tonga Islands)','faka Tonga','to',NULL),(163,'Tsonga','Xitsonga','ts',NULL),(164,'Tswana','Setswana','tn',NULL),(165,'Turkish','Türkçe','tr','tr'),(166,'Turkmen','Türkmen, Түркмен','tk',NULL),(167,'Twi','Twi','tw',NULL),(168,'Uighur, Uyghur','Uyƣurqə, ئۇيغۇرچە‎','ug',NULL),(169,'Ukrainian','українська','uk','uk'),(170,'Urdu','اردو','ur','ur'),(171,'Uzbek','zbek, Ўзбек, أۇزبېك‎','uz',NULL),(172,'Venda','Tshivenḓa','ve',NULL),(173,'Vietnamese','Tiếng Việt','vi','vi'),(174,'Volapük','Volapük','vo',NULL),(175,'Walloon','Walon','wa',NULL),(176,'Welsh','Cymraeg','cy','cy'),(177,'Western Frisian','Frysk','fy',NULL),(178,'Wolof','Wollof','wo',NULL),(179,'Xhosa','isiXhosa','xh',NULL),(180,'Yiddish','ייִדיש','yi','yi'),(181,'Yoruba','Yorùbá','yo','yo'),(182,'Zhuang, Chuang','Saɯ cueŋƅ, Saw cuengh','za',NULL);
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lemma_content_pairs`
--

DROP TABLE IF EXISTS `lemma_content_pairs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lemma_content_pairs` (
  `english_lemma_id` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  KEY `content_id` (`content_id`),
  KEY `english_lemma_content` (`english_lemma_id`,`content_id`),
  CONSTRAINT `lemma_content_pairs_ibfk_1` FOREIGN KEY (`english_lemma_id`) REFERENCES `english_lemmas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `lemma_content_pairs_ibfk_2` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lemma_content_pairs`
--

LOCK TABLES `lemma_content_pairs` WRITE;
/*!40000 ALTER TABLE `lemma_content_pairs` DISABLE KEYS */;
/*!40000 ALTER TABLE `lemma_content_pairs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lessons`
--

DROP TABLE IF EXISTS `lessons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lessons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_id` int(11) DEFAULT NULL,
  `video` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `content_id` (`content_id`),
  CONSTRAINT `lessons_ibfk_1` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lessons`
--

LOCK TABLES `lessons` WRITE;
/*!40000 ALTER TABLE `lessons` DISABLE KEYS */;
INSERT INTO `lessons` VALUES (1,1,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/sm9cJXp_NMc\" frameborder=\"0\" allowfullscreen></iframe>'),(2,2,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/rc-3Cfc6lrE\" frameborder=\"0\" allowfullscreen></iframe>'),(3,3,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/po5yamNCEiw\" frameborder=\"0\" allowfullscreen></iframe>'),(4,4,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/pl6vKOQJj7Q\" frameborder=\"0\" allowfullscreen></iframe>'),(5,5,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/piYE4nxq2AY\" frameborder=\"0\" allowfullscreen></iframe>'),(6,6,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/ozMLxIA2qGo\" frameborder=\"0\" allowfullscreen></iframe>'),(7,7,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/jwE24rmEUQc\" frameborder=\"0\" allowfullscreen></iframe>'),(8,8,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/dudPm8iW4FE\" frameborder=\"0\" allowfullscreen></iframe>'),(9,9,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/XYS2aM32LCs\" frameborder=\"0\" allowfullscreen></iframe>'),(10,10,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/QwMNhkrBO7g\" frameborder=\"0\" allowfullscreen></iframe>'),(11,11,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/MbXwZ3RHSB8\" frameborder=\"0\" allowfullscreen></iframe>'),(12,12,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/MYWh5vrmWB8\" frameborder=\"0\" allowfullscreen></iframe>'),(13,13,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/K_58sg_VMbg\" frameborder=\"0\" allowfullscreen></iframe>'),(14,14,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/I_a2MdG2B8E\" frameborder=\"0\" allowfullscreen></iframe>'),(15,15,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/BuXQHr5LaSE\" frameborder=\"0\" allowfullscreen></iframe>'),(16,16,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/8RebNsiNkrA\" frameborder=\"0\" allowfullscreen></iframe>'),(17,17,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/5E9kyYbPQE8\" frameborder=\"0\" allowfullscreen></iframe>'),(18,18,'<iframe width=\"300\" height=\"225\" src=\"//www.youtube.com/embed/0v7rt7WyoG0\" frameborder=\"0\" allowfullscreen></iframe>');
/*!40000 ALTER TABLE `lessons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monthly_user_points`
--

DROP TABLE IF EXISTS `monthly_user_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monthly_user_points` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `month` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `monthly_user_points_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `auth_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monthly_user_points`
--

LOCK TABLES `monthly_user_points` WRITE;
/*!40000 ALTER TABLE `monthly_user_points` DISABLE KEYS */;
/*!40000 ALTER TABLE `monthly_user_points` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pictures`
--

DROP TABLE IF EXISTS `pictures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pictures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text COLLATE utf8_unicode_ci,
  `owner` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_pictures_owner` (`owner`),
  CONSTRAINT `pictures_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `auth_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pictures`
--

LOCK TABLES `pictures` WRITE;
/*!40000 ALTER TABLE `pictures` DISABLE KEYS */;
INSERT INTO `pictures` VALUES (1,'1',1),(2,'2',1),(3,'3',1),(4,'4',1),(5,'5',1),(6,'6',1),(7,'7',1),(8,'8',2),(9,'9',3),(10,'10',4),(11,'11',5),(12,'12',6),(13,'13',7),(14,'14',8),(15,'15',9),(16,'16',10),(17,'17',11),(18,'1339b18c-7446-4a15-91ec-76d788e36776_10',NULL),(19,'a1392622-97cd-4dd3-8b71-9735e54b981e_10',NULL),(20,'eaaa1aee-d85c-460c-b315-b9fa92b55ea2_10',NULL),(21,'6533d7b6-6fa6-40c7-9308-53a44562b7d4_10',NULL),(22,'fc511994-83a3-4a7a-b1f3-aee30a789c7b_10',NULL),(23,'79ce34e9-b1ad-4c43-a725-a5ece1cc53d7_10',NULL),(24,'0cb57cb7-da2d-4881-908f-d6fa6bfc894a_10',NULL),(25,'5fce9288-a6cf-4d5a-93c0-fc0e3c9d9252_10',NULL),(26,'c455da67-79fd-40b0-940c-bcf638bdb03d_10',NULL),(27,'8f813e30-e1dc-4348-a611-8285099fddeb_10',NULL),(28,'f5e501de-52ca-46f4-a824-e7724384bbfb_10',NULL),(29,'a98037a3-52e6-463a-8d6d-cb33ee20f4bd_10',NULL),(30,'1b2f6eb7-b3cb-4636-9fe9-5389a67c6fcf_10',NULL),(31,'ea1de479-9158-4659-935e-a75d0a5193c2_10',NULL),(32,'1220b9d7-b4ed-4aaa-96e1-bf9173a168e4_10',NULL),(33,'aeeb436c-c5f5-4800-aa56-23051eab133a_10',NULL),(34,'9d5c3c1c-6e25-4a13-9716-e205efcce1df_10',NULL),(35,'9780582a-08a3-4971-895f-a63402721980_10',NULL);
/*!40000 ALTER TABLE `pictures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `potential_pictures`
--

DROP TABLE IF EXISTS `potential_pictures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `potential_pictures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(75) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `potential_pictures`
--

LOCK TABLES `potential_pictures` WRITE;
/*!40000 ALTER TABLE `potential_pictures` DISABLE KEYS */;
/*!40000 ALTER TABLE `potential_pictures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profiles`
--

DROP TABLE IF EXISTS `profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` int(11) DEFAULT NULL,
  `picture_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `city` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `about_me` varchar(1000) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `picture_id` (`picture_id`),
  KEY `country_id` (`country_id`),
  KEY `ix_profiles_owner` (`owner`),
  CONSTRAINT `profiles_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `auth_id` (`id`),
  CONSTRAINT `profiles_ibfk_2` FOREIGN KEY (`picture_id`) REFERENCES `pictures` (`id`),
  CONSTRAINT `profiles_ibfk_3` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profiles`
--

LOCK TABLES `profiles` WRITE;
/*!40000 ALTER TABLE `profiles` DISABLE KEYS */;
INSERT INTO `profiles` VALUES (1,1,7,'Chris','1990-01-02',217,'Redding','I am a web developer'),(2,2,8,'Debbie','1957-01-03',217,'Redding','I am a mother and florist.'),(3,3,9,'Gabriel','2012-11-15',217,'Redding','I am a baby.'),(4,4,10,'Carlos Hernandez','1994-10-15',190,'Barcelona','I am a businessman.'),(5,5,11,'Adrian','1990-08-03',79,'Frankfurt','I am a programmer.'),(6,6,12,'Kim Eun Hye','1990-06-15',110,'Busan','I am a business woman.'),(7,7,13,'Reina Tanaka','1988-01-02',104,'Kyoto','I am a student.'),(8,8,14,'Doo Xianliang','1957-01-03',43,'Harbin','I am a student.'),(9,9,15,'Heike Brouwer','1980-07-20',147,'Hoorn','I am a businessman.'),(10,10,16,'Florian Belaire','1987-05-12',72,'Lyon','I am a student.');
/*!40000 ALTER TABLE `profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quality_votes`
--

DROP TABLE IF EXISTS `quality_votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quality_votes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `score` int(11) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `content_id` (`content_id`),
  KEY `ix_quality_votes_owner` (`owner`),
  CONSTRAINT `quality_votes_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `auth_id` (`id`),
  CONSTRAINT `quality_votes_ibfk_2` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quality_votes`
--

LOCK TABLES `quality_votes` WRITE;
/*!40000 ALTER TABLE `quality_votes` DISABLE KEYS */;
/*!40000 ALTER TABLE `quality_votes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questions`
--

DROP TABLE IF EXISTS `questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quiz_id` int(11) DEFAULT NULL,
  `prompt` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `correct_message` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `incorrect_message` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prompt` (`prompt`),
  KEY `quiz_id` (`quiz_id`),
  CONSTRAINT `questions_ibfk_1` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `questions`
--

LOCK TABLES `questions` WRITE;
/*!40000 ALTER TABLE `questions` DISABLE KEYS */;
/*!40000 ALTER TABLE `questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quizzes`
--

DROP TABLE IF EXISTS `quizzes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quizzes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `tagline` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quizzes`
--

LOCK TABLES `quizzes` WRITE;
/*!40000 ALTER TABLE `quizzes` DISABLE KEYS */;
INSERT INTO `quizzes` VALUES (1,'This quiz is coming soon!','Test your Knowledge!'),(2,'This quiz is coming soon!','Test your Knowledge!'),(3,'This quiz is coming soon!','Test your Knowledge!'),(4,'This quiz is coming soon!','Test your Knowledge!'),(5,'This quiz is coming soon!','Test your Knowledge!'),(6,'This quiz is coming soon!','Test your Knowledge!'),(7,'This quiz is coming soon!','Test your Knowledge!'),(8,'This quiz is coming soon!','Test your Knowledge!'),(9,'This quiz is coming soon!','Test your Knowledge!'),(10,'This quiz is coming soon!','Test your Knowledge!'),(11,'This quiz is coming soon!','Test your Knowledge!'),(12,'This quiz is coming soon!','Test your Knowledge!'),(13,'This quiz is coming soon!','Test your Knowledge!'),(14,'This quiz is coming soon!','Test your Knowledge!'),(15,'This quiz is coming soon!','Test your Knowledge!'),(16,'This quiz is coming soon!','Test your Knowledge!'),(17,'This quiz is coming soon!','Test your Knowledge!'),(18,'This quiz is coming soon!','Test your Knowledge!');
/*!40000 ALTER TABLE `quizzes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `readings`
--

DROP TABLE IF EXISTS `readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `readings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_id` int(11) DEFAULT NULL,
  `text` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `content_id` (`content_id`),
  CONSTRAINT `readings_ibfk_1` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `readings`
--

LOCK TABLES `readings` WRITE;
/*!40000 ALTER TABLE `readings` DISABLE KEYS */;
/*!40000 ALTER TABLE `readings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sources`
--

DROP TABLE IF EXISTS `sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reading_id` int(11) DEFAULT NULL,
  `author` varchar(60) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source` varchar(60) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reading_id` (`reading_id`),
  CONSTRAINT `sources_ibfk_1` FOREIGN KEY (`reading_id`) REFERENCES `readings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sources`
--

LOCK TABLES `sources` WRITE;
/*!40000 ALTER TABLE `sources` DISABLE KEYS */;
/*!40000 ALTER TABLE `sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag_content_pairs`
--

DROP TABLE IF EXISTS `tag_content_pairs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_content_pairs` (
  `tag_id` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  KEY `content_id` (`content_id`),
  KEY `tag_content` (`tag_id`,`content_id`),
  CONSTRAINT `tag_content_pairs_ibfk_1` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tag_content_pairs_ibfk_2` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag_content_pairs`
--

LOCK TABLES `tag_content_pairs` WRITE;
/*!40000 ALTER TABLE `tag_content_pairs` DISABLE KEYS */;
INSERT INTO `tag_content_pairs` VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17),(1,18);
/*!40000 ALTER TABLE `tag_content_pairs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
INSERT INTO `tags` VALUES (1,'grammar');
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `total_user_points`
--

DROP TABLE IF EXISTS `total_user_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `total_user_points` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `total_user_points_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `auth_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `total_user_points`
--

LOCK TABLES `total_user_points` WRITE;
/*!40000 ALTER TABLE `total_user_points` DISABLE KEYS */;
/*!40000 ALTER TABLE `total_user_points` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translations`
--

DROP TABLE IF EXISTS `translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_id` int(11) DEFAULT NULL,
  `foreign_lemma_id` int(11) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `card_id` (`card_id`),
  KEY `foreign_lemma_id` (`foreign_lemma_id`),
  KEY `ix_translations_count` (`count`),
  CONSTRAINT `translations_ibfk_1` FOREIGN KEY (`card_id`) REFERENCES `cards` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `translations_ibfk_2` FOREIGN KEY (`foreign_lemma_id`) REFERENCES `foreign_lemmas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=331 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translations`
--

LOCK TABLES `translations` WRITE;
/*!40000 ALTER TABLE `translations` DISABLE KEYS */;
INSERT INTO `translations` VALUES (1,86,1,1),(2,151,2,1),(3,216,3,1),(4,176,4,1),(5,316,5,1),(6,306,6,1),(7,241,7,1),(8,186,8,1),(9,211,9,1),(10,111,10,1),(11,66,11,1),(12,6,12,1),(13,276,13,1),(14,21,14,1),(15,291,15,1),(16,206,16,1),(17,51,17,1),(18,301,18,1),(19,96,19,1),(20,296,20,1),(21,91,21,1),(22,196,22,1),(23,261,23,1),(24,231,24,1),(25,271,25,1),(26,156,26,1),(27,41,27,1),(28,226,28,1),(29,256,29,1),(30,326,30,1),(31,121,31,1),(32,201,32,1),(33,76,34,1),(34,266,35,1),(35,71,33,1),(36,131,36,1),(37,126,37,1),(38,221,38,1),(39,286,39,1),(40,46,40,1),(41,236,41,1),(42,26,42,1),(43,11,43,1),(44,81,44,1),(45,191,45,1),(46,166,46,1),(47,181,47,1),(48,56,48,1),(49,321,49,1),(50,246,50,1),(51,61,51,1),(52,101,52,1),(53,1,53,1),(54,36,54,1),(55,251,55,1),(56,136,56,1),(57,31,57,1),(58,16,58,1),(59,311,59,1),(60,141,60,1),(61,171,61,1),(62,281,62,1),(63,116,63,1),(64,146,64,1),(65,161,65,1),(66,106,66,1),(67,87,67,1),(68,317,68,1),(69,177,69,1),(70,217,70,1),(71,292,71,1),(72,227,72,1),(73,277,73,1),(74,97,74,1),(75,212,75,1),(76,22,76,1),(77,77,77,1),(78,272,78,1),(79,197,79,1),(80,257,80,1),(81,152,81,1),(82,132,82,1),(83,307,83,1),(84,27,84,1),(85,202,85,1),(86,302,86,1),(87,297,87,1),(88,57,88,1),(89,92,89,1),(90,7,90,1),(91,187,91,1),(92,67,92,1),(93,127,93,1),(94,242,94,1),(95,287,95,1),(96,72,96,1),(97,207,97,1),(98,112,98,1),(99,157,99,1),(100,47,100,1),(101,327,101,1),(102,232,102,1),(103,42,103,1),(104,102,104,1),(105,167,105,1),(106,52,106,1),(107,322,107,1),(108,142,108,1),(109,262,109,1),(110,62,110,1),(111,32,111,1),(112,247,112,1),(113,122,113,1),(114,2,114,1),(115,267,116,1),(116,107,115,1),(117,222,117,1),(118,312,118,1),(119,252,119,1),(120,12,120,1),(121,237,121,1),(122,147,122,1),(123,282,123,1),(124,137,124,1),(125,192,125,1),(126,82,126,1),(127,182,127,1),(128,37,128,1),(129,158,130,1),(130,3,131,1),(131,298,132,1),(132,218,133,1),(133,48,134,1),(134,183,135,1),(135,53,136,1),(136,203,137,1),(137,103,138,1),(138,153,139,1),(139,193,140,1),(140,88,141,1),(141,208,142,1),(142,63,143,1),(143,188,144,1),(144,13,146,1),(145,288,145,1),(146,228,147,1),(147,113,148,1),(148,93,149,1),(149,83,150,1),(150,58,151,1),(151,268,152,1),(152,253,153,1),(153,223,154,1),(154,28,155,1),(155,143,156,1),(156,278,157,1),(157,148,158,1),(158,308,159,1),(159,243,160,1),(160,23,161,1),(161,323,162,1),(162,128,163,1),(163,33,164,1),(164,233,165,1),(165,238,166,1),(166,8,167,1),(167,138,168,1),(168,98,169,1),(169,123,170,1),(170,78,171,1),(171,38,172,1),(172,248,173,1),(173,318,174,1),(174,293,175,1),(175,263,176,1),(176,328,129,1),(177,108,177,1),(178,303,178,1),(179,178,179,1),(180,68,180,1),(181,198,181,1),(182,133,182,1),(183,168,183,1),(184,258,184,1),(185,313,185,1),(186,213,186,1),(187,73,187,1),(188,43,188,1),(189,273,189,1),(190,283,190,1),(191,117,191,1),(192,162,192,1),(193,172,193,1),(194,17,194,1),(195,49,195,1),(196,219,196,1),(197,154,197,1),(198,194,198,1),(199,94,199,1),(200,84,200,1),(201,204,201,1),(202,210,203,1),(203,190,204,1),(204,100,205,1),(205,330,206,1),(206,80,207,1),(207,25,208,1),(208,215,209,1),(209,130,210,1),(210,115,211,1),(211,325,212,1),(212,270,213,1),(213,30,214,1),(214,150,215,1),(215,45,216,1),(216,265,217,1),(217,260,218,1),(218,170,219,1),(219,110,220,1),(220,125,221,1),(221,60,222,1),(222,200,223,1),(223,235,224,1),(224,320,225,1),(225,230,226,1),(226,180,227,1),(227,250,228,1),(228,174,229,1),(229,285,230,1),(230,70,231,1),(231,275,232,1),(232,240,233,1),(233,135,234,1),(234,19,235,1),(235,75,236,1),(236,315,237,1),(237,119,238,1),(238,164,239,1),(239,175,240,1),(240,120,241,1),(241,20,242,1),(242,165,243,1),(243,69,244,1),(244,205,245,1),(245,234,246,1),(246,284,247,1),(247,264,248,1),(248,269,249,1),(249,109,250,1),(250,209,251,1),(251,195,252,1),(252,85,253,1),(253,118,254,1),(254,134,255,1),(255,124,257,1),(256,319,256,1),(257,163,258,1),(258,199,259,1),(259,18,260,1),(260,44,261,1),(261,79,262,1),(262,155,263,1),(263,304,264,1),(264,149,265,1),(265,169,266,1),(266,59,267,1),(267,220,268,1),(268,179,269,1),(269,229,270,1),(270,214,271,1),(271,24,272,1),(272,173,273,1),(273,34,274,1),(274,294,275,1),(275,239,276,1),(276,50,277,1),(277,29,278,1),(278,329,279,1),(279,74,280,1),(280,189,281,1),(281,324,282,1),(282,129,283,1),(283,99,285,1),(284,95,284,1),(285,274,286,1),(286,224,202,1),(287,249,287,1),(288,279,288,1),(289,39,289,1),(290,114,290,1),(291,314,291,1),(292,144,292,1),(293,244,293,1),(294,54,294,1),(295,184,295,1),(296,259,296,1),(297,89,297,1),(298,159,298,1),(299,254,299,1),(300,309,300,1),(301,9,301,1),(302,14,302,1),(303,299,303,1),(304,4,304,1),(305,104,305,1),(306,289,306,1),(307,64,307,1),(308,139,308,1),(309,305,309,1),(310,310,310,1),(311,160,311,1),(312,15,312,1),(313,5,313,1),(314,90,314,1),(315,225,318,1),(316,40,319,1),(317,105,320,1),(318,280,321,1),(319,255,322,1),(320,295,315,1),(321,140,323,1),(322,65,324,1),(323,185,325,1),(324,290,326,1),(325,245,317,1),(326,300,327,1),(327,10,328,1),(328,145,156,1),(329,35,316,1),(330,55,329,1);
/*!40000 ALTER TABLE `translations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_added_content_vocab`
--

DROP TABLE IF EXISTS `user_added_content_vocab`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_added_content_vocab` (
  `user_id` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  KEY `content_id` (`content_id`),
  KEY `user_added_content_vocab` (`user_id`,`content_id`),
  CONSTRAINT `user_added_content_vocab_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `auth_id` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_added_content_vocab_ibfk_2` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_added_content_vocab`
--

LOCK TABLES `user_added_content_vocab` WRITE;
/*!40000 ALTER TABLE `user_added_content_vocab` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_added_content_vocab` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_finished_content`
--

DROP TABLE IF EXISTS `user_finished_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_finished_content` (
  `user_id` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  KEY `content_id` (`content_id`),
  KEY `user_finished_content` (`user_id`,`content_id`),
  CONSTRAINT `user_finished_content_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `auth_id` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_finished_content_ibfk_2` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_finished_content`
--

LOCK TABLES `user_finished_content` WRITE;
/*!40000 ALTER TABLE `user_finished_content` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_finished_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_points`
--

DROP TABLE IF EXISTS `user_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_points` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_points_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `auth_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_points`
--

LOCK TABLES `user_points` WRITE;
/*!40000 ALTER TABLE `user_points` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_points` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_voted_content_difficulty`
--

DROP TABLE IF EXISTS `user_voted_content_difficulty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_voted_content_difficulty` (
  `user_id` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  KEY `content_id` (`content_id`),
  KEY `user_voted_content_difficulty` (`user_id`,`content_id`),
  CONSTRAINT `user_voted_content_difficulty_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `auth_id` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_voted_content_difficulty_ibfk_2` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_voted_content_difficulty`
--

LOCK TABLES `user_voted_content_difficulty` WRITE;
/*!40000 ALTER TABLE `user_voted_content_difficulty` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_voted_content_difficulty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_voted_content_quality`
--

DROP TABLE IF EXISTS `user_voted_content_quality`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_voted_content_quality` (
  `user_id` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  KEY `content_id` (`content_id`),
  KEY `user_voted_content_quality` (`user_id`,`content_id`),
  CONSTRAINT `user_voted_content_quality_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `auth_id` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_voted_content_quality_ibfk_2` FOREIGN KEY (`content_id`) REFERENCES `contents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_voted_content_quality`
--

LOCK TABLES `user_voted_content_quality` WRITE;
/*!40000 ALTER TABLE `user_voted_content_quality` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_voted_content_quality` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weekly_user_points`
--

DROP TABLE IF EXISTS `weekly_user_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weekly_user_points` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `week` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `weekly_user_points_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `auth_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weekly_user_points`
--

LOCK TABLES `weekly_user_points` WRITE;
/*!40000 ALTER TABLE `weekly_user_points` DISABLE KEYS */;
/*!40000 ALTER TABLE `weekly_user_points` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-08-17 19:37:39
