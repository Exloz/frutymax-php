# Dockerfile (ubicado en la raíz del proyecto)

### Etapa 1: construir assets con Node.js y Vite ###
FROM node:20-alpine AS assets

WORKDIR /var/www/html

# instalar dependencias de JS
COPY package.json package-lock.json ./
COPY vite.config.js tailwind.config.js postcss.config.js tsconfig.json ./
COPY resources/ resources/

RUN npm ci \
 && npm run build

### Etapa 2: preparar PHP-FPM y composer ###
FROM php:8.2-fpm-alpine AS app

WORKDIR /var/www/html

# instalar dependencias de sistema y extensiones PHP
RUN apk add --no-cache \
      bash git libzip-dev oniguruma-dev libpng-dev curl-dev zip unzip \
 && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath

# copiar binario de composer desde la imagen oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ajustar PHP-FPM para escuchar en el puerto 9000
RUN sed -i 's|^listen = .*|listen = 9000|' /usr/local/etc/php-fpm.d/www.conf

# copiar código de aplicación
COPY . .

# copiar assets compilados
COPY --from=assets /var/www/html/public/build public/build

# instalar dependencias de PHP y cachear configuración
RUN composer install --optimize-autoloader --no-dev --no-interaction \
 && php artisan config:cache \
 && php artisan route:cache \
 && php artisan view:cache

# permisos
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000

# comando por defecto
CMD ["php-fpm"]
