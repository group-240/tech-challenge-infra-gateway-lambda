#!/bin/bash

# Clean up any existing zips
rm -f authorizer.zip customers.zip

# Zip authorizer lambda
cd src/authorizer
zip -r ../../authorizer.zip lambda_function.py
cd ../..

# Setup temporary directory for customers lambda
TEMP_DIR=$(mktemp -d)
cd src/customers
cp lambda_function.py requirements.txt $TEMP_DIR/
cd $TEMP_DIR
python3 -m pip install -r requirements.txt -t .
rm -f requirements.txt
zip -r ../../customers.zip .
cd ../..

# Cleanup
rm -rf $TEMP_DIR
rm -f src/customers/customers.zip