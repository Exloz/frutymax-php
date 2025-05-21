# Etapa 1: Build de assets con Node
FROM node:20-alpine AS node-build

WORKDIR /app

COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm ci

COPY resources ./resources
COPY vite.config.* ./
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

# Copia dependencias PHP y código fuente
COPY --from=composer-deps /app/vendor ./vendor
COPY . .

# Copia los assets compilados
COPY --from=node-build /app/resources/dist ./public/build

# Permisos para Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Variables de entorno recomendadas
ENV APP_ENV=production \
    APP_DEBUG=false \
    LOG_CHANNEL=stderr

EXPOSE 9000

CMD ["php-fpm"]
