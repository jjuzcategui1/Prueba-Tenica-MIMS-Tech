# Stage 1: Construir la Aplicacion Node.js
FROM node:20-alpine AS builder

# Create app directory
WORKDIR /app/

COPY package*.json /app/

RUN npm install --only=production

# Copy app source
COPY . .

# Stage 2: Crea la imagen final de produccion 
FROM node:20-alpine

WORKDIR /app/

# Copia las dependencias a produccion y el codigo de la aplicacion 
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/app.js .

# Expose port
EXPOSE 3000

# Run the application
CMD ["node", "app.js"]