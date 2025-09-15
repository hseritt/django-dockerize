#!/usr/bin/env bash

env=$@

clear

if [ "$env" = "prod" ]
then
    curl http://localhost/llm/test-ollama/
else
    curl http://localhost:8000/llm/test-ollama/
fi
