#!/usr/bin/env bash

flake8 --exclude=apps/**/migrations &&
coverage run --omit=**/migrations/*,manage.py manage.py test --failfast &&
coverage report -m