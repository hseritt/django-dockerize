#!/usr/bin/env bash

clear;
./dockerize.sh &&
cd master-project/ &&
source pyenv/bin/activate &&
./getdeps.sh &&
sudo ./dev-up.sh &&
sudo ./prod-up.sh &&
deactivate
cd ..
sudo rm -rf master-project
sh clear-docker.sh

