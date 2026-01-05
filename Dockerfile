FROM php:8.2-cli

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update && apt-get install -y \
    git unzip zip curl \
    libpng-dev libonig-dev libxml2-dev libzip-dev \
    libicu-dev libpq-dev

RUN docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    exif \
    bcmath \
    gd \
    zip \
    intl

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY composer.json composer.lock ./

# 🔥 THIS IS THE KEY LINE
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress --ignore-platform-reqs

COPY . .

RUN php artisan key:generate || true

EXPOSE 10000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
