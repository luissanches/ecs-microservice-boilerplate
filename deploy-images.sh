#!/bin/bash

echo ">>> Deploy images is starting ..."
echo ""

./build-images.sh

echo ">>> Going to AWS Container Registry login ..."

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 105019345634.dkr.ecr.us-east-1.amazonaws.com

docker tag one-edge-backend-auth:latest 105019345634.dkr.ecr.us-east-1.amazonaws.com/one-edge-backend-auth:latest
docker push 105019345634.dkr.ecr.us-east-1.amazonaws.com/one-edge-backend-auth:latest

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 105019345634.dkr.ecr.us-east-1.amazonaws.com

docker tag one-edge-backend-tenants:latest 105019345634.dkr.ecr.us-east-1.amazonaws.com/one-edge-backend-tenants:latest
docker push 105019345634.dkr.ecr.us-east-1.amazonaws.com/one-edge-backend-tenants:latest

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 105019345634.dkr.ecr.us-east-1.amazonaws.com

docker tag one-edge-backend-billing:latest 105019345634.dkr.ecr.us-east-1.amazonaws.com/one-edge-backend-billing:latest
docker push 105019345634.dkr.ecr.us-east-1.amazonaws.com/one-edge-backend-billing:latest

echo ""
echo ">>> Images have been deployed successsfully..."