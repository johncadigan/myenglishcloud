#!/bin/bash


mysql -u root -p password englishc < englishc.sql
pip install virtualenv
virtualenv .
source bin/activate
python setup.py install
pip install -r reqs.txt
pip install PIL --allow-unverified PIL --allow-all-external
