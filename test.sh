#!/usr/bin/env bash



clear;
sudo rm -rf master-project
./dockerize.sh &&
cd master-project/ &&
source .venv/bin/activate &&
./getdeps.sh &&
sudo ./dev-up.sh &&
sudo ./prod-up.sh &&
deactivate
cd ..
sudo rm -rf master-project
sh clear-docker.sh
