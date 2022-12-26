#!/usr/bin/env bash

APP="myproject"
REQUIREMENTS="${APP}/requirements.txt"

function main() {
    pip-compile -o ${REQUIREMENTS} &&
    pip-sync ${REQUIREMENTS} 
}

main;
