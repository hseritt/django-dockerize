#!/usr/bin/env bash

clear
flake8 --exclude=apps/**/migrations &&
coverage run --omit=**/migrations/*,manage.py manage.py test --failfast &&
coverage report -m