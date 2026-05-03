FROM node:18-alpine

# App user
RUN addgroup -S app && adduser -S app -G app
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy app
COPY . .

USER app
ENV NODE_ENV=production
CMD ["node", "server.js"]
