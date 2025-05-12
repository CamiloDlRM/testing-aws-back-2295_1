# Etapa de construcción
FROM node:18-alpine AS builder

# Configurar directorio de trabajo
WORKDIR /usr/src/app

# Copiar archivos de configuración
COPY package.json package-lock.json ./

# Instalar dependencias
RUN npm install

COPY . .

ARG NODE_ENV=build
ARG DB_HOST=localhost
ARG DB_PORT=5432
ARG DB_USERNAME=testuser
ARG DB_PASSWORD=testpass
ARG DB_NAME=testdb

ENV NODE_ENV=$NODE_ENV \
    DB_HOST=$DB_HOST \
    DB_PORT=$DB_PORT \
    DB_USERNAME=$DB_USERNAME \
    DB_PASSWORD=$DB_PASSWORD \
    DB_NAME=$DB_NAME

RUN npm run build

FROM node:18-alpine AS production

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/package.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules

EXPOSE 3000

CMD ["node", "dist/main.js"]
