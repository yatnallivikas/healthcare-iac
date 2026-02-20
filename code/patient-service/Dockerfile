# ---------- Test Stage ----------
FROM node:18-alpine AS tester

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Install curl only in test stage
RUN apk add --no-cache curl

# Start app and test health endpoint
RUN node patient-service.js & \
    PID=$! && \
    sleep 3 && \
    curl -f http://localhost:3000/health && \
    kill $PID

# ---------- Production Stage ----------
FROM node:18-alpine

WORKDIR /app

# Copy only package files first
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy application source
COPY . .

EXPOSE 3000

USER node

CMD ["node", "patient-service.js"]
