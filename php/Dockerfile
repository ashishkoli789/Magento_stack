# -----------------------------
# Composer stage
# -----------------------------
FROM composer:2.7 AS composer

# -----------------------------
# Runtime stage
# -----------------------------
FROM php:8.3-fpm-bookworm

# Install system packages
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    zip \
    libicu-dev \
    libxml2-dev \
    libzip-dev \
    libxslt1-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libwebp-dev \
    libxpm-dev \
    libmagickwand-dev \
    libsodium-dev \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Configure GD
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp

# Install PHP extensions
RUN docker-php-ext-install \
    bcmath \
    exif \
    ftp \
    gd \
    intl \
    opcache \
    pdo_mysql \
    soap \
    sockets \
    xsl \
    zip

# Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Create user/group
RUN groupadd -g 1001 clp && \
    useradd -u 1001 -g clp -m -s /bin/bash test-ssh

# Copy composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy configs
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

# Set ownership
RUN chown -R test-ssh:clp /var/www/html

# Run as non-root
USER test-ssh

CMD ["php-fpm"]
