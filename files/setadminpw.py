#!/usr/bin/env python

import os
import sys

import django

sys.path.append(".")
os.environ["DJANGO_SETTINGS_MODULE"] = "config.settings"

django.setup()

from django.contrib.auth.models import User  # noqa: E402

admin_user = User.objects.get(username="admin")
admin_user.set_password("admin")
admin_user.save()
