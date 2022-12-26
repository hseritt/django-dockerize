#!/usr/bin/env bash

MASTER_PROJECT_NAME="master-project"
PYTHON_VERSION="3.10.8"

clear; reset;

echo "Re-creating $MASTER_PROJECT_NAME if exists ..."
rm -rf $MASTER_PROJECT_NAME
mkdir $MASTER_PROJECT_NAME
echo "  Done"

cd $MASTER_PROJECT_NAME

echo "Setting runtime ..."
echo "python-$PYTHON_VERSION" > runtime.txt
echo "  Done"

echo "Building virtual environment ..."
python -m venv pyenv
source pyenv/bin/activate
echo "  Done"

echo "Setting up pip and pip-tools ..."
pip install --upgrade pip
pip install pip-tools
cp -v ../files/requirements.in .
echo "  Done"

echo "Running pip-compile and installing packages ..."
pip-compile
pip-sync
echo "  Done"

echo "Setting up Django project ..."
django-admin startproject myproject
cd myproject
./manage.py startapp myapp
cd ..
echo "  Done"

echo "Adding environment files ..."
cp -v ../files/.env* .
echo "  Done"

echo "Adding docker-compose files ..."
cp -v ../files/docker-compose* .
echo "  Done"

echo "Adding Dockerfiles ..."
cp -v ../files/Docker* myproject/.
echo "  Done"

echo "Adding entrypoint files ..."
cp -v ../files/entrypoint.* myproject/.
echo "  Done"

echo "Setting up Nginx ..."
mkdir nginx
cp ../files/nginx/Dockerfile nginx/.
cp ../files/nginx/nginx.conf nginx/.
echo "  Done"

echo "Additional scripts ..."
cp ../files/createadmin.sh myproject/.
cp ../files/setadminpw.py myproject/.
cp ../files/getdeps.sh .
cp ../files/dev-up.sh .
cp ../files/prod-up.sh .
echo "  Done"
