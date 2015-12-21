# myenglishcloud
A demo of my former website

#Prereqs
Ideally this will be installed on Ubuntu which will enable you to install prerequisites with the package manager

sudo apt-get install mysql-server 

sudo apt-get install python-dev libmysqlclient-dev

sudo pip install virtualenv

You then need to create a database named englishc for the dumped database, englishc.sql, to be loaded into during installation:

mysql -u root -p -h localhost
create database englishc;

#Installation
Add permissions for the scripts:
chmod a+rwx install.sh run.sh

./install.sh


#Running
./run.sh



