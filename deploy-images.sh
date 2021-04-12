#!/bin/bash

echo ">>> Deploy images is starting ..."
echo ""

./build-images.sh

echo ">>> Going to AWS Container Registry login ..."

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 105019345634.dkr.ecr.us-east-1.amazonaws.com
docker tag oe-backend-auth:latest 105019345634.dkr.ecr.us-east-1.amazonaws.com/oe-backend-auth:latest
docker push 105019345634.dkr.ecr.us-east-1.amazonaws.com/oe-backend-auth:latest

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 105019345634.dkr.ecr.us-east-1.amazonaws.com
docker tag oe-backend-billing:latest 105019345634.dkr.ecr.us-east-1.amazonaws.com/oe-backend-billing:latest
docker push 105019345634.dkr.ecr.us-east-1.amazonaws.com/oe-backend-billing:latest

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 105019345634.dkr.ecr.us-east-1.amazonaws.com
docker tag oe-backend-tenants:latest 105019345634.dkr.ecr.us-east-1.amazonaws.com/oe-backend-tenants:latest
docker push 105019345634.dkr.ecr.us-east-1.amazonaws.com/oe-backend-tenants:latest

echo ""
echo ">>> Images have been deployed successsfully..."