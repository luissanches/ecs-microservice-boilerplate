#!/bin/bash

echo ">>> Build backend containers is starting ..."
echo ""

cd SourceCode/backend

docker build -t one-edge-backend-auth -f microservices/auth/Dockerfile .

docker build -t one-edge-backend-tenants -f microservices/tenants/Dockerfile .

docker build -t one-edge-backend-billing -f microservices/billing/Dockerfile .

echo ""
echo ">>> Build backend containers has been completed"