#!/bin/bash

# Find and delete all *.pyc files in the current directory and subdirectories
find . -type f -name "*.pyc" -delete

echo "All .pyc files have been deleted."
