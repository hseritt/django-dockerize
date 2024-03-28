# Dockerize

django-dockerize creates a Django project and then containerizes it with a dev and prod environment (prod uses nginx and gunicorn). It also provides a Postgresql database.

Besides providing Postgres, it is not overly opiniated. At least the packages given in the project can easily be removed and an alternate one can be provided.

These are:

* Using pip and pip-compile with pip-sync. Pipenv or Poetry can easily be added to the project if you prefer to add them.
* Gunicorn. You can switch that for guvicorn if you prefer.
* django-environ is used to handle project environment settings.
* black is included for formatting.
* Most current version of Python is 3.12.1. Feel free to change that if you prefer.
* A couple of scripts are used to create a superuser called 'admin' (default password is 'admin').
* Static files dir is called staticfiles and media files dir is called mediafiles.

## How to Use It

Do a git clone of this project:

```
# git clone git@github.com:hseritt/django-dockerize.git
```

Run dockerize:

```
./dockerize

Enter MASTER_PROJECT_NAME (default: master-project): 
Enter PYTHON_VERSION (default: 3.12.1): 
Enter DJANGO_PROJECT_NAME (default: myproject - should be named as a python module): 
Enter DB_NAME (default: myproject): 
Enter DB_USER (default: admin): 
Enter DB_PASS (default: admin): 
Enter VIRTUAL_ENV (default: .venv): 

```

MASTER_PROJECT_NAME is your main folder. You should run `git init` here.
PYTHON_VERSION is the version of Python you are currently using. This script will not install it. I recommend using pyenv to install and manage your Python versions.
DJANGO_PROJECT_NAME is a python module. This is the name of your Django project when you typically run `django-admin startproject [project_name]`.
DB_NAME is your database name. DB_USER and DB_PASS are your database username and password.
VIRTUAL_ENV is the installation folder of your project's Python virtual environment.

In this folder where `dockerize.sh` is run, this will create a folder called master-project. You can then move it anywhere you would like. Keep in mind though that the files created in the .venv folder usually have relative paths set for the linked files. You may have to reset this if you move it elsehwere (which you should probably do).
