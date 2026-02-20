FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

RUN node patient-service.js & \
    sleep 3 && \
    curl -f http://localhost:3001/health && \
    kill $!

EXPOSE 3001

USER node

CMD ["node", "appointment-service.js"]