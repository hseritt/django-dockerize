#!/usr/bin/env bash

APP="$DJANGO_PROJECT_NAME"
REQUIREMENTS="${APP}/requirements.txt"

function main() {
    pip-compile -o ${REQUIREMENTS} &&
    pip-sync ${REQUIREMENTS} 
}

main;
