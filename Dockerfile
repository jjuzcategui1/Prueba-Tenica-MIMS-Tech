FROM node:18-alpine
WORKDIR /app
COPY package.json ./
RUN npm install --only=production
COPY . .
CMD ["node", "app.js"]
EXPOSE 3000