#!/bin/bash

echo ">>> Install microservices is starting ..."
echo ""

echo ">>> Removing node modules..."
rm -rf ./SourceCode/backend/microservices/auth/node_modules
rm -rf ./SourceCode/backend/microservices/tenants/node_modules

echo ">>> Installing auth dependencies..."
cd ./SourceCode/backend/microservices/auth
npm i 

echo ">>> Installing tenants dependencies..."
cd ../tenants
npm i 

echo ">>> Installing billing dependencies..."
cd ../billing
npm i 

echo ""
echo ">>> Install microservices has been completed"