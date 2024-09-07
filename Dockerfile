FROM php:8.2-fpm

ENV PORT 8080

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Node y NPM
RUN curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
RUN ["sh",  "./nodesource_setup.sh"]

# Linux
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libmemcached-dev  \
    zlib1g-dev \
    libssl-dev \
    libzip-dev \
    libmagickwand-dev --no-install-recommends \
    zip \
    unzip \
    nodejs \
    && npm install -g npm \ 
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    # Intl
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-enable intl \
    # PHP ZIP
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip \
    && docker-php-ext-enable zip \
    && docker-php-ext-install ftp

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY docker/php/999-php_custom.ini /usr/local/etc/php/conf.d/

# Otras extensiones de php
RUN docker-php-ext-install pdo pdo_mysql mbstring 

# Extensiones PECL
RUN pecl install xdebug \
    && pecl install memcached \
    && pecl install imagick \
    && docker-php-ext-enable xdebug memcached imagick

WORKDIR /var/www/

COPY composer.json .

RUN composer install --no-scripts

COPY package.json .

COPY . /var/www/

RUN npm install

RUN npm run build

COPY docker/start.sh /start.sh

RUN chmod +x /start.sh

CMD ["/start.sh"]

EXPOSE $PORT