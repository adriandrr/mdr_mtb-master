#!/bin/bash

# Create a new virtual environment
python3 -m venv .tests/venv

# Activate the virtual environment
source .tests/venv/bin/activate

# Install the required packages
pip install -r .tests/resources/requirements.txt
