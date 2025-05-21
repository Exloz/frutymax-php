# Etapa 1: Build de assets con Node
FROM node:20-alpine AS node-build

WORKDIR /app

# Copiar archivos necesarios para instalar dependencias
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./

RUN npm ci

# Copiar código fuente necesario para el build de Vite
COPY resources ./resources
COPY public ./public
COPY vite.config.* ./
COPY tsconfig.* ./
COPY .env .env

RUN npm run build

# Etapa 2: Dependencias PHP y Composer
FROM composer:2.7 AS composer-deps

WORKDIR /app

COPY composer.json composer.lock ./
COPY artisan ./
COPY bootstrap ./bootstrap
COPY routes ./routes
COPY config ./config
COPY app ./app

RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# Etapa 3: Imagen final de producción
FROM php:8.2-fpm-alpine

# Instala extensiones necesarias
RUN apk add --no-cache \
    icu-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libzip-dev \
    oniguruma-dev \
    zip \
    unzip \
    git \
    curl \
    bash \
    && docker-php-ext-install intl pdo pdo_mysql mbstring zip exif pcntl

WORKDIR /var/www/html

# Copia dependencias PHP
COPY --from=composer-deps /app/vendor ./vendor

# Copia código fuente Laravel (puedes filtrar si lo deseas)
COPY . .

# Copia los assets compilados de Vite
COPY --from=node-build /app/public/build ./public/build

# Asegura que los directorios clave tengan los permisos correctos
RUN chown -R www-data:www-data \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache

# Variables de entorno para producción
ENV APP_ENV=production \
    APP_DEBUG=false \
    LOG_CHANNEL=stderr

EXPOSE 9000

CMD ["php-fpm"]
