#!/usr/bin/env bash



clear;
sudo rm -rf master-project
./dockerize.sh &&
cd master-project/ &&
source .venv/bin/activate &&
./getdeps.sh &&
./dev-up.sh &&
./prod-up.sh &&
docker-compose down -v
docker-compose -f docker-compose.prod.yml down -v
deactivate
cd ..
sudo rm -rf master-project
