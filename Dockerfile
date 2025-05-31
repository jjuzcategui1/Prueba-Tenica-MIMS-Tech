# Construir la Aplicacion Node.js
FROM node:20-alpine AS builder

# Create app directory
WORKDIR /app

COPY ../app/package.json ../app/package-lock.json ./

RUN npm install --only=production

# Copy app source
COPY ../app/ .

# Run the application
CMD ["node", "app.js"]

# Expose port
EXPOSE 3000

