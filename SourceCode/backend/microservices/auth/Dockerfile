FROM node:15.3
ENV NODE_ENV=production

WORKDIR /app/

COPY ./common/ ./common/

COPY ./microservices/auth/ ./microservices/auth/

RUN npm install --production

COPY . .

CMD [ "node", "src/test.js" ]
