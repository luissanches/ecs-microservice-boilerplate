#!/bin/bash

echo ">>> Build backend containers is starting ..."
echo ""

cd SourceCode/backend

docker build -t one-edge-backend-auth -f microservices/auth/Dockerfile .

echo ""
echo ">>> Build backend containers has been completed"