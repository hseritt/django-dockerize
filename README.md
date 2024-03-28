# Django-Dockerize

django-dockerize is a very simple way to create a Django project with docker containers. django-dockerize provides  a dev and prod environment (prod uses nginx and gunicorn). It also provides a Postgresql database.

This is a good option if you are interested in setting up a basic Django project with dockerization. Typically, I would only recommend development using docker with Django in cases where your production environment makes use of containers (Kubernetes) or if you just want to get a feel for developing using docker containers.

Besides providing Postgres, it is not overly opiniated. It does not come with the kitchen sink. For that I would recommend having a look at [cookiecutter-django](https://github.com/cookiecutter/cookiecutter-django) by pydanny. At least the packages given in the project can easily be removed and an alternate one can be provided.

These packages are:

* Using pip and pip-compile with pip-sync. Pip is used to install packages on the docker side. But, in docker and on the local side, Pipenv or Poetry can easily be added to the project if you prefer to add them.
* Gunicorn. You can switch that for guvicorn if you prefer.
* django-environ is used to handle project environment settings.
* black is included for formatting.
* Most current version of Python is 3.12.1. Feel free to change that if you prefer.
* A couple of scripts are used to create a superuser called 'admin' (default password is 'admin').
* Static files dir is called staticfiles and media files dir is called mediafiles.
* Adds test.sh script to run tests and coverage. Just don't use if you don't prefer it.

## How to Use It

Do a git clone of this project:

```
git clone git@github.com:hseritt/django-dockerize.git
```

Run dockerize:

```
./dockerize
```

You'll be asked a few questions:

```
Enter MASTER_PROJECT_NAME (default: master-project): 
Enter PYTHON_VERSION (default: 3.12.1): 
Enter DJANGO_PROJECT_NAME (default: myproject - should be named as a python module): 
Enter DB_NAME (default: myproject): 
Enter DB_USER (default: admin): 
Enter DB_PASS (default: admin): 
Enter VIRTUAL_ENV (default: .venv):
```

* **MASTER_PROJECT_NAME** is your main folder. You should run `git init` here.
* **PYTHON_VERSION** is the version of Python you are currently using. This script will not install it. I recommend using pyenv to install and manage your Python versions.
* **DJANGO_PROJECT_NAME** is the name of your Django project. Keep in mind it is a python module. So, don't use dashes or spaces. This is the name of your Django project when you typically run `django-admin startproject [project_name]`.
* **DB_NAME** is your database name. **DB_USER** and **DB_PASS** are your database username and password.
* **VIRTUAL_ENV** is the installation folder of your project's Python virtual environment.

In this folder where `dockerize.sh` is run, this will create a folder called master-project by default (or whichever name you give it). You can then move it anywhere you would like. Keep in mind though that the files created in the .venv folder usually have relative paths set for the linked files. You may have to reset this if you move it elsehwere (which you should probably do).
