# ---------- Test Stage ----------
FROM node:18-alpine AS tester

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Install curl only in test stage
RUN apk add --no-cache curl

# Start app and test health endpoint
RUN node appointment-service.js & \
    PID=$! && \
    sleep 3 && \
    curl -f http://localhost:3001/health && \
    kill $PID


# ---------- Production Stage ----------
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY . .

EXPOSE 3001

USER node

CMD ["node", "appointment-service.js"]

docker tag appointment-service:latest 333813598365.dkr.ecr.ap-south-1.amazonaws.com/appointment-service:latest
docker push 333813598365.dkr.ecr.ap-south-1.amazonaws.com/appointment-service:latest