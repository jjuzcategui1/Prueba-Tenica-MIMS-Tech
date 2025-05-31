# Stage 1: Construir la Aplicacion Node.js
FROM node:20-alpine AS builder

# Create app directory
WORKDIR /app/

RUN ls -l

COPY package*.json /app/

RUN ls -l /app/

RUN npm install --only=production
RUN npm install --omit=dev

# Copy app source
COPY . /app/

# Stage 2: Crea la imagen final de produccion 
#FROM node:20-alpine

#WORKDIR /app/

# Copia las dependencias a produccion y el codigo de la aplicacion 
#COPY --from=builder /app/node_modules ./node_modules
#COPY --from=builder /app/app.js .

# Run the application
CMD ["node", "app.js"]

# Expose port
EXPOSE 3000

