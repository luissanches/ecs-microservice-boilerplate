#!/bin/bash

echo ">>> Install microservices is starting ..."
echo ""

rm -f SourceCode/backend/microservices/auth/node_modules/
rm -f SourceCode/backend/microservices/tenants/node_modules/

npm i SourceCode/backend/microservices/auth/
npm i SourceCode/backend/microservices/tenants/

echo ""
echo ">>> Install microservices has been completed"