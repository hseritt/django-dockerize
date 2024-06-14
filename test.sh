#!/usr/bin/env bash



clear;
sudo rm -rf master-project
./dockerize.sh &&
cd master-project/ &&
source .venv/bin/activate &&
./getdeps.sh &&
cd myproject
./test.sh &&
cd ..
./dev-up.sh
docker-compose down -v
./prod-up.sh
docker-compose -f docker-compose.prod.yml down -v
deactivate
cd ..
sudo rm -rf master-project
